import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';
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
              const SnackBar(content: Text('Recinto creado exitosamente'), backgroundColor: Colors.green),
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
                          AppTextField(
                            controller: _cantonController,
                            label: 'Cantón',
                            prefixIcon: Icons.map_rounded,
                            validator: (v) => v?.trim().isEmpty ?? true ? 'Requerido' : null,
                          ),
                          AppTextField(
                            controller: _parroquiaController,
                            label: 'Parroquia',
                            prefixIcon: Icons.location_city_rounded,
                            validator: (v) => v?.trim().isEmpty ?? true ? 'Requerido' : null,
                          ),
                          AppTextField(
                            controller: _nombreController,
                            label: 'Nombre del Recinto',
                            prefixIcon: Icons.business_rounded,
                            validator: (v) => v?.trim().isEmpty ?? true ? 'Requerido' : null,
                          ),
                          AppTextField(
                            controller: _numeroJrvController,
                            label: 'Número JRV (opcional)',
                            prefixIcon: Icons.pin_rounded,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 8),
                          AppButton(
                            label: 'Crear Recinto',
                            icon: Icons.add_location_alt_rounded,
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
