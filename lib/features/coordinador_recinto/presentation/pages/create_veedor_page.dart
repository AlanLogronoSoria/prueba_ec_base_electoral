import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/recinto_bloc.dart';
import '../bloc/recinto_event.dart';
import '../bloc/recinto_state.dart';

class CreateVeedorPage extends StatefulWidget {
  final String recintoId;

  const CreateVeedorPage({super.key, required this.recintoId});

  @override
  State<CreateVeedorPage> createState() => _CreateVeedorPageState();
}

class _CreateVeedorPageState extends State<CreateVeedorPage> {
  final _formKey = GlobalKey<FormState>();
  final _cedulaController = TextEditingController();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _correoController = TextEditingController();
  String? _selectedMesaId;

  @override
  void initState() {
    super.initState();
    context
        .read<RecintoBloc>()
        .add(LoadMesas(recintoId: widget.recintoId));
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

    final authState = context.read<AuthBloc>().state;
    String creadoPor = '';
    if (authState is AuthAuthenticated) {
      creadoPor = authState.usuario.id;
    }
    context.read<RecintoBloc>().add(
          CreateVeedor(
            cedula: _cedulaController.text.trim(),
            nombres: _nombresController.text.trim(),
            apellidos: _apellidosController.text.trim(),
            telefono: _telefonoController.text.trim(),
            correo: _correoController.text.trim(),
            creadoPor: creadoPor,
            mesaId: _selectedMesaId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Veedor')),
      body: BlocListener<RecintoBloc, RecintoState>(
        listener: (context, state) {
          if (state is VeedorCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Veedor creado y asignado exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          }
          if (state is RecintoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<RecintoBloc, RecintoState>(
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
                            controller: _cedulaController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Cédula',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) {
                              if (v?.trim().isEmpty ?? true) {
                                return 'Requerido';
                              }
                              if (v!.trim().length != 10) {
                                return 'Debe tener 10 dígitos';
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
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Teléfono',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                                v?.trim().isEmpty ?? true ? 'Requerido' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _correoController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Correo',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) {
                              if (v?.trim().isEmpty ?? true) {
                                return 'Requerido';
                              }
                              if (!v!.contains('@')) return 'Correo inválido';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          if (state is MesasLoaded && state.mesas.isNotEmpty)
                            DropdownButtonFormField<String>(
                              initialValue: _selectedMesaId,
                              decoration: const InputDecoration(
                                labelText: 'Asignar a Mesa',
                                border: OutlineInputBorder(),
                              ),
                              items: state.mesas
                                  .map(
                                    (m) => DropdownMenuItem(
                                      value: m.id,
                                      child: Text(
                                          'JRV ${m.numeroJrv}${m.veedorId != null ? ' (con veedor)' : ''}'),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedMesaId = v),
                              validator: (v) =>
                                  v == null ? 'Seleccione una mesa' : null,
                            )
                          else
                            const Text('Cargando mesas...'),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed:
                                state is RecintoLoading ? null : _onCreate,
                            style: FilledButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              minimumSize: const Size(double.infinity, 0),
                            ),
                            child: const Text('Crear Veedor y Asignar'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (state is RecintoLoading)
                  Container(
                    color: Colors.black26,
                    child:
                        const Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
