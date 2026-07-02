import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/gps_helper.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/veedor_bloc.dart';
import '../bloc/veedor_event.dart';
import '../bloc/veedor_state.dart';
import 'foto_acta_page.dart';

class RegistrarActaPage extends StatefulWidget {
  const RegistrarActaPage({super.key});

  @override
  State<RegistrarActaPage> createState() => _RegistrarActaPageState();
}

class _RegistrarActaPageState extends State<RegistrarActaPage> {
  final _formKey = GlobalKey<FormState>();
  final _mesaIdController = TextEditingController();
  final _totalController = TextEditingController();
  final _nulosController = TextEditingController();
  final _blancosController = TextEditingController();

  final Map<String, TextEditingController> _orgControllers = {};
  List<Map<String, dynamic>> _organizaciones = [];
  String _dignidad = 'alcalde';
  bool _gpsObtained = false;
  double _gpsLat = 0;
  double _gpsLng = 0;

  @override
  void initState() {
    super.initState();
    context.read<VeedorBloc>().add(const LoadOrganizaciones());
  }

  @override
  void dispose() {
    _mesaIdController.dispose();
    _totalController.dispose();
    _nulosController.dispose();
    _blancosController.dispose();
    for (final c in _orgControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _obtenerGps() async {
    final enabled = await GpsHelper.isGpsEnabled();
    if (!enabled) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('GPS Requerido'),
            content: const Text(
              'Debes activar el GPS para registrar el acta. '
              'La ubicación es obligatoria.',
            ),
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
      if (result == LocationPermission.denied ||
          result == LocationPermission.deniedForever) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Permiso Denegado'),
              content: const Text(
                'El permiso de ubicación es obligatorio para '
                'registrar el acta. No puedes continuar sin él.',
              ),
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
    if (position != null) {
      setState(() {
        _gpsObtained = true;
        _gpsLat = position.latitude;
        _gpsLng = position.longitude;
      });
    }
  }

  bool _validarActa() {
    final total = int.tryParse(_totalController.text) ?? 0;

    for (final c in _orgControllers.values) {
      final voto = int.tryParse(c.text) ?? 0;
      if (voto > total) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'El voto de una organización ($voto) excede el total de sufragantes ($total)',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    }

    final nulos = int.tryParse(_nulosController.text) ?? 0;
    final blancos = int.tryParse(_blancosController.text) ?? 0;

    int sumaOrganizaciones = 0;
    for (final c in _orgControllers.values) {
      sumaOrganizaciones += int.tryParse(c.text) ?? 0;
    }

    return (sumaOrganizaciones + nulos + blancos) == total;
  }

  void _onRegistrar() {
    if (!_formKey.currentState!.validate()) return;

    if (!_gpsObtained) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes obtener la ubicación GPS primero'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_validarActa()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La suma de votos no coincide con el total de sufragantes',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    String registradoPor = '';
    if (authState is AuthAuthenticated) {
      registradoPor = authState.usuario.id;
    }

    final votosPorOrganizacion = <String, int>{};
    for (final org in _organizaciones) {
      final orgId = org['id'] as String;
      final controller = _orgControllers[orgId];
      if (controller != null) {
        votosPorOrganizacion[orgId] = int.tryParse(controller.text) ?? 0;
      }
    }

    context.read<VeedorBloc>().add(
          RegistrarActa(
            mesaId: _mesaIdController.text.trim(),
            dignidad: _dignidad,
            totalSufragantes: int.parse(_totalController.text),
            votosNulos: int.parse(_nulosController.text),
            votosBlancos: int.parse(_blancosController.text),
            gpsLatitud: _gpsLat,
            gpsLongitud: _gpsLng,
            registradoPor: registradoPor,
            votosPorOrganizacion: votosPorOrganizacion,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Acta')),
      body: BlocConsumer<VeedorBloc, VeedorState>(
        listener: (context, state) {
          if (state is ActaRegistrada) {
            if (state.acta.estado == 'pendiente_sync') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Acta guardada localmente — se sincronizará al recuperar conexión',
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Acta registrada exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
            }
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<VeedorBloc>(),
                  child: FotoActaPage(actaId: state.acta.id),
                ),
              ),
            );
          }
          if (state is VeedorError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is OrganizacionesLoaded) {
            _organizaciones = state.organizaciones;
            for (final org in _organizaciones) {
              final id = org['id'] as String;
              if (!_orgControllers.containsKey(id)) {
                _orgControllers[id] = TextEditingController();
              }
            }
          }
        },
          builder: (context, state) {
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _mesaIdController,
                          decoration: const InputDecoration(
                            labelText: 'ID de la Mesa',
                            prefixIcon: Icon(Icons.table_chart_rounded, size: 20, color: AppColors.textTertiary),
                          ),
                          validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _dignidad,
                          decoration: const InputDecoration(
                            labelText: 'Dignidad',
                            prefixIcon: Icon(Icons.assignment_rounded, size: 20, color: AppColors.textTertiary),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'alcalde', child: Text('Alcalde')),
                            DropdownMenuItem(value: 'prefecto', child: Text('Prefecto')),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _dignidad = v);
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _totalController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Total Sufragantes',
                            prefixIcon: Icon(Icons.people_rounded, size: 20, color: AppColors.textTertiary),
                          ),
                          validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nulosController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Votos Nulos',
                            prefixIcon: Icon(Icons.close_rounded, size: 20, color: AppColors.textTertiary),
                          ),
                          validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _blancosController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Votos Blancos',
                            prefixIcon: Icon(Icons.check_box_outline_blank_rounded, size: 20, color: AppColors.textTertiary),
                          ),
                          validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 24),
                        if (_organizaciones.isNotEmpty) ...[
                          Text('Votos por Organización', style: AppTypography.headingSmall),
                          const SizedBox(height: 8),
                          ..._organizaciones.map((org) {
                            final id = org['id'] as String;
                            final nombre = org['nombre'] as String;
                            final candidato = org['candidato'] as String;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: TextFormField(
                                controller: _orgControllers[id],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: '$nombre - $candidato',
                                ),
                                validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                              ),
                            );
                          }),
                        ],
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _gpsObtained ? null : _obtenerGps,
                          icon: Icon(
                            _gpsObtained ? Icons.gps_fixed_rounded : Icons.gps_off_rounded,
                            size: 20,
                            color: _gpsObtained ? AppColors.success : AppColors.textSecondary,
                          ),
                          label: Text(_gpsObtained ? 'GPS Obtenido' : 'Obtener Ubicación GPS'),
                        ),
                        if (_gpsObtained)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.successLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on_rounded, size: 16, color: AppColors.success),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Lat: $_gpsLat, Lng: $_gpsLng',
                                    style: const TextStyle(fontSize: 12, color: AppColors.success),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: state is VeedorLoading ? null : _onRegistrar,
                          child: const Text('Guardar Acta'),
                        ),
                      ],
                    ),
                  ),
                ),
                if (state is VeedorLoading)
                  Container(
                    color: AppColors.overlay,
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }
}
