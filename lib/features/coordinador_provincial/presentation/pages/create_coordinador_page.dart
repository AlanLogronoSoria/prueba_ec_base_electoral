import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/cedula_validator.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/provincial_bloc.dart';
import '../bloc/provincial_event.dart';
import '../bloc/provincial_state.dart';

class CreateCoordinadorPage extends StatefulWidget {
  const CreateCoordinadorPage({super.key});

  @override
  State<CreateCoordinadorPage> createState() => _CreateCoordinadorPageState();
}

class _CreateCoordinadorPageState extends State<CreateCoordinadorPage> {
  final _formKey = GlobalKey<FormState>();
  final _cedulaController = TextEditingController();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _correoController = TextEditingController();
  String? _selectedRecintoId;
  List<_RecintoItem> _recintos = [];

  @override
  void initState() {
    super.initState();
    context.read<ProvincialBloc>().add(const LoadRecintosSinCoordinador());
  }

  @override
  void dispose() {
    _cedulaController.dispose();
    _nombresController.dispose();
    _apellidosController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    super.dispose();
  }

  void _onCreate() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRecintoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un recinto'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    final authState = context.read<AuthBloc>().state;
    final creadoPor = authState is AuthAuthenticated ? authState.usuario.cedula : '';
    context.read<ProvincialBloc>().add(
          CreateCoordinadorRecinto(
            recintoId: _selectedRecintoId!,
            cedula: _cedulaController.text.trim(),
            nombres: _nombresController.text.trim(),
            apellidos: _apellidosController.text.trim(),
            telefono: _telefonoController.text.trim(),
            correo: _correoController.text.trim(),
            creadoPor: creadoPor,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Coordinador de Recinto')),
      body: BlocListener<ProvincialBloc, ProvincialState>(
        listener: (context, state) {
          if (state is CoordinadorRecintoCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Coordinador creado exitosamente'),
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
            if (state is RecintosSinCoordinadorLoaded) {
              _recintos = state.recintos
                  .map((r) => _RecintoItem(id: r.id, nombre: r.nombre))
                  .toList();
            }
            return Stack(
              children: [
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            initialValue: _selectedRecintoId,
                            decoration: const InputDecoration(
                              labelText: 'Recinto',
                              border: OutlineInputBorder(),
                            ),
                            items: _recintos
                                .map(
                                  (r) => DropdownMenuItem(
                                    value: r.id,
                                    child: Text(r.nombre),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedRecintoId = v),
                            validator: (v) =>
                                v == null ? 'Seleccione un recinto' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _cedulaController,
                            decoration: const InputDecoration(
                              labelText: 'Cédula',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v?.trim().isEmpty ?? true) {
                                return 'Requerido';
                              }
                              if (!CedulaValidator.isValid(v!.trim())) {
                                return 'Cédula inválida';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nombresController,
                            decoration: const InputDecoration(
                              labelText: 'Nombres',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                                v?.trim().isEmpty ?? true ? 'Requerido' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _apellidosController,
                            decoration: const InputDecoration(
                              labelText: 'Apellidos',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                                v?.trim().isEmpty ?? true ? 'Requerido' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _telefonoController,
                            decoration: const InputDecoration(
                              labelText: 'Teléfono',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (v) =>
                                v?.trim().isEmpty ?? true ? 'Requerido' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _correoController,
                            decoration: const InputDecoration(
                              labelText: 'Correo Electrónico',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v?.trim().isEmpty ?? true) return 'Requerido';
                              if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(v!.trim())) {
                                return 'Correo inválido';
                              }
                              return null;
                            },
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
                            child: const Text('Crear Coordinador'),
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

class _RecintoItem {
  final String id;
  final String nombre;
  const _RecintoItem({required this.id, required this.nombre});
}
