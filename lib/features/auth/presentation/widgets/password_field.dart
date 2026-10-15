import 'package:bikes_app/core/utils/validators.dart';
import 'package:flutter/material.dart';

/// Campo de contraseña con botón para mostrar u ocultar el texto.
///
/// El estado "oculto/visible" es local de este widget, por eso basta con
/// un `StatefulWidget` y no hace falta Riverpod.
class PasswordField extends StatefulWidget {
  const PasswordField({super.key, required this.controller, this.onSubmitted});

  final TextEditingController controller;
  final VoidCallback? onSubmitted;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      validator: Validators.password,
      onFieldSubmitted: (_) => widget.onSubmitted?.call(),
      decoration: InputDecoration(
        hintText: 'Contraseña',
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          tooltip: _obscureText ? 'Mostrar contraseña' : 'Ocultar contraseña',
          icon: Icon(
            _obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
      ),
    );
  }
}
