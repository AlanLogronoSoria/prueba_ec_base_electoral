import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';
import '../bloc/recovery_bloc.dart';
import '../bloc/recovery_event.dart';
import '../bloc/recovery_state.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _cedulaController = TextEditingController();

  @override
  void dispose() {
    _cedulaController.dispose();
    super.dispose();
  }

  void _onRequestReset() {
    if (!_formKey.currentState!.validate()) return;
    context.read<RecoveryBloc>().add(
          RequestPasswordReset(
            cedula: _cedulaController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar Contraseña')),
      body: BlocListener<RecoveryBloc, RecoveryState>(
        listener: (context, state) {
          if (state is RecoveryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          } else if (state is RecoveryEmailSent) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                title: const Text('Correo Enviado'),
                content: Text(
                  'Se ha enviado un enlace de recuperación a ${state.email}. '
                  'Revisa tu bandeja de entrada.',
                ),
                actions: [
                  FilledButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Aceptar'),
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
                              color: AppColors.warningLight,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.lock_reset_rounded,
                              size: 32,
                              color: AppColors.warning,
                            ),
                          ),
                          Text(
                            'Recuperar Contraseña',
                            textAlign: TextAlign.center,
                            style: AppTypography.displayMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ingresa tu cédula para recibir un enlace de recuperación en tu correo registrado.',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySmall,
                          ),
                          const SizedBox(height: 32),
                          AppTextField(
                            controller: _cedulaController,
                            label: 'Cédula',
                            hint: 'Ingrese su cédula',
                            prefixIcon: Icons.badge_outlined,
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v?.trim().isEmpty ?? true) return 'Ingrese su cédula';
                              if (v!.trim().length != 10) return 'Debe tener 10 dígitos';
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          AppButton(
                            label: 'Enviar enlace de recuperación',
                            icon: Icons.send_rounded,
                            onPressed: state is RecoveryLoading ? null : _onRequestReset,
                            isLoading: state is RecoveryLoading,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (state is RecoveryLoading)
                  Container(
                    color: Colors.black26,
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
