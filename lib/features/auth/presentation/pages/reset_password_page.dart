import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
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
                          const Icon(
                            Icons.lock_reset,
                            size: 80,
                            color: Colors.green,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Nueva Contraseña',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Ingresa tu nueva contraseña.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 32),
                          TextFormField(
                            controller: _newPasswordController,
                            obscureText: _obscureNew,
                            decoration: InputDecoration(
                              labelText: 'Nueva Contraseña',
                              prefixIcon: const Icon(Icons.lock),
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureNew
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () =>
                                    setState(() => _obscureNew = !_obscureNew),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingrese una contraseña';
                              }
                              if (value.length < 8) {
                                return 'Mínimo 8 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirm,
                            decoration: InputDecoration(
                              labelText: 'Confirmar Contraseña',
                              prefixIcon: const Icon(Icons.lock),
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () => setState(() =>
                                    _obscureConfirm = !_obscureConfirm),
                              ),
                            ),
                            validator: (value) {
                              if (value != _newPasswordController.text) {
                                return 'Las contraseñas no coinciden';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed:
                                state is RecoveryLoading ? null : _onResetPassword,
                            style: FilledButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Restablecer Contraseña',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (state is RecoveryLoading)
                  Container(
                    color: Colors.black26,
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
