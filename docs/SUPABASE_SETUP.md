# Configurar Supabase

Guía para conectar la app a tu propio proyecto de Supabase (plan gratuito). Sin este paso, la app funciona en **modo demo** con datos en memoria.

## 1. Crear el proyecto

1. Entra a [supabase.com](https://supabase.com) y crea un proyecto nuevo (por ejemplo `bikes-app`).
2. En **Project Settings → API Keys** copia:
   - **Project URL** (`https://xxxx.supabase.co`)
   - **Publishable key** (`sb_publishable_...`). En proyectos antiguos se llama **anon key**; también sirve.

> Nunca pongas la **secret key** (`service_role`) en la app. Solo la usa la Edge Function, del lado del servidor.

## 2. Crear las tablas

En **SQL Editor → New query**:

1. Pega el contenido de `supabase/migrations/20261014000000_init.sql` y presiona **Run**. Esto crea:
   - las tablas `branches`, `profiles`, `bikes`, `customers` y `rentals`;
   - las políticas de seguridad (RLS) por rol y sucursal;
   - las funciones `start_rental` y `finish_rental`;
   - la vista `rental_details`.
2. En otra consulta, pega `supabase/seed.sql` y presiona **Run**. Esto agrega 2 sucursales, 8 bicicletas y 3 clientes de prueba.

## 3. Desactivar el registro público

En **Authentication → Sign In / Providers**, desactiva **Allow new users to sign up**. Así solo el administrador puede crear cuentas desde la app.

## 4. Crear el primer administrador

1. Ve a **Authentication → Users → Add user → Create new user**.
2. Escribe tu correo y una contraseña, y marca **Auto Confirm User**.
3. En el **SQL Editor**, conviértelo en administrador:

```sql
update public.profiles
set role = 'admin', full_name = 'Tu Nombre'
where email = 'tu-correo@ejemplo.com';
```

Cada usuario nuevo nace como `employee` sin sucursal. Solo un admin puede cambiar el rol o la sucursal de alguien.

## 5. Publicar la Edge Function `create-employee`

Esta función permite que el admin cree cuentas de empleados desde la app.

**Opción A: desde el Dashboard (más fácil)**

1. Ve a **Edge Functions → Deploy a new function → Via Editor**.
2. Ponle de nombre `create-employee`.
3. Pega el contenido de `supabase/functions/create-employee/index.ts` y presiona **Deploy**.

**Opción B: con la CLI**

```bash
npx supabase login
npx supabase link --project-ref TU_PROJECT_REF
npx supabase functions deploy create-employee
```

La función usa las variables `SUPABASE_URL`, `SUPABASE_ANON_KEY` y `SUPABASE_SERVICE_ROLE_KEY`, que Supabase inyecta automáticamente. Puedes verlas en **Edge Functions → Secrets**.

## 6. Conectar la app

1. Copia `env.example.json` como `env.json` (este archivo está en `.gitignore`) y llénalo:

```json
{
  "SUPABASE_URL": "https://xxxx.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "sb_publishable_xxxx"
}
```

2. Ejecuta la app con:

```bash
flutter run --dart-define-from-file=env.json
```

En VS Code puedes agregarlo a `.vscode/launch.json`:

```json
{
  "configurations": [
    {
      "name": "bikes_app (Supabase)",
      "request": "launch",
      "type": "dart",
      "args": ["--dart-define-from-file=env.json"]
    }
  ]
}
```

## 7. Primeros pasos en la app

1. Inicia sesión con tu usuario administrador.
2. Ve a **Perfil → Panel de administración → Empleados** y crea las cuentas de tus empleados, asignándoles una sucursal.
3. En **Bicicletas**, abre cada bici y toca **Ver código QR** para imprimir su etiqueta.
4. Con un empleado, escanea el QR: si la bici está libre se inicia la renta, y si está rentada se finaliza.

## ¿Cómo funciona la seguridad?

| Tabla | Empleado | Administrador |
| --- | --- | --- |
| `branches` | Lee | Lee y edita |
| `profiles` | Se lee a sí mismo y a su sucursal | Lee y edita todo |
| `bikes` | Lee las de su sucursal | Lee y edita todas |
| `customers` | Lee, crea y edita | Lee, crea y edita |
| `rentals` | Lee las de su sucursal | Lee todas |

Las rentas **nunca** se insertan ni se editan directamente: solo mediante `start_rental` y `finish_rental`. Esas funciones:

- validan permisos y disponibilidad;
- bloquean la fila de la bicicleta (`for update`) para que dos empleados no la renten al mismo tiempo;
- calculan el cobro en el servidor (por hora iniciada, mínimo 1 hora).

Además, un índice único impide que una bici tenga dos rentas activas, y un trigger impide cambiar a mano el estado de una bici rentada.
