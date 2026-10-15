import 'package:bikes_app/core/error/failures.dart';
import 'package:bikes_app/core/theme/app_colors.dart';
import 'package:bikes_app/core/utils/validators.dart';
import 'package:bikes_app/core/widgets/async_value_view.dart';
import 'package:bikes_app/core/widgets/responsive_center.dart';
import 'package:bikes_app/core/widgets/state_views.dart';
import 'package:bikes_app/core/widgets/status_badge.dart';
import 'package:bikes_app/features/branches/domain/entities/branch.dart';
import 'package:bikes_app/features/branches/presentation/providers/branches_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Administración de sucursales (solo admin).
class BranchesPage extends ConsumerWidget {
  const BranchesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branches = ref.watch(branchesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sucursales')),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add_branch_button'),
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva'),
      ),
      body: ResponsiveCenter(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
          children: [
            AsyncValueView(
              value: branches,
              onRetry: () => ref.invalidate(branchesProvider),
              data: (items) {
                if (items.isEmpty) {
                  return const EmptyView(message: 'No hay sucursales.');
                }
                return Card(
                  child: Column(
                    children: [
                      for (final branch in items)
                        ListTile(
                          leading: const Icon(Icons.store_mall_directory_outlined),
                          title: Text(branch.name),
                          subtitle: branch.address == null
                              ? null
                              : Text(branch.address!),
                          trailing: branch.isActive
                              ? const Icon(Icons.edit_outlined)
                              : const StatusBadge(
                                  label: 'Inactiva',
                                  color: AppColors.textSecondary,
                                ),
                          onTap: () => _openForm(context, branch: branch),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openForm(BuildContext context, {Branch? branch}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _BranchFormSheet(branch: branch),
    );
  }
}

class _BranchFormSheet extends ConsumerStatefulWidget {
  const _BranchFormSheet({this.branch});

  final Branch? branch;

  @override
  ConsumerState<_BranchFormSheet> createState() => _BranchFormSheetState();
}

class _BranchFormSheetState extends ConsumerState<_BranchFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.branch?.name);
    _addressController = TextEditingController(text: widget.branch?.address);
    _isActive = widget.branch?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final saved = await ref
        .read(saveBranchControllerProvider.notifier)
        .save(
          BranchDraft(
            name: _nameController.text,
            address: _addressController.text,
            isActive: _isActive,
          ),
          id: widget.branch?.id,
        );
    if (saved && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(saveBranchControllerProvider, (previous, next) {
      if (next case AsyncError(:final error)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessageOf(error)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });
    final isLoading = ref.watch(saveBranchControllerProvider).isLoading;

    return Padding(
      // Sube el formulario cuando aparece el teclado.
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.branch == null ? 'Nueva sucursal' : 'Editar sucursal',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('branch_name_field'),
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              validator: (value) =>
                  Validators.requiredText(value, field: 'El nombre'),
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('branch_address_field'),
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Dirección (opcional)',
              ),
            ),
            if (widget.branch != null)
              SwitchListTile(
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
                title: const Text('Activa'),
              ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('save_branch_button'),
              onPressed: isLoading ? null : _save,
              child: Text(isLoading ? 'Guardando…' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
