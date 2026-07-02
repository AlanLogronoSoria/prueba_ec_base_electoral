import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is RecoveryEmailSent) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text('Correo Enviado'),
                content: Text(
                  'Se ha enviado un enlace de recuperación a ${state.email}. '
                  'Revisa tu bandeja de entrada y sigue las instrucciones.',
                ),
                actions: [
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Volver al inicio'),
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
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Recuperar Contraseña',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Ingresa tu cédula para recibir un enlace de '
                            'recuperación en tu correo electrónico.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 32),
                          TextFormField(
                            controller: _cedulaController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Cédula',
                              prefixIcon: Icon(Icons.badge),
                              border: OutlineInputBorder(),
                            ),
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
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed:
                                state is RecoveryLoading ? null : _onRequestReset,
                            style: FilledButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Enviar enlace de recuperación',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Volver al inicio de sesión'),
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
