# Bikes App 🚲

App móvil en **Flutter** para controlar la renta de bicicletas en varias sucursales. El empleado **escanea el QR** de una bicicleta: si está libre, inicia la renta con los datos del cliente; si está rentada, la finaliza y la app calcula el cobro. Los administradores gestionan el catálogo de bicicletas, las sucursales y los empleados.

> Funciona en dos modos:
> - **Demo:** sin configurar nada, con datos en memoria.
> - **Supabase:** con tu propio backend (ver [docs/SUPABASE_SETUP.md](docs/SUPABASE_SETUP.md)).

## Funcionalidades

**Empleado**
- **Escanear QR:** abre la acción correcta según el estado de la bici (iniciar renta, finalizarla o avisar si está en mantenimiento). También se puede escribir el código a mano.
- **Clientes:** se buscan por teléfono, DPI o nombre, o se registran en el momento.
- **Rentas activas:** tiempo transcurrido y total estimado; detalle con botón para finalizar.
- **Historial** de rentas finalizadas con el total cobrado.
- **Bicicletas** de su sucursal, con filtros por estado.

**Administrador**
- **Catálogo de bicicletas** de todas las sucursales: crear, editar tarifa, estado o sucursal, dar de baja y **ver el código QR** para imprimirlo.
- **Sucursales:** crear y editar.
- **Empleados:** crear cuentas, asignar rol y sucursal, desactivar.

**Reglas de negocio**
- Se cobra por **hora iniciada** (mínimo 1 hora) con la tarifa de cada bicicleta. La tarifa se guarda al iniciar la renta.
- Una bici no puede tener dos rentas activas. El servidor lo valida dentro de una transacción.
- Cada empleado solo ve los datos de **su sucursal** (Row Level Security).

### Cuentas del modo demo

| Rol | Correo | Contraseña |
| --- | --- | --- |
| Empleado (Sucursal Centro) | `demo@bikes.com` | `123456` |
| Administrador | `admin@bikes.com` | `123456` |

En el login hay botones para entrar con cada una. Códigos de prueba en la Sucursal Centro: `BK-001` y `BK-003` (libres), `BK-002` (en renta).

## Tecnologías

| Área | Herramienta |
| --- | --- |
| Framework | Flutter 3.35 · Dart 3.9 |
| Estado e inyección de dependencias | [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) 3 |
| Navegación | [go_router](https://pub.dev/packages/go_router): `StatefulShellRoute` y guards con `redirect` |
| Backend | [Supabase](https://supabase.com): PostgreSQL, Auth, RLS, funciones RPC y Edge Functions |
| QR | [qr_code_scanner_plus](https://pub.dev/packages/qr_code_scanner_plus) para leer y [qr_flutter](https://pub.dev/packages/qr_flutter) para generar |
| Tests | `flutter_test` (unitarios, de providers y de widgets) |

## Arquitectura

**Clean Architecture** organizada por *features*. Las dependencias siempre apuntan hacia el dominio:

```text
presentation  ──►  domain  ◄──  data
(páginas,          (entidades,      (modelos JSON,
 widgets,           contratos,       data sources Supabase / demo,
 providers)         casos de uso)    repositorios)
```

- **domain:** Dart puro con las reglas de negocio. Ejemplos: `ScanBike` decide qué hacer con un QR; `SignIn` bloquea a usuarios inactivos o sin sucursal.
- **data:** cada feature tiene dos *data sources* con la misma interfaz, uno de **Supabase** y otro **falso** (modo demo y tests). Los errores técnicos se convierten en `Failure` de dominio.
- **presentation:** pantallas y providers de Riverpod.
- **`<feature>_dependencies.dart`:** conecta las capas y elige el data source según la configuración.

```text
lib/
├── main.dart                    # Inicializa Supabase (si hay credenciales) y la sesión
├── app/                         # MaterialApp.router, rutas, guards, HomeShell
├── core/                        # config, errores, tema, utilidades, widgets comunes
└── features/
    ├── auth/        # login, sesión, roles
    ├── rentals/     # escanear → iniciar / finalizar, rentas activas, historial
    ├── customers/   # búsqueda y registro de clientes
    ├── bikes/       # catálogo, formulario admin, QR
    ├── branches/    # sucursales (admin)
    ├── employees/   # empleados (admin)
    ├── scanner/     # cámara QR y código manual
    ├── admin/       # menú de administración
    └── profile/
supabase/
├── migrations/      # esquema, RLS, triggers, funciones RPC y vista
├── seed.sql         # datos de prueba
└── functions/create-employee/   # Edge Function (crea cuentas)
```

### Navegación

```text
/login
/bike/:bikeCode                   (resultado del escaneo, pantalla completa)
/admin ─ /admin/bikes[/new|/:id] ─ /admin/branches ─ /admin/employees[/new|/:id]
┌─ HomeShell (pestañas) ─────────────────────────────┐
│ /rentals ── /rentals/history ── /rentals/:rentalId │
│ /bikes                                             │
│ /scan ──── /scan/camera                            │
│ /profile                                           │
└────────────────────────────────────────────────────┘
```

Guards en `redirect`:
1. Sin sesión → `/login`.
2. Con sesión no se puede volver al login.
3. `/admin/*` es solo para administradores.

## Cómo ejecutar

Requisitos: Flutter 3.35 o superior (el proyecto incluye `.fvmrc` para [FVM](https://fvm.app)).

```bash
flutter pub get

# Modo demo
flutter run

# Con Supabase (ver docs/SUPABASE_SETUP.md)
flutter run --dart-define-from-file=env.json
```

## Tests

```bash
flutter analyze
flutter test
```

| Archivo | Qué prueba |
| --- | --- |
| `test/core/validators_test.dart` | Validaciones (correo, teléfono, DPI, tarifa) y formatos |
| `test/features/rentals/rental_test.dart` | Regla de cobro por hora iniciada |
| `test/features/rentals/rental_use_cases_test.dart` | Iniciar, finalizar y escanear; permisos por sucursal |
| `test/features/auth/login_controller_test.dart` | Login, roles, usuario inactivo o sin sucursal, logout, restaurar sesión |
| `test/widget/app_flow_test.dart` | Flujos completos de la UI: empleado y administrador |

Las reglas SQL (`supabase/migrations`) se probaron contra PostgreSQL 16: permisos por sucursal, transacciones de renta, errores y cobro.

## Próximos pasos

- Actualizar en tiempo real la lista de rentas con Supabase Realtime.
- Migrar el escáner a `mobile_scanner`.
- Reportes de ingresos por sucursal y por día.
- Internacionalización (`flutter_localizations`).

## Créditos

Ilustración del login: [Storyset](https://storyset.com) (Freepik).
