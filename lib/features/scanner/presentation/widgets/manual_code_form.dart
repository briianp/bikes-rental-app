import 'package:bikes_app/core/utils/validators.dart';
import 'package:flutter/material.dart';

/// Permite escribir el código de la bicicleta cuando no hay cámara
/// (emulador, web, escritorio) o el QR está dañado.
class ManualCodeForm extends StatefulWidget {
  const ManualCodeForm({super.key, required this.onSubmit});

  final ValueChanged<String> onSubmit;

  @override
  State<ManualCodeForm> createState() => _ManualCodeFormState();
}

class _ManualCodeFormState extends State<ManualCodeForm> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.onSubmit(_controller.text.trim().toUpperCase());
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            key: const Key('manual_code_field'),
            controller: _controller,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.go,
            onFieldSubmitted: (_) => _submit(),
            validator: (value) =>
                Validators.requiredText(value, field: 'El código'),
            decoration: const InputDecoration(
              hintText: 'Código, por ejemplo BK-001',
              prefixIcon: Icon(Icons.keyboard_alt_outlined),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            key: const Key('manual_code_submit_button'),
            onPressed: _submit,
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }
}
