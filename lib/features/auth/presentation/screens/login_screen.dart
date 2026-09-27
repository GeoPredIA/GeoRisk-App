import 'package:flutter/material.dart';

import '../../../../app/navigation/main_bottom_nav.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/services/auth_api_service.dart';
import '../../domain/repositories/auth_repository.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, AuthRepository? repository})
      : _repository = repository;

  final AuthRepository? _repository;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  AuthRepository get _repository =>
      widget._repository ?? AuthRepositoryImpl(AuthApiService());

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final user = await _repository.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text);
      if (!mounted) return;
      if (!user.isVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tu cuenta aún no está verificada.')));
        return;
      }
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainBottomNav()),
          (_) => false);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _enterAsGuest() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainBottomNav()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.terrain_rounded,
                          size: 48, color: AppColors.primaryDark),
                      const SizedBox(height: 20),
                      Text('Bienvenido a GeoPredIA',
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      const Text(
                          'Decisiones de exploración con inteligencia geológica, ambiental y social.'),
                      const SizedBox(height: 32),
                      TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                              labelText: 'Correo institucional',
                              prefixIcon: Icon(Icons.email_outlined)),
                          validator: (value) =>
                              value != null && value.contains('@')
                                  ? null
                                  : 'Ingresa un correo válido.'),
                      const SizedBox(height: 16),
                      TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                  tooltip: 'Mostrar contraseña',
                                  onPressed: () => setState(() =>
                                      _obscurePassword = !_obscurePassword),
                                  icon: Icon(_obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined))),
                          validator: (value) =>
                              value != null && value.length >= 8
                                  ? null
                                  : 'Usa al menos 8 caracteres.'),
                      const SizedBox(height: 24),
                      SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                              onPressed: _isLoading ? null : _signIn,
                              icon: _isLoading
                                  ? const SizedBox.square(
                                      dimension: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))
                                  : const Icon(Icons.login),
                              label: const Text('Iniciar sesión'))),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _enterAsGuest,
                          icon: const Icon(Icons.visibility_outlined),
                          label: const Text('Ingresar como invitado'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          'Modo demostración · datos sintéticos',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                          child: TextButton(
                              onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const SignUpScreen())),
                              child: const Text('Crear una cuenta'))),
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
