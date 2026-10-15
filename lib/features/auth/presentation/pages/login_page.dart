import 'package:bikes_app/core/config/app_config.dart';
import 'package:bikes_app/core/constants/demo_credentials.dart';
import 'package:bikes_app/core/error/failures.dart';
import 'package:bikes_app/core/theme/app_colors.dart';
import 'package:bikes_app/core/widgets/primary_button.dart';
import 'package:bikes_app/features/auth/presentation/providers/login_controller.dart';
import 'package:bikes_app/features/auth/presentation/widgets/email_field.dart';
import 'package:bikes_app/features/auth/presentation/widgets/password_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    // No navegamos aquí: si el login es correcto, el router detecta la
    // nueva sesión y redirige solo a la pantalla de inicio.
    await ref
        .read(loginControllerProvider.notifier)
        .signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  void _fillDemoCredentials({required bool admin}) {
    _emailController.text = admin
        ? DemoCredentials.adminEmail
        : DemoCredentials.employeeEmail;
    _passwordController.text = admin
        ? DemoCredentials.adminPassword
        : DemoCredentials.employeePassword;
    _submit();
  }

  @override
  Widget build(BuildContext context) {
    // `listen` sirve para efectos secundarios (SnackBar, diálogos, navegación)
    // sin reconstruir la pantalla.
    ref.listen(loginControllerProvider, (previous, next) {
      if (next case AsyncError(:final error)) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(errorMessageOf(error)),
              backgroundColor: AppColors.error,
            ),
          );
      }
    });

    // `watch` reconstruye el widget cada vez que cambia el estado.
    final isLoading = ref.watch(loginControllerProvider).isLoading;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.asset(
                        'assets/images/bicycle-shop-amico.png',
                        height: 220,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Iniciar sesión',
                        textAlign: TextAlign.center,
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Gestiona las rentas de tu sucursal.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 28),
                      EmailField(
                        key: const Key('login_email_field'),
                        controller: _emailController,
                      ),
                      const SizedBox(height: 16),
                      PasswordField(
                        key: const Key('login_password_field'),
                        controller: _passwordController,
                        onSubmitted: _submit,
                      ),
                      const SizedBox(height: 28),
                      PrimaryButton(
                        key: const Key('login_submit_button'),
                        label: 'Ingresar',
                        isLoading: isLoading,
                        onPressed: _submit,
                      ),
                      // Solo en modo demo (sin Supabase configurado).
                      if (!AppConfig.useSupabase) ...[
                        const SizedBox(height: 20),
                        _DemoCredentialsCard(onUse: _fillDemoCredentials),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoCredentialsCard extends StatelessWidget {
  const _DemoCredentialsCard({required this.onUse});

  final void Function({required bool admin}) onUse;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.info),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Modo demo · contraseña: ${DemoCredentials.employeePassword}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                TextButton(
                  key: const Key('demo_employee_button'),
                  onPressed: () => onUse(admin: false),
                  child: const Text('Entrar como empleado'),
                ),
                TextButton(
                  key: const Key('demo_admin_button'),
                  onPressed: () => onUse(admin: true),
                  child: const Text('Entrar como admin'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
