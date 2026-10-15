import 'package:bikes_app/core/error/failures.dart';
import 'package:bikes_app/core/theme/app_colors.dart';
import 'package:bikes_app/core/utils/validators.dart';
import 'package:bikes_app/core/widgets/primary_button.dart';
import 'package:bikes_app/core/widgets/state_views.dart';
import 'package:bikes_app/features/customers/domain/entities/customer.dart';
import 'package:bikes_app/features/customers/presentation/providers/customers_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Permite buscar un cliente existente (teléfono, DPI o nombre) o
/// registrar uno nuevo. Avisa con [onChanged] cuál quedó seleccionado.
class CustomerPicker extends ConsumerStatefulWidget {
  const CustomerPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final Customer? selected;
  final ValueChanged<Customer?> onChanged;

  @override
  ConsumerState<CustomerPicker> createState() => _CustomerPickerState();
}

class _CustomerPickerState extends ConsumerState<CustomerPicker> {
  final _searchController = TextEditingController();
  String _query = '';
  bool _showNewCustomerForm = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    FocusScope.of(context).unfocus();
    setState(() => _query = _searchController.text.trim());
  }

  void _select(Customer customer) {
    setState(() {
      _showNewCustomerForm = false;
      _query = '';
      _searchController.clear();
    });
    widget.onChanged(customer);
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    if (selected != null) {
      return _SelectedCustomerCard(
        customer: selected,
        onChange: () => widget.onChanged(null),
      );
    }

    if (_showNewCustomerForm) {
      return _NewCustomerForm(
        initialQuery: _query,
        onCreated: _select,
        onCancel: () => setState(() => _showNewCustomerForm = false),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const Key('customer_search_field'),
          controller: _searchController,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _search(),
          decoration: InputDecoration(
            hintText: 'Buscar por teléfono, DPI o nombre',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: IconButton(
              key: const Key('customer_search_button'),
              tooltip: 'Buscar',
              icon: const Icon(Icons.arrow_forward_rounded),
              onPressed: _search,
            ),
          ),
        ),
        if (_query.length >= 2) _SearchResults(query: _query, onSelect: _select),
        const SizedBox(height: 8),
        TextButton.icon(
          key: const Key('new_customer_button'),
          onPressed: () => setState(() => _showNewCustomerForm = true),
          icon: const Icon(Icons.person_add_alt_1_outlined),
          label: const Text('Registrar cliente nuevo'),
        ),
      ],
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.query, required this.onSelect});

  final String query;
  final ValueChanged<Customer> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(customerSearchProvider(query));
    return results.when(
      loading: () => const LoadingView(),
      error: (error, _) => ErrorView(
        message: errorMessageOf(error),
        onRetry: () => ref.invalidate(customerSearchProvider(query)),
      ),
      data: (customers) {
        if (customers.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'No encontramos clientes. Puedes registrarlo como nuevo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Card(
            child: Column(
              children: [
                for (final customer in customers)
                  ListTile(
                    leading: const Icon(Icons.person_outline_rounded),
                    title: Text(customer.fullName),
                    subtitle: Text(
                      [
                        customer.phone,
                        if (customer.documentId != null)
                          'DPI ${customer.documentId}',
                      ].join(' · '),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => onSelect(customer),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SelectedCustomerCard extends StatelessWidget {
  const _SelectedCustomerCard({required this.customer, required this.onChange});

  final Customer customer;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        leading: const CircleAvatar(
          backgroundColor: AppColors.accent,
          child: Icon(Icons.person_rounded, color: Colors.white),
        ),
        title: Text(
          customer.fullName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          [
            customer.phone,
            if (customer.documentId != null) 'DPI ${customer.documentId}',
          ].join(' · '),
        ),
        trailing: TextButton(onPressed: onChange, child: const Text('Cambiar')),
      ),
    );
  }
}

class _NewCustomerForm extends ConsumerStatefulWidget {
  const _NewCustomerForm({
    required this.initialQuery,
    required this.onCreated,
    required this.onCancel,
  });

  final String initialQuery;
  final ValueChanged<Customer> onCreated;
  final VoidCallback onCancel;

  @override
  ConsumerState<_NewCustomerForm> createState() => _NewCustomerFormState();
}

class _NewCustomerFormState extends ConsumerState<_NewCustomerForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _documentController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Si buscó un número, lo usamos como teléfono para no escribirlo dos veces.
    final digits = Validators.digitsOnly(widget.initialQuery);
    if (digits.length >= 8 && digits.length <= 15) {
      _phoneController.text = digits;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _documentController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final customer = await ref
        .read(createCustomerControllerProvider.notifier)
        .create(
          NewCustomer(
            fullName: _nameController.text,
            phone: _phoneController.text,
            documentId: _documentController.text,
            email: _emailController.text,
          ),
        );
    if (customer != null && mounted) widget.onCreated(customer);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(createCustomerControllerProvider, (previous, next) {
      if (next case AsyncError(:final error)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessageOf(error)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });
    final isLoading = ref.watch(createCustomerControllerProvider).isLoading;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            key: const Key('customer_name_field'),
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            validator: (value) =>
                Validators.requiredText(value, field: 'El nombre'),
            decoration: const InputDecoration(
              hintText: 'Nombre completo',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: const Key('customer_phone_field'),
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            validator: Validators.phone,
            decoration: const InputDecoration(
              hintText: 'Teléfono',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: const Key('customer_document_field'),
            controller: _documentController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            validator: Validators.optionalDpi,
            decoration: const InputDecoration(
              hintText: 'DPI (opcional)',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: const Key('customer_email_field'),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: Validators.optionalEmail,
            decoration: const InputDecoration(
              hintText: 'Correo (opcional)',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            key: const Key('save_customer_button'),
            label: 'Guardar cliente',
            icon: Icons.save_outlined,
            isLoading: isLoading,
            onPressed: _save,
          ),
          TextButton(onPressed: widget.onCancel, child: const Text('Cancelar')),
        ],
      ),
    );
  }
}
