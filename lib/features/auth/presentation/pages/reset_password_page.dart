import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';
import '../bloc/recovery_bloc.dart';
import '../bloc/recovery_event.dart';
import '../bloc/recovery_state.dart';

class ResetPasswordPage extends StatefulWidget {
  final String userId;
  final String secret;

  const ResetPasswordPage({
    super.key,
    required this.userId,
    required this.secret,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onResetPassword() {
    if (!_formKey.currentState!.validate()) return;
    context.read<RecoveryBloc>().add(
          CompletePasswordReset(
            userId: widget.userId,
            secret: widget.secret,
            newPassword: _newPasswordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restablecer Contraseña')),
      body: BlocListener<RecoveryBloc, RecoveryState>(
        listener: (context, state) {
          if (state is RecoveryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
          if (state is RecoveryPasswordReset) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text('Contraseña Restablecida'),
                content: const Text(
                  'Tu contraseña se ha restablecido exitosamente. '
                  'Ahora puedes iniciar sesión con tu nueva contraseña.',
                ),
                actions: [
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      while (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Ir al inicio de sesión'),
                  ),
                ],
              ),
            );
          }
        },
        child: BlocBuilder<RecoveryBloc, RecoveryState>(
          builder: (context, state) {
            return Stack(
              children: [
                Center(
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
                              color: AppColors.successLight,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.lock_reset_rounded,
                              size: 32,
                              color: AppColors.success,
                            ),
                          ),
                          Text(
                            'Nueva Contraseña',
                            textAlign: TextAlign.center,
                            style: AppTypography.displayMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ingresa tu nueva contraseña.',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySmall,
                          ),
                          const SizedBox(height: 32),
                          AppTextField(
                            controller: _newPasswordController,
                            label: 'Nueva Contraseña',
                            prefixIcon: Icons.lock,
                            obscureText: _obscureNew,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Ingrese una contraseña';
                              if (value.length < 8) return 'Mínimo 8 caracteres';
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
                            label: 'Restablecer Contraseña',
                            icon: Icons.check_rounded,
                            onPressed: state is RecoveryLoading ? null : _onResetPassword,
                            isLoading: state is RecoveryLoading,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (state is RecoveryLoading)
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
