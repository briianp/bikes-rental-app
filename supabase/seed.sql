-- =====================================================================
-- Datos de prueba. Ejecutar DESPUÉS de la migración inicial.
--
-- Los usuarios no se crean aquí: créalos en Authentication → Users
-- (ver docs/SUPABASE_SETUP.md) y luego asígnales rol y sucursal.
-- =====================================================================

insert into public.branches (id, name, address) values
  ('11111111-1111-4111-8111-111111111111', 'Sucursal Centro', '6a avenida 10-20, zona 1'),
  ('22222222-2222-4222-8222-222222222222', 'Sucursal Norte', 'Calzada Norte 45-10, zona 17')
on conflict (id) do nothing;

insert into public.bikes (code, brand, model, status, hourly_rate, branch_id) values
  ('BK-001', 'Trek',        'Marlin 5',    'available',   25, '11111111-1111-4111-8111-111111111111'),
  ('BK-002', 'Giant',       'Talon 3',     'available',   25, '11111111-1111-4111-8111-111111111111'),
  ('BK-003', 'Specialized', 'Rockhopper',  'available',   30, '11111111-1111-4111-8111-111111111111'),
  ('BK-004', 'Cannondale',  'Trail 8',     'maintenance', 25, '11111111-1111-4111-8111-111111111111'),
  ('BK-005', 'Scott',       'Aspect 970',  'available',   20, '22222222-2222-4222-8222-222222222222'),
  ('BK-006', 'Merida',      'Big Nine',    'available',   20, '22222222-2222-4222-8222-222222222222'),
  ('BK-007', 'GW',          'Lynx',        'available',   15, '22222222-2222-4222-8222-222222222222'),
  ('BK-008', 'Oxford',      'Orion',       'available',   15, '22222222-2222-4222-8222-222222222222')
on conflict (code) do nothing;

insert into public.customers (full_name, phone, document_id, email) values
  ('Ana López',           '55123456', '2456789010101', 'ana.lopez@correo.com'),
  ('Carlos Méndez',       '44781234', null,            null),
  ('María Fernanda Ruiz', '30567890', '3012456780101', 'mafer.ruiz@correo.com')
on conflict (phone) do nothing;
