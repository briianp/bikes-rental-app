import 'package:bikes_app/app/router/app_routes.dart';
import 'package:bikes_app/core/widgets/state_views.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Se muestra cuando la ruta no existe (por ejemplo, un enlace roto).
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key, required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Página no encontrada')),
      body: Center(
        child: EmptyView(
          icon: Icons.explore_off_outlined,
          message: 'La ruta "$location" no existe.',
          action: FilledButton(
            onPressed: () => context.go(AppRoutes.rentals),
            child: const Text('Ir al inicio'),
          ),
        ),
      ),
    );
  }
}
