import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class _Destination {
  const _Destination(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const _destinations = [
  _Destination('Rentas', Icons.directions_bike_outlined, Icons.directions_bike_rounded),
  _Destination('Bicicletas', Icons.pedal_bike_outlined, Icons.pedal_bike_rounded),
  _Destination('Escanear', Icons.qr_code_scanner_outlined, Icons.qr_code_scanner_rounded),
  _Destination('Perfil', Icons.person_outline_rounded, Icons.person_rounded),
];

/// Estructura principal con navegación por pestañas.
///
/// [navigationShell] lo crea go_router (`StatefulShellRoute.indexedStack`):
/// cada pestaña tiene su propio historial y conserva su estado al cambiar
/// de una a otra.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// Ancho a partir del cual se usa un menú lateral en lugar de la barra inferior.
  static const double _railBreakpoint = 840;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      // Tocar la pestaña activa regresa a su pantalla inicial.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= _railBreakpoint;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final destination in _destinations)
                  NavigationRailDestination(
                    icon: Icon(destination.icon),
                    selectedIcon: Icon(destination.selectedIcon),
                    label: Text(destination.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: [
          for (final destination in _destinations)
            NavigationDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              label: destination.label,
            ),
        ],
      ),
    );
  }
}
