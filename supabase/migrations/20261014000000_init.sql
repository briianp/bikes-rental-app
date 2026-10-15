-- =====================================================================
-- Bikes App · Esquema inicial
--
-- Cómo aplicarlo: Supabase Dashboard → SQL Editor → pegar y ejecutar.
-- (o con la CLI: `supabase db push`)
--
-- Contenido:
--   1. Tipos
--   2. Tablas e índices
--   3. Funciones auxiliares y triggers
--   4. Seguridad (Row Level Security)
--   5. Funciones de negocio (RPC): start_rental / finish_rental
--   6. Vista rental_details
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. Tipos
-- ---------------------------------------------------------------------
create type public.user_role as enum ('admin', 'employee');
create type public.bike_status as enum ('available', 'rented', 'maintenance');
create type public.rental_status as enum ('active', 'finished');


-- ---------------------------------------------------------------------
-- 2. Tablas
-- ---------------------------------------------------------------------

-- Sucursales
create table public.branches (
  id          uuid primary key default gen_random_uuid(),
  name        text not null unique check (length(trim(name)) > 0),
  address     text,
  is_active   boolean not null default true,
  created_at  timestamptz not null default now()
);

-- Perfil de cada usuario de Supabase Auth (empleado o administrador).
-- Se crea automáticamente con el trigger on_auth_user_created.
create table public.profiles (
  id          uuid primary key references auth.users (id) on delete cascade,
  full_name   text not null,
  email       text not null,
  role        public.user_role not null default 'employee',
  branch_id   uuid references public.branches (id),
  is_active   boolean not null default true,
  created_at  timestamptz not null default now()
);

-- Bicicletas. `code` es el texto que lleva el QR (ej. BK-001).
create table public.bikes (
  id           uuid primary key default gen_random_uuid(),
  code         text not null unique
                 check (length(code) > 0 and code = upper(trim(code))),
  brand        text not null check (length(trim(brand)) > 0),
  model        text not null check (length(trim(model)) > 0),
  status       public.bike_status not null default 'available',
  hourly_rate  numeric(10, 2) not null check (hourly_rate > 0),
  branch_id    uuid not null references public.branches (id),
  is_active    boolean not null default true,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);
create index bikes_branch_id_idx on public.bikes (branch_id);

-- Clientes: se comparten entre sucursales y se buscan por teléfono o DPI.
create table public.customers (
  id           uuid primary key default gen_random_uuid(),
  full_name    text not null check (length(trim(full_name)) > 0),
  phone        text not null unique,
  document_id  text unique,          -- DPI (opcional)
  email        text,
  created_at   timestamptz not null default now()
);

-- Rentas. La tarifa se copia al iniciar para que un cambio de precio
-- posterior no altere las rentas en curso.
create table public.rentals (
  id           uuid primary key default gen_random_uuid(),
  bike_id      uuid not null references public.bikes (id),
  customer_id  uuid not null references public.customers (id),
  branch_id    uuid not null references public.branches (id),
  started_by   uuid not null references public.profiles (id),
  finished_by  uuid references public.profiles (id),
  hourly_rate  numeric(10, 2) not null,
  started_at   timestamptz not null default now(),
  ended_at     timestamptz,
  total_price  numeric(10, 2),
  status       public.rental_status not null default 'active',
  constraint rentals_status_consistency check (
    (status = 'active'   and ended_at is null     and total_price is null)
    or
    (status = 'finished' and ended_at is not null and total_price is not null)
  )
);
-- Garantía a nivel de base de datos: una bici solo puede tener una renta activa.
create unique index rentals_one_active_per_bike
  on public.rentals (bike_id) where status = 'active';
create index rentals_branch_status_idx on public.rentals (branch_id, status);
create index rentals_customer_id_idx on public.rentals (customer_id);


-- ---------------------------------------------------------------------
-- 3. Funciones auxiliares y triggers
-- ---------------------------------------------------------------------

-- ¿El usuario actual es un administrador activo?
-- SECURITY DEFINER evita recursión infinita al usarse dentro de las
-- políticas RLS de `profiles`.
create or replace function public.is_admin()
returns boolean
language sql stable security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin' and is_active
  );
$$;

-- Sucursal del usuario actual (null si no tiene o está inactivo).
create or replace function public.current_branch_id()
returns uuid
language sql stable security definer
set search_path = ''
as $$
  select branch_id from public.profiles
  where id = auth.uid() and is_active;
$$;

-- ¿El usuario actual es un empleado o admin activo?
create or replace function public.is_active_user()
returns boolean
language sql stable security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.profiles where id = auth.uid() and is_active
  );
$$;

-- Crea el perfil cuando se registra un usuario en Supabase Auth.
-- Por seguridad SIEMPRE nace como 'employee' sin sucursal; solo un
-- administrador puede cambiar su rol o asignarle sucursal.
create or replace function public.handle_new_user()
returns trigger
language plpgsql security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, full_name, email)
  values (
    new.id,
    coalesce(
      nullif(trim(new.raw_user_meta_data ->> 'full_name'), ''),
      split_part(new.email, '@', 1)
    ),
    new.email
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Mantiene bikes.updated_at al día.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger bikes_set_updated_at
  before update on public.bikes
  for each row execute function public.set_updated_at();

-- Protege la consistencia entre bicicletas y rentas:
--   · El estado 'rented' solo lo asignan start_rental / finish_rental.
--   · Una bici con renta activa no puede cambiar de estado, de sucursal
--     ni desactivarse hasta que se finalice la renta.
create or replace function public.check_bike_rental_consistency()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_has_active_rental boolean;
begin
  if tg_op = 'INSERT' then
    if new.status = 'rented' then
      raise exception 'Una bicicleta nueva no puede crearse en estado "en renta".'
        using errcode = 'P0001';
    end if;
    return new;
  end if;

  if new.status is not distinct from old.status
     and new.branch_id is not distinct from old.branch_id
     and new.is_active is not distinct from old.is_active then
    return new;
  end if;

  select exists (
    select 1 from public.rentals where bike_id = new.id and status = 'active'
  ) into v_has_active_rental;

  if v_has_active_rental
     and (new.status <> 'rented'
          or new.branch_id is distinct from old.branch_id
          or not new.is_active) then
    raise exception 'La bicicleta % tiene una renta activa. Finalízala primero.', new.code
      using errcode = 'P0001';
  end if;

  if not v_has_active_rental and new.status = 'rented' then
    raise exception 'El estado "en renta" solo se asigna al iniciar una renta.'
      using errcode = 'P0001';
  end if;

  return new;
end;
$$;

create trigger bikes_check_rental_consistency
  before insert or update on public.bikes
  for each row execute function public.check_bike_rental_consistency();


-- ---------------------------------------------------------------------
-- 4. Row Level Security
--
-- Regla general:
--   · admin    → ve y administra todo.
--   · employee → solo ve datos de su sucursal.
--   · Las rentas NO se insertan ni actualizan directamente: solo mediante
--     las funciones start_rental / finish_rental.
-- ---------------------------------------------------------------------
alter table public.branches  enable row level security;
alter table public.profiles  enable row level security;
alter table public.bikes     enable row level security;
alter table public.customers enable row level security;
alter table public.rentals   enable row level security;

-- branches
create policy "branches: usuarios activos pueden leer"
  on public.branches for select to authenticated
  using (public.is_active_user());
create policy "branches: admin crea"
  on public.branches for insert to authenticated
  with check (public.is_admin());
create policy "branches: admin edita"
  on public.branches for update to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- profiles
create policy "profiles: propio, misma sucursal o admin"
  on public.profiles for select to authenticated
  using (
    id = (select auth.uid())
    or public.is_admin()
    or branch_id = public.current_branch_id()
  );
create policy "profiles: admin edita"
  on public.profiles for update to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- bikes
create policy "bikes: su sucursal o admin"
  on public.bikes for select to authenticated
  using (public.is_admin() or branch_id = public.current_branch_id());
create policy "bikes: admin crea"
  on public.bikes for insert to authenticated
  with check (public.is_admin());
create policy "bikes: admin edita"
  on public.bikes for update to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- customers (compartidos entre sucursales)
create policy "customers: usuarios activos leen"
  on public.customers for select to authenticated
  using (public.is_active_user());
create policy "customers: usuarios activos crean"
  on public.customers for insert to authenticated
  with check (public.is_active_user());
create policy "customers: usuarios activos editan"
  on public.customers for update to authenticated
  using (public.is_active_user()) with check (public.is_active_user());

-- rentals (solo lectura; escritura vía RPC)
create policy "rentals: su sucursal o admin"
  on public.rentals for select to authenticated
  using (public.is_admin() or branch_id = public.current_branch_id());


-- ---------------------------------------------------------------------
-- 5. Funciones de negocio (se llaman desde la app con supabase.rpc)
--
-- Se ejecutan en una sola transacción y bloquean la fila (`for update`),
-- así dos empleados no pueden rentar la misma bicicleta a la vez.
--
-- Códigos de error (la app los traduce a mensajes):
--   P0001 → regla de negocio  ·  P0002 → no encontrado  ·  42501 → sin permiso
-- ---------------------------------------------------------------------

create or replace function public.start_rental(
  p_bike_code   text,
  p_customer_id uuid
)
returns public.rentals
language plpgsql security definer
set search_path = ''
as $$
declare
  v_profile public.profiles;
  v_bike    public.bikes;
  v_code    text := upper(trim(p_bike_code));
  v_rental  public.rentals;
begin
  select * into v_profile
  from public.profiles
  where id = auth.uid() and is_active;
  if not found then
    raise exception 'Tu usuario no tiene permisos para rentar.'
      using errcode = '42501';
  end if;

  select * into v_bike
  from public.bikes
  where code = v_code and is_active
  for update;
  if not found then
    raise exception 'No existe una bicicleta con el código %.', v_code
      using errcode = 'P0002';
  end if;

  if v_profile.role <> 'admin'
     and v_bike.branch_id is distinct from v_profile.branch_id then
    raise exception 'La bicicleta % pertenece a otra sucursal.', v_code
      using errcode = '42501';
  end if;

  if v_bike.status <> 'available' then
    raise exception 'La bicicleta % no está disponible.', v_code
      using errcode = 'P0001';
  end if;

  if not exists (select 1 from public.customers where id = p_customer_id) then
    raise exception 'El cliente no existe.' using errcode = 'P0002';
  end if;

  insert into public.rentals (bike_id, customer_id, branch_id, started_by, hourly_rate)
  values (v_bike.id, p_customer_id, v_bike.branch_id, v_profile.id, v_bike.hourly_rate)
  returning * into v_rental;

  update public.bikes set status = 'rented' where id = v_bike.id;

  return v_rental;
end;
$$;

create or replace function public.finish_rental(p_rental_id uuid)
returns public.rentals
language plpgsql security definer
set search_path = ''
as $$
declare
  v_profile public.profiles;
  v_rental  public.rentals;
  v_now     timestamptz := now();
  v_hours   integer;
begin
  select * into v_profile
  from public.profiles
  where id = auth.uid() and is_active;
  if not found then
    raise exception 'Tu usuario no tiene permisos para finalizar rentas.'
      using errcode = '42501';
  end if;

  select * into v_rental
  from public.rentals
  where id = p_rental_id
  for update;
  if not found then
    raise exception 'La renta no existe.' using errcode = 'P0002';
  end if;

  if v_profile.role <> 'admin'
     and v_rental.branch_id is distinct from v_profile.branch_id then
    raise exception 'La renta pertenece a otra sucursal.' using errcode = '42501';
  end if;

  if v_rental.status <> 'active' then
    raise exception 'Esta renta ya fue finalizada.' using errcode = 'P0001';
  end if;

  -- Regla de cobro: por hora iniciada, mínimo 1 hora.
  v_hours := greatest(
    1,
    ceil(extract(epoch from (v_now - v_rental.started_at)) / 3600.0)::integer
  );

  update public.rentals
  set status      = 'finished',
      ended_at    = v_now,
      total_price = v_hours * v_rental.hourly_rate,
      finished_by = v_profile.id
  where id = v_rental.id
  returning * into v_rental;

  update public.bikes set status = 'available' where id = v_rental.bike_id;

  return v_rental;
end;
$$;

-- Solo usuarios autenticados pueden ejecutar las funciones de negocio.
revoke execute on function public.start_rental(text, uuid) from public, anon;
revoke execute on function public.finish_rental(uuid) from public, anon;
grant execute on function public.start_rental(text, uuid) to authenticated;
grant execute on function public.finish_rental(uuid) to authenticated;


-- ---------------------------------------------------------------------
-- 6. Vista con los datos de una renta listos para mostrar.
--
-- `security_invoker = true` hace que la vista respete el RLS de las
-- tablas (cada empleado solo ve las rentas de su sucursal).
-- ---------------------------------------------------------------------
create view public.rental_details
with (security_invoker = true)
as
select
  r.id,
  r.status,
  r.started_at,
  r.ended_at,
  r.hourly_rate,
  r.total_price,
  r.branch_id,
  br.name                       as branch_name,
  r.bike_id,
  coalesce(b.code, '—')                      as bike_code,
  coalesce(b.brand || ' ' || b.model, '—')   as bike_name,
  r.customer_id,
  c.full_name                   as customer_name,
  c.phone                       as customer_phone,
  c.email                       as customer_email,
  c.document_id                 as customer_document_id,
  coalesce(p.full_name, 'Empleado') as employee_name
from public.rentals r
left join public.bikes b  on b.id = r.bike_id
join public.customers c   on c.id = r.customer_id
join public.branches br   on br.id = r.branch_id
left join public.profiles p on p.id = r.started_by;
