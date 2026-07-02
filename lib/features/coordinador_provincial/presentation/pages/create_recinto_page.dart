import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/provincial_bloc.dart';
import '../bloc/provincial_event.dart';
import '../bloc/provincial_state.dart';

class CreateRecintoPage extends StatefulWidget {
  const CreateRecintoPage({super.key});

  @override
  State<CreateRecintoPage> createState() => _CreateRecintoPageState();
}

class _CreateRecintoPageState extends State<CreateRecintoPage> {
  final _formKey = GlobalKey<FormState>();
  final _cantonController = TextEditingController();
  final _parroquiaController = TextEditingController();
  final _nombreController = TextEditingController();
  final _numeroJrvController = TextEditingController();

  @override
  void dispose() {
    _cantonController.dispose();
    _parroquiaController.dispose();
    _nombreController.dispose();
    _numeroJrvController.dispose();
    super.dispose();
  }

  void _onCreate() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ProvincialBloc>().add(
          CreateRecinto(
            canton: _cantonController.text.trim(),
            parroquia: _parroquiaController.text.trim(),
            nombre: _nombreController.text.trim(),
            numeroJrv: _numeroJrvController.text.trim().isEmpty
                ? null
                : _numeroJrvController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Recinto')),
      body: BlocListener<ProvincialBloc, ProvincialState>(
        listener: (context, state) {
          if (state is RecintoCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Recinto creado exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          }
          if (state is ProvincialError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<ProvincialBloc, ProvincialState>(
          builder: (context, state) {
            return Stack(
              children: [
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _cantonController,
                            decoration: const InputDecoration(
                              labelText: 'Cantón',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                                v?.trim().isEmpty ?? true ? 'Requerido' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _parroquiaController,
                            decoration: const InputDecoration(
                              labelText: 'Parroquia',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                                v?.trim().isEmpty ?? true ? 'Requerido' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nombreController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre del Recinto',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                                v?.trim().isEmpty ?? true ? 'Requerido' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _numeroJrvController,
                            decoration: const InputDecoration(
                              labelText: 'Número JRV (opcional)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed:
                                state is ProvincialLoading ? null : _onCreate,
                            style: FilledButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              minimumSize: const Size(double.infinity, 0),
                            ),
                            child: const Text('Crear Recinto'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (state is ProvincialLoading)
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
