import 'package:bikes_app/core/error/failures.dart';
import 'package:bikes_app/core/widgets/state_views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pinta los tres estados de un [AsyncValue] de Riverpod:
/// cargando, error (con reintentar) y datos.
///
/// ```dart
/// AsyncValueView(
///   value: ref.watch(activeRentalsProvider),
///   onRetry: () => ref.invalidate(activeRentalsProvider),
///   data: (rentals) => RentalsList(rentals: rentals),
/// )
/// ```
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => const LoadingView(),
      error: (error, _) =>
          ErrorView(message: errorMessageOf(error), onRetry: onRetry),
    );
  }
}
