import 'package:bikes_app/core/error/failures.dart';
import 'package:bikes_app/core/theme/app_colors.dart';
import 'package:bikes_app/core/utils/validators.dart';
import 'package:bikes_app/core/widgets/async_value_view.dart';
import 'package:bikes_app/core/widgets/primary_button.dart';
import 'package:bikes_app/core/widgets/responsive_center.dart';
import 'package:bikes_app/core/widgets/state_views.dart';
import 'package:bikes_app/features/bikes/domain/entities/bike.dart';
import 'package:bikes_app/features/bikes/presentation/providers/bikes_providers.dart';
import 'package:bikes_app/features/bikes/presentation/widgets/bike_qr_dialog.dart';
import 'package:bikes_app/features/bikes/presentation/widgets/bike_status_ui.dart';
import 'package:bikes_app/features/branches/domain/entities/branch.dart';
import 'package:bikes_app/features/branches/presentation/providers/branches_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Crear (sin [bikeId]) o editar una bicicleta. Solo admin.
class BikeFormPage extends ConsumerWidget {
  const BikeFormPage({super.key, this.bikeId});

  final String? bikeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = bikeId;
    final branches = ref.watch(branchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(id == null ? 'Nueva bicicleta' : 'Editar bicicleta'),
      ),
      body: ResponsiveCenter(
        child: AsyncValueView(
          value: branches,
          onRetry: () => ref.invalidate(branchesProvider),
          data: (branchList) {
            if (id == null) return _BikeForm(branches: branchList);
            return AsyncValueView(
              value: ref.watch(bikeByIdProvider(id)),
              onRetry: () => ref.invalidate(bikeByIdProvider(id)),
              data: (bike) => bike == null
                  ? const EmptyView(message: 'La bicicleta no existe.')
                  : _BikeForm(branches: branchList, bike: bike),
            );
          },
        ),
      ),
    );
  }
}

class _BikeForm extends ConsumerStatefulWidget {
  const _BikeForm({required this.branches, this.bike});

  final List<Branch> branches;
  final Bike? bike;

  @override
  ConsumerState<_BikeForm> createState() => _BikeFormState();
}

class _BikeFormState extends ConsumerState<_BikeForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  late final TextEditingController _brandController;
  late final TextEditingController _modelController;
  late final TextEditingController _rateController;
  String? _branchId;
  late BikeStatus _status;
  late bool _isActive;

  bool get _isRented => widget.bike?.status == BikeStatus.rented;

  @override
  void initState() {
    super.initState();
    final bike = widget.bike;
    _codeController = TextEditingController(text: bike?.code);
    _brandController = TextEditingController(text: bike?.brand);
    _modelController = TextEditingController(text: bike?.model);
    _rateController = TextEditingController(
      text: bike?.hourlyRate.toStringAsFixed(2),
    );
    _branchId = bike?.branchId;
    _status = bike?.status ?? BikeStatus.available;
    _isActive = bike?.isActive ?? true;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final saved = await ref
        .read(saveBikeControllerProvider.notifier)
        .save(
          BikeDraft(
            code: _codeController.text,
            brand: _brandController.text,
            model: _modelController.text,
            hourlyRate: double.parse(
              _rateController.text.trim().replaceAll(',', '.'),
            ),
            branchId: _branchId!,
            status: _status,
            isActive: _isActive,
          ),
          existing: widget.bike,
        );
    if (saved == null || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bicicleta ${saved.code} guardada'),
        backgroundColor: AppColors.success,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(saveBikeControllerProvider, (previous, next) {
      if (next case AsyncError(:final error)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessageOf(error)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });
    final isLoading = ref.watch(saveBikeControllerProvider).isLoading;
    final bike = widget.bike;
    // Se muestran las sucursales activas y, si aplica, la actual de la bici.
    final branchOptions = widget.branches
        .where((b) => b.isActive || b.id == _branchId)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (bike != null) ...[
              OutlinedButton.icon(
                key: const Key('show_qr_button'),
                onPressed: () => showBikeQrDialog(context, bike),
                icon: const Icon(Icons.qr_code_2_rounded),
                label: const Text('Ver código QR'),
              ),
              const SizedBox(height: 20),
            ],
            TextFormField(
              key: const Key('bike_code_field'),
              controller: _codeController,
              // El código va impreso en el QR: no se cambia al editar.
              readOnly: bike != null,
              textCapitalization: TextCapitalization.characters,
              validator: (value) =>
                  Validators.requiredText(value, field: 'El código'),
              decoration: const InputDecoration(
                labelText: 'Código (QR)',
                hintText: 'BK-009',
                prefixIcon: Icon(Icons.qr_code_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('bike_brand_field'),
              controller: _brandController,
              textCapitalization: TextCapitalization.words,
              validator: (value) =>
                  Validators.requiredText(value, field: 'La marca'),
              decoration: const InputDecoration(
                labelText: 'Marca',
                prefixIcon: Icon(Icons.sell_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('bike_model_field'),
              controller: _modelController,
              validator: (value) =>
                  Validators.requiredText(value, field: 'El modelo'),
              decoration: const InputDecoration(
                labelText: 'Modelo',
                prefixIcon: Icon(Icons.pedal_bike_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('bike_rate_field'),
              controller: _rateController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) =>
                  Validators.positiveNumber(value, field: 'La tarifa'),
              decoration: const InputDecoration(
                labelText: 'Tarifa por hora (Q)',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: const Key('bike_branch_field'),
              initialValue: _branchId,
              isExpanded: true,
              items: [
                for (final branch in branchOptions)
                  DropdownMenuItem(value: branch.id, child: Text(branch.name)),
              ],
              onChanged: _isRented
                  ? null
                  : (value) => setState(() => _branchId = value),
              validator: (value) =>
                  value == null ? 'Selecciona una sucursal' : null,
              decoration: const InputDecoration(
                labelText: 'Sucursal',
                prefixIcon: Icon(Icons.store_mall_directory_outlined),
              ),
            ),
            const SizedBox(height: 12),
            if (_isRented)
              const Card(
                child: ListTile(
                  leading: Icon(Icons.lock_clock_outlined),
                  title: Text('En renta'),
                  subtitle: Text(
                    'Finaliza la renta para cambiar su estado o sucursal.',
                  ),
                ),
              )
            else
              DropdownButtonFormField<BikeStatus>(
                key: const Key('bike_status_field'),
                initialValue: _status,
                isExpanded: true,
                items: [
                  for (final status in [
                    BikeStatus.available,
                    BikeStatus.maintenance,
                  ])
                    DropdownMenuItem(value: status, child: Text(status.label)),
                ],
                onChanged: (value) =>
                    setState(() => _status = value ?? BikeStatus.available),
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  prefixIcon: Icon(Icons.build_outlined),
                ),
              ),
            if (bike != null) ...[
              const SizedBox(height: 8),
              SwitchListTile(
                value: _isActive,
                onChanged: _isRented
                    ? null
                    : (value) => setState(() => _isActive = value),
                title: const Text('Activa'),
                subtitle: const Text(
                  'Desactívala para darla de baja sin perder su historial.',
                ),
              ),
            ],
            const SizedBox(height: 24),
            PrimaryButton(
              key: const Key('save_bike_button'),
              label: 'Guardar',
              icon: Icons.save_outlined,
              isLoading: isLoading,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
