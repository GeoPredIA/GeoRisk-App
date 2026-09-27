import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/services/auth_api_service.dart';
import '../../domain/repositories/auth_repository.dart';
import 'email_verification_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, AuthRepository? repository})
      : _repository = repository;

  final AuthRepository? _repository;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String _role = 'Geólogo';

  AuthRepository get _repository =>
      widget._repository ?? AuthRepositoryImpl(AuthApiService());

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final email = _emailController.text.trim();
      await _repository.signUp(
        fullName: _nameController.text.trim(),
        email: email,
        password: _passwordController.text,
        role: _role,
      );
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => EmailVerificationScreen(email: email)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Únete al equipo GeoPredIA',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              const Text(
                  'Registra tus datos para crear tu cuenta en SAP HANA Cloud.'),
              const SizedBox(height: 24),
              TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                      labelText: 'Nombre completo',
                      prefixIcon: Icon(Icons.person_outline)),
                  validator: (value) => value == null || value.trim().length < 3
                      ? 'Ingresa tu nombre completo.'
                      : null),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                      labelText: 'Correo institucional',
                      prefixIcon: Icon(Icons.email_outlined)),
                  validator: (value) => value != null && value.contains('@')
                      ? null
                      : 'Ingresa un correo válido.'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                  initialValue: _role,
                  decoration: const InputDecoration(
                      labelText: 'Rol especialista',
                      prefixIcon: Icon(Icons.badge_outlined)),
                  items: const [
                    DropdownMenuItem(value: 'Geólogo', child: Text('Geólogo')),
                    DropdownMenuItem(
                        value: 'Ambiental', child: Text('Ambiental')),
                    DropdownMenuItem(value: 'Social', child: Text('Social')),
                    DropdownMenuItem(
                        value: 'Coordinador', child: Text('Coordinador'))
                  ],
                  onChanged: (value) => setState(() => _role = value ?? _role)),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: Icon(Icons.lock_outline)),
                  validator: (value) => value != null && value.length >= 8
                      ? null
                      : 'Usa al menos 8 caracteres.'),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: 'Confirmar contraseña',
                      prefixIcon: Icon(Icons.lock_reset_outlined)),
                  validator: (value) => value == _passwordController.text
                      ? null
                      : 'Las contraseñas no coinciden.'),
              const SizedBox(height: 24),
              SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                      onPressed: _isLoading ? null : _createAccount,
                      icon: _isLoading
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.mark_email_read_outlined),
                      label: const Text('Crear cuenta y verificar correo'))),
            ]),
          ),
        ),
      ),
    );
  }
}
