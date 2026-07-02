import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onChangePassword() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          ChangePasswordRequested(
            currentPassword: _currentPasswordController.text,
            newPassword: _newPasswordController.text,
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
          } else if (state is AuthUnauthenticated) {
            context.go('/login');
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return Stack(
              children: [
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: AppColors.warningLight,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.lock_reset_rounded,
                                size: 32,
                                color: AppColors.warning,
                              ),
                            ),
                            const Text(
                              'Cambio de Contraseña',
                              textAlign: TextAlign.center,
                              style: AppTypography.displayMedium,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Por seguridad, debes cambiar tu contraseña inicial.',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodySmall,
                            ),
                            const SizedBox(height: 32),
                            AppTextField(
                              controller: _currentPasswordController,
                              label: 'Contraseña Actual',
                              prefixIcon: Icons.lock_outline,
                              obscureText: _obscureCurrent,
                              validator: (v) =>
                                  v?.isEmpty ?? true ? 'Ingrese la contraseña actual' : null,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscureCurrent
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  size: 20,
                                  color: AppColors.textTertiary,
                                ),
                                onPressed: () => setState(
                                    () => _obscureCurrent = !_obscureCurrent),
                              ),
                            ),
                            AppTextField(
                              controller: _newPasswordController,
                              label: 'Nueva Contraseña',
                              prefixIcon: Icons.lock,
                              obscureText: _obscureNew,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingrese una contraseña';
                                }
                                if (value.length < 8) {
                                  return 'Mínimo 8 caracteres';
                                }
                                return null;
                              },
                              suffix: IconButton(
                                icon: Icon(
                                  _obscureNew
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  size: 20,
                                  color: AppColors.textTertiary,
                                ),
                                onPressed: () =>
                                    setState(() => _obscureNew = !_obscureNew),
                              ),
                            ),
                            AppTextField(
                              controller: _confirmPasswordController,
                              label: 'Confirmar Contraseña',
                              prefixIcon: Icons.lock,
                              obscureText: _obscureConfirm,
                              validator: (value) {
                                if (value != _newPasswordController.text) {
                                  return 'Las contraseñas no coinciden';
                                }
                                return null;
                              },
                              suffix: IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  size: 20,
                                  color: AppColors.textTertiary,
                                ),
                                onPressed: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm),
                              ),
                            ),
                            const SizedBox(height: 24),
                            AppButton(
                              label: 'Cambiar Contraseña',
                              icon: Icons.check_rounded,
                              onPressed: state is AuthLoading ? null : _onChangePassword,
                              isLoading: state is AuthLoading,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (state is AuthLoading)
                  Container(
                    color: AppColors.overlay,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
