import 'package:bikes_app/app/router/app_routes.dart';
import 'package:bikes_app/app/router/not_found_page.dart';
import 'package:bikes_app/app/shell/home_shell.dart';
import 'package:bikes_app/features/admin/presentation/pages/admin_home_page.dart';
import 'package:bikes_app/features/auth/domain/entities/app_user.dart';
import 'package:bikes_app/features/auth/presentation/pages/login_page.dart';
import 'package:bikes_app/features/auth/presentation/providers/session_provider.dart';
import 'package:bikes_app/features/bikes/presentation/pages/admin_bikes_page.dart';
import 'package:bikes_app/features/bikes/presentation/pages/bike_form_page.dart';
import 'package:bikes_app/features/bikes/presentation/pages/bikes_page.dart';
import 'package:bikes_app/features/branches/presentation/pages/branches_page.dart';
import 'package:bikes_app/features/employees/presentation/pages/employee_form_page.dart';
import 'package:bikes_app/features/employees/presentation/pages/employees_page.dart';
import 'package:bikes_app/features/profile/presentation/pages/profile_page.dart';
import 'package:bikes_app/features/rentals/presentation/pages/bike_action_page.dart';
import 'package:bikes_app/features/rentals/presentation/pages/rental_detail_page.dart';
import 'package:bikes_app/features/rentals/presentation/pages/rental_history_page.dart';
import 'package:bikes_app/features/rentals/presentation/pages/rentals_page.dart';
import 'package:bikes_app/features/scanner/presentation/pages/qr_camera_page.dart';
import 'package:bikes_app/features/scanner/presentation/pages/scanner_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Router de la app, expuesto como provider para poder leer la sesión.
///
/// Mapa de navegación:
///
/// ```text
/// /login
/// /bike/:bikeCode                  (iniciar o finalizar renta)
/// /admin ── /admin/bikes ── /admin/bikes/new | /admin/bikes/:bikeId
///        ── /admin/branches
///        ── /admin/employees ── /admin/employees/new | /:employeeId
/// ┌─ HomeShell (barra inferior) ─────────────────────────┐
/// │ /rentals ── /rentals/history ── /rentals/:rentalId   │
/// │ /bikes                                               │
/// │ /scan ──── /scan/camera        (pantalla completa)   │
/// │ /profile                                             │
/// └──────────────────────────────────────────────────────┘
/// ```
final routerProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  // go_router no conoce Riverpod. Este ValueNotifier hace de puente:
  // cuando cambia la sesión, el router vuelve a ejecutar `redirect`.
  final session = ValueNotifier<AppUser?>(ref.read(sessionProvider));
  ref.listen<AppUser?>(sessionProvider, (_, user) => session.value = user);

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.rentals,
    refreshListenable: session,

    // Guards: se ejecutan antes de cada navegación.
    redirect: (context, state) {
      final user = session.value;
      final location = state.matchedLocation;
      final isOnLogin = location == AppRoutes.login;

      // 1. Sin sesión → login.
      if (user == null) return isOnLogin ? null : AppRoutes.login;
      // 2. Con sesión no tiene sentido ver el login.
      if (isOnLogin) return AppRoutes.rentals;
      // 3. El panel de administración es solo para admins.
      if (location.startsWith(AppRoutes.admin) && !user.isAdmin) {
        return AppRoutes.rentals;
      }
      return null; // Sin cambios.
    },

    errorBuilder: (context, state) =>
        NotFoundPage(location: state.uri.toString()),

    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),

      // Fuera del shell: se abren a pantalla completa, sin barra inferior.
      GoRoute(
        path: AppRoutes.bikeActionPattern,
        builder: (context, state) =>
            BikeActionPage(bikeCode: state.pathParameters['bikeCode']!),
      ),
      GoRoute(
        path: AppRoutes.admin,
        builder: (context, state) => const AdminHomePage(),
        routes: [
          GoRoute(
            path: 'bikes',
            builder: (context, state) => const AdminBikesPage(),
            routes: [
              // Las rutas fijas van antes que las de parámetros.
              GoRoute(
                path: 'new',
                builder: (context, state) => const BikeFormPage(),
              ),
              GoRoute(
                path: ':bikeId',
                builder: (context, state) =>
                    BikeFormPage(bikeId: state.pathParameters['bikeId']),
              ),
            ],
          ),
          GoRoute(
            path: 'branches',
            builder: (context, state) => const BranchesPage(),
          ),
          GoRoute(
            path: 'employees',
            builder: (context, state) => const EmployeesPage(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const EmployeeFormPage(),
              ),
              GoRoute(
                path: ':employeeId',
                builder: (context, state) => EmployeeFormPage(
                  employeeId: state.pathParameters['employeeId'],
                ),
              ),
            ],
          ),
        ],
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.rentals,
                builder: (context, state) => const RentalsPage(),
                routes: [
                  GoRoute(
                    path: 'history',
                    builder: (context, state) => const RentalHistoryPage(),
                  ),
                  GoRoute(
                    path: ':rentalId',
                    builder: (context, state) => RentalDetailPage(
                      rentalId: state.pathParameters['rentalId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.bikes,
                builder: (context, state) => const BikesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.scanner,
                builder: (context, state) => const ScannerPage(),
                routes: [
                  GoRoute(
                    path: 'camera',
                    // Se apila en el navegador raíz para cubrir la barra inferior.
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const QrCameraPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  ref.onDispose(() {
    session.dispose();
    router.dispose();
  });

  return router;
});
