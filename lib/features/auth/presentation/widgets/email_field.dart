import 'package:bikes_app/core/utils/validators.dart';
import 'package:flutter/material.dart';

class EmailField extends StatelessWidget {
  const EmailField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      autocorrect: false,
      validator: Validators.email,
      decoration: const InputDecoration(
        hintText: 'Correo electrónico',
        prefixIcon: Icon(Icons.person_outline_rounded),
      ),
    );
  }
}
