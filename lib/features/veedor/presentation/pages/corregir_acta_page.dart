import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/utils/gps_helper.dart';
import '../../../../core/utils/image_quality_checker.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/veedor_bloc.dart';
import '../bloc/veedor_event.dart';
import '../bloc/veedor_state.dart';

class CorregirActaPage extends StatefulWidget {
  final String actaId;
  final Map<String, dynamic> actaData;
  final List<Map<String, dynamic>> organizaciones;

  const CorregirActaPage({
    super.key,
    required this.actaId,
    required this.actaData,
    required this.organizaciones,
  });

  @override
  State<CorregirActaPage> createState() => _CorregirActaPageState();
}

class _CorregirActaPageState extends State<CorregirActaPage> {
  final _formKey = GlobalKey<FormState>();
  final _totalController = TextEditingController();
  final _nulosController = TextEditingController();
  final _blancosController = TextEditingController();
  final _votoControllers = <String, TextEditingController>{};
  File? _nuevaFoto;
  bool _gpsObtained = false;
  double _gpsLat = 0;
  double _gpsLng = 0;

  @override
  void initState() {
    super.initState();
    _totalController.text = (widget.actaData['total_sufragantes'] ?? 0).toString();
    _nulosController.text = (widget.actaData['votos_nulos'] ?? 0).toString();
    _blancosController.text = (widget.actaData['votos_blancos'] ?? 0).toString();

    for (final org in widget.organizaciones) {
      final id = org['id'] as String;
      _votoControllers[id] = TextEditingController(text: '0');
    }
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

  bool _validarIndividual() {
    final total = int.tryParse(_totalController.text) ?? 0;
    for (final entry in _votoControllers.entries) {
      final voto = int.tryParse(entry.value.text) ?? 0;
      if (voto > total) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('El voto de una organización ($voto) excede el total de sufragantes ($total)'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    }
    return true;
  }

  Map<String, int> _buildVotosPorOrganizacion() {
    final map = <String, int>{};
    for (final entry in _votoControllers.entries) {
      final voto = int.tryParse(entry.value.text) ?? 0;
      map[entry.key] = voto;
    }
    return map;
  }

  Future<void> _obtenerGps() async {
    final enabled = await GpsHelper.isGpsEnabled();
    if (!enabled) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('GPS Requerido'),
            content: const Text('Debes activar el GPS. La ubicación es obligatoria.'),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
      }
      return;
    }

    final permission = await GpsHelper.checkPermission();
    if (permission == LocationPermission.denied) {
      final result = await GpsHelper.requestPermission();
      if (result == LocationPermission.denied || result == LocationPermission.deniedForever) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Permiso Denegado'),
              content: const Text('El permiso de ubicación es obligatorio.'),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Entendido'),
                ),
              ],
            ),
          );
        }
        return;
      }
    }

    final position = await GpsHelper.getCurrentPosition();
    if (position != null && mounted) {
      setState(() {
        _gpsObtained = true;
        _gpsLat = position.latitude;
        _gpsLng = position.longitude;
      });
    }
  }

  void _onCorregir() {
    if (!_formKey.currentState!.validate()) return;
    if (!_validarIndividual()) return;

    final authState = context.read<AuthBloc>().state;
    String modificadoPor = '';
    if (authState is AuthAuthenticated) {
      modificadoPor = authState.usuario.id;
    }

    context.read<VeedorBloc>().add(
          CorregirActaVeedor(
            actaId: widget.actaId,
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
    if (file == null) return;

    final imageFile = File(file.path);
    final isSharp = await ImageQualityChecker.isSharp(imageFile);
    if (!isSharp) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Foto Borrosa'),
            content: const Text('La foto no tiene la nitidez suficiente. Por favor, selecciona otra.'),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
      }
      return;
    }

    if (mounted) setState(() => _nuevaFoto = imageFile);
  }

  void _subirFoto() {
    if (_nuevaFoto == null) return;
    context.read<VeedorBloc>().add(
          SubirFotoActa(
            filePath: _nuevaFoto!.path,
            actaId: widget.actaId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Corregir Acta')),
      body: BlocConsumer<VeedorBloc, VeedorState>(
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
              const SnackBar(
                content: Text('Foto actualizada exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            setState(() => _nuevaFoto = null);
          }
          if (state is VeedorError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final acta = widget.actaData;
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Acta: ${acta['dignidad'] ?? ''}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text('Mesa: ${acta['mesa_id'] ?? ''}',
                                  style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _totalController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Total Sufragantes',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nulosController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Votos Nulos',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _blancosController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Votos Blancos',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      const Text('Votos por Organización',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...widget.organizaciones.map((org) {
                        final id = org['id'] as String;
                        final nombre = org['nombre'] as String;
                        final candidato = org['candidato'] as String? ?? '';
                        final controller = _votoControllers[id]!;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TextFormField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: nombre,
                              hintText: candidato.isNotEmpty ? 'Candidato: $candidato' : null,
                              border: const OutlineInputBorder(),
                            ),
                            validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _obtenerGps,
                              icon: Icon(_gpsObtained ? Icons.gps_fixed : Icons.gps_not_fixed,
                                  color: _gpsObtained ? Colors.green : null),
                              label: Text(_gpsObtained ? 'GPS Capturado' : 'Actualizar GPS'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _seleccionarFoto,
                              icon: Icon(
                                  _nuevaFoto != null ? Icons.check_circle : Icons.add_a_photo),
                              label: Text(_nuevaFoto != null ? 'Foto seleccionada' : 'Cambiar Foto'),
                            ),
                          ),
                        ],
                      ),
                      if (_nuevaFoto != null) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_nuevaFoto!, height: 200, fit: BoxFit.cover),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _subirFoto,
                          icon: const Icon(Icons.cloud_upload),
                          label: const Text('Subir Nueva Foto'),
                        ),
                      ],
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: state is VeedorLoading ? null : _onCorregir,
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar Corrección'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (state is VeedorLoading)
                Container(
                  color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }
}
