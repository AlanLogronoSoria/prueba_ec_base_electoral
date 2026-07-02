import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _cedulaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _selectedRole;

  static const _roles = [
    'coordinador_provincial',
    'coordinador_recinto',
    'veedor',
  ];

  @override
  void dispose() {
    _cedulaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          LoginRequested(
            cedula: _cedulaController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            selectedRole: _selectedRole,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AuthRequiresPasswordChange) {
            context.go('/change-password');
          } else if (state is AuthAuthenticated) {
            final route = switch (state.usuario.rol) {
              'coordinador_provincial' => '/provincial',
              'coordinador_recinto' => '/recinto',
              'veedor' => '/veedor',
              _ => '/login',
            };
            context.go(route);
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return Stack(
              children: [
                Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.35,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryDark,
                            AppColors.primary,
                          ],
                        ),
                      ),
                      child: SafeArea(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(30),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.how_to_vote_rounded,
                                  size: 44,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Control Electoral',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Sistema de Escrutinio Ecuador',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFBFDBFE),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppTextField(
                                controller: _cedulaController,
                                label: 'Cédula',
                                hint: 'Ingrese su cédula',
                                prefixIcon: Icons.badge_outlined,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Ingrese su cédula';
                                  }
                                  if (value.trim().length != 10) {
                                    return 'La cédula debe tener 10 dígitos';
                                  }
                                  return null;
                                },
                              ),
                              AppTextField(
                                controller: _emailController,
                                label: 'Correo electrónico',
                                hint: 'correo@ejemplo.com',
                                prefixIcon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Ingrese su correo electrónico';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Ingrese un correo válido';
                                  }
                                  return null;
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: DropdownButtonFormField<String>(
                                  value: _selectedRole,
                                  decoration: const InputDecoration(
                                    labelText: 'Rol',
                                    prefixIcon: Icon(
                                      Icons.supervised_user_circle_outlined,
                                      size: 20,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'coordinador_provincial',
                                      child: Text('Coordinador Provincial'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'coordinador_recinto',
                                      child: Text('Coordinador de Recinto'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'veedor',
                                      child: Text('Veedor'),
                                    ),
                                  ],
                                  onChanged: (v) =>
                                      setState(() => _selectedRole = v),
                                  validator: (v) =>
                                      v == null ? 'Seleccione un rol' : null,
                                ),
                              ),
                              AppTextField(
                                controller: _passwordController,
                                label: 'Contraseña',
                                prefixIcon: Icons.lock_outline,
                                obscureText: _obscurePassword,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese su contraseña';
                                  }
                                  return null;
                                },
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    size: 20,
                                    color: AppColors.textTertiary,
                                  ),
                                  onPressed: () => setState(
                                      () => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => context.push('/forgot-password'),
                                  child: const Text('¿Olvidaste tu contraseña?'),
                                ),
                              ),
                              const SizedBox(height: 20),
                              FilledButton(
                                onPressed:
                                    state is AuthLoading ? null : _onLogin,
                                child: const Text('Iniciar Sesión'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (state is AuthLoading)
                  Container(
                    color: AppColors.overlay,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
