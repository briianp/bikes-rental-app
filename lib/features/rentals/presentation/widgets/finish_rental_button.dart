import 'package:bikes_app/core/error/failures.dart';
import 'package:bikes_app/core/theme/app_colors.dart';
import 'package:bikes_app/core/utils/formatters.dart';
import 'package:bikes_app/core/widgets/primary_button.dart';
import 'package:bikes_app/features/rentals/domain/entities/rental.dart';
import 'package:bikes_app/features/rentals/presentation/providers/rental_controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Botón "Finalizar renta" con diálogo de confirmación.
///
/// [onFinished] recibe la renta ya finalizada (con el total del servidor).
class FinishRentalButton extends ConsumerWidget {
  const FinishRentalButton({
    super.key,
    required this.rental,
    this.onFinished,
  });

  final Rental rental;
  final ValueChanged<Rental>? onFinished;

  Future<void> _confirmAndFinish(BuildContext context, WidgetRef ref) async {
    final estimatedTotal = rental.calculateTotal(DateTime.now());
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Finalizar renta?'),
        content: Text(
          'Bicicleta ${rental.bikeCode} · ${rental.customerName}\n'
          'Total a cobrar: ${Formatters.currency(estimatedTotal)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            key: const Key('confirm_finish_rental_button'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final finished = await ref
        .read(finishRentalControllerProvider.notifier)
        .finish(rental.id);
    if (finished == null || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Renta finalizada. Total: '
          '${Formatters.currency(finished.totalPrice ?? 0)}',
        ),
        backgroundColor: AppColors.success,
      ),
    );
    onFinished?.call(finished);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(finishRentalControllerProvider, (previous, next) {
      if (next case AsyncError(:final error)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessageOf(error)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });
    final isLoading = ref.watch(finishRentalControllerProvider).isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrimaryButton(
          key: const Key('finish_rental_button'),
          label: 'Finalizar renta',
          icon: Icons.flag_rounded,
          isLoading: isLoading,
          onPressed: () => _confirmAndFinish(context, ref),
        ),
        const SizedBox(height: 8),
        const Text(
          'Se cobra por hora iniciada (mínimo 1 hora).',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      ],
    );
  }
}
