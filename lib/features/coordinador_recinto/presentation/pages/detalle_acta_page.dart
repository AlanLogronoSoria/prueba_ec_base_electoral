import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../veedor/domain/entities/acta.dart';
import '../../../veedor/domain/entities/organizacion_politica.dart';
import '../bloc/recinto_bloc.dart';
import '../bloc/recinto_event.dart';
import '../bloc/recinto_state.dart';

class DetalleActaPage extends StatefulWidget {
  final Acta acta;

  const DetalleActaPage({super.key, required this.acta});

  @override
  State<DetalleActaPage> createState() => _DetalleActaPageState();
}

class _DetalleActaPageState extends State<DetalleActaPage> {
  final _formKey = GlobalKey<FormState>();
  final _totalController = TextEditingController();
  final _nulosController = TextEditingController();
  final _blancosController = TextEditingController();
  final _votoControllers = <String, TextEditingController>{};
  List<OrganizacionPolitica> _organizaciones = [];
  File? _nuevaFoto;

  @override
  void initState() {
    super.initState();
    _totalController.text = widget.acta.totalSufragantes.toString();
    _nulosController.text = widget.acta.votosNulos.toString();
    _blancosController.text = widget.acta.votosBlancos.toString();
    context.read<RecintoBloc>().add(const LoadOrganizaciones());
  }

  @override
  void dispose() {
    _totalController.dispose();
    _nulosController.dispose();
    _blancosController.dispose();
    for (final c in _votoControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, int> _buildVotosPorOrganizacion() {
    final map = <String, int>{};
    for (final org in _organizaciones) {
      final controller = _votoControllers[org.id];
      if (controller != null && controller.text.isNotEmpty) {
        map[org.id] = int.tryParse(controller.text) ?? 0;
      }
    }
    return map;
  }

  void _onCorregir() {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthBloc>().state;
    String modificadoPor = '';
    if (authState is AuthAuthenticated) {
      modificadoPor = authState.usuario.id;
    }

    context.read<RecintoBloc>().add(
          CorregirActa(
            actaId: widget.acta.id,
            totalSufragantes: int.parse(_totalController.text),
            votosNulos: int.parse(_nulosController.text),
            votosBlancos: int.parse(_blancosController.text),
            votosPorOrganizacion: _buildVotosPorOrganizacion(),
            modificadoPor: modificadoPor,
          ),
        );
  }

  Future<void> _seleccionarFoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _nuevaFoto = File(file.path));
    }
  }

  void _subirFoto() {
    if (_nuevaFoto == null) return;
    context.read<RecintoBloc>().add(
          SubirFotoActa(
            filePath: _nuevaFoto!.path,
            actaId: widget.acta.id,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Corregir Acta')),
      body: BlocListener<RecintoBloc, RecintoState>(
        listener: (context, state) {
          if (state is ActaCorregida) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Acta corregida exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          }
          if (state is FotoSubida) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Foto actualizada exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            setState(() => _nuevaFoto = null);
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
            if (state is OrganizacionesLoaded && mounted) {
              _organizaciones = state.organizaciones;
            }

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Datos del Acta',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Dignidad: ${widget.acta.dignidad}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const Divider(),
                        TextFormField(
                          controller: _totalController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Total Sufragantes',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nulosController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Votos Nulos',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _blancosController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Votos Blancos',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Votos por Organización',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (state is RecintoLoading &&
                            _organizaciones.isEmpty)
                          const Center(child: CircularProgressIndicator())
                        else if (_organizaciones.isEmpty)
                          const Text('No hay organizaciones cargadas')
                        else
                          ..._organizaciones.map((org) {
                            _votoControllers.putIfAbsent(
                              org.id,
                              () => TextEditingController(),
                            );
                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 12),
                              child: TextFormField(
                                controller: _votoControllers[org.id],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText:
                                      '${org.nombre} - ${org.candidato}',
                                  border:
                                      const OutlineInputBorder(),
                                ),
                              ),
                            );
                          }),
                        const SizedBox(height: 24),
                        const Text(
                          'Foto del Acta',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (widget.acta.fotoUrl != null &&
                            _nuevaFoto == null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              widget.acta.fotoUrl!,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  const Icon(Icons.broken_image,
                                      size: 60),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (_nuevaFoto != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _nuevaFoto!,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        OutlinedButton.icon(
                          onPressed: _seleccionarFoto,
                          icon: const Icon(Icons.camera_alt),
                          label: Text(
                            _nuevaFoto != null
                                ? 'Cambiar foto seleccionada'
                                : 'Seleccionar nueva foto',
                          ),
                        ),
                        if (_nuevaFoto != null) ...[
                          const SizedBox(height: 8),
                          FilledButton.tonalIcon(
                            onPressed:
                                state is RecintoLoading ? null : _subirFoto,
                            icon: const Icon(Icons.upload),
                            label: const Text('Subir Foto'),
                          ),
                        ],
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed:
                              state is RecintoLoading ? null : _onCorregir,
                          style: FilledButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Guardar Corrección'),
                        ),
                      ],
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
