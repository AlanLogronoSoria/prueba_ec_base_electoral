import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/cedula_validator.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';
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
        const SnackBar(content: Text('Debe seleccionar un recinto'), backgroundColor: Colors.orange),
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
              const SnackBar(content: Text('Coordinador creado exitosamente'), backgroundColor: Colors.green),
            );
            Navigator.of(context).pop();
          }
          if (state is ProvincialError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: DropdownButtonFormField<String>(
                              value: _selectedRecintoId,
                              decoration: const InputDecoration(
                                labelText: 'Recinto',
                                prefixIcon: Icon(Icons.business_rounded, size: 20, color: AppColors.textTertiary),
                              ),
                              items: _recintos
                                  .map((r) => DropdownMenuItem(value: r.id, child: Text(r.nombre)))
                                  .toList(),
                              onChanged: (v) => setState(() => _selectedRecintoId = v),
                              validator: (v) => v == null ? 'Seleccione un recinto' : null,
                            ),
                          ),
                          AppTextField(
                            controller: _cedulaController,
                            label: 'Cédula',
                            prefixIcon: Icons.badge_outlined,
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v?.trim().isEmpty ?? true) return 'Requerido';
                              if (!CedulaValidator.isValid(v!.trim())) return 'Cédula inválida';
                              return null;
                            },
                          ),
                          AppTextField(
                            controller: _nombresController,
                            label: 'Nombres',
                            prefixIcon: Icons.person_outline,
                            validator: (v) => v?.trim().isEmpty ?? true ? 'Requerido' : null,
                          ),
                          AppTextField(
                            controller: _apellidosController,
                            label: 'Apellidos',
                            prefixIcon: Icons.person_outline,
                            validator: (v) => v?.trim().isEmpty ?? true ? 'Requerido' : null,
                          ),
                          AppTextField(
                            controller: _telefonoController,
                            label: 'Teléfono',
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (v) => v?.trim().isEmpty ?? true ? 'Requerido' : null,
                          ),
                          AppTextField(
                            controller: _correoController,
                            label: 'Correo Electrónico',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v?.trim().isEmpty ?? true) return 'Requerido';
                              if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v!.trim())) {
                                return 'Correo inválido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          AppButton(
                            label: 'Crear Coordinador',
                            icon: Icons.person_add_alt_rounded,
                            onPressed: state is ProvincialLoading ? null : _onCreate,
                            isLoading: state is ProvincialLoading,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (state is ProvincialLoading)
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

class _RecintoItem {
  final String id;
  final String nombre;
  const _RecintoItem({required this.id, required this.nombre});
}
