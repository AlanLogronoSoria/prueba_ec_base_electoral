import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/mesa.dart';
import '../bloc/recinto_bloc.dart';
import '../bloc/recinto_event.dart';
import '../bloc/recinto_state.dart';
import 'detalle_acta_page.dart';

class DetalleMesaPage extends StatefulWidget {
  final String recintoId;
  final String? mesaId;
  final String? numeroJrv;

  const DetalleMesaPage({
    super.key,
    required this.recintoId,
    this.mesaId,
    this.numeroJrv,
  });

  @override
  State<DetalleMesaPage> createState() => _DetalleMesaPageState();
}

class _DetalleMesaPageState extends State<DetalleMesaPage> {
  Mesa? _mesa;

  @override
  void initState() {
    super.initState();
    context
        .read<RecintoBloc>()
        .add(LoadMesas(recintoId: widget.recintoId));
  }

  void _showAsignarVeedorDialog() {
    if (_mesa == null) return;
    final cedulaController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reasignar Veedor'),
        content: TextField(
          controller: cedulaController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Cédula del veedor',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              context.read<RecintoBloc>().add(
                    AsignarVeedor(
                      mesaId: _mesa!.id,
                      veedorCedula: cedulaController.text.trim(),
                    ),
                  );
              Navigator.pop(ctx);
            },
            child: const Text('Asignar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            _mesa != null ? 'JRV ${_mesa!.numeroJrv}' : 'Detalle Mesa'),
      ),
      body: BlocConsumer<RecintoBloc, RecintoState>(
        listener: (context, state) {
          if (state is VeedorAsignado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Veedor asignado correctamente'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<RecintoBloc>().add(
                LoadMesas(recintoId: widget.recintoId));
          }
          if (state is ActaCorregida) {
            if (_mesa != null) {
              context
                  .read<RecintoBloc>()
                  .add(LoadActaPorMesa(mesaId: _mesa!.id));
            }
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
        builder: (context, state) {
          if (state is MesasLoaded && _mesa == null) {
            final encontrada = widget.mesaId != null
                ? state.mesas.where((m) => m.id == widget.mesaId).firstOrNull
                : widget.numeroJrv != null
                    ? state.mesas
                        .where((m) => m.numeroJrv == widget.numeroJrv)
                        .firstOrNull
                    : null;
            if (encontrada != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _mesa = encontrada;
                  });
                  if (encontrada.hasActa) {
                    context
                        .read<RecintoBloc>()
                        .add(LoadActaPorMesa(mesaId: encontrada.id));
                  }
                }
              });
            }
          }

          if (state is RecintoLoading && _mesa == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_mesa == null) {
            return const Center(child: Text('Mesa no encontrada'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _mesa!.hasActa
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: _mesa!.hasActa
                                  ? Colors.green
                                  : Colors.orange,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'JRV ${_mesa!.numeroJrv}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        _InfoRow(
                          label: 'Estado del acta',
                          value: _mesa!.hasActa
                              ? 'Registrada'
                              : 'Pendiente',
                          valueColor: _mesa!.hasActa
                              ? Colors.green
                              : Colors.orange,
                        ),
                        _InfoRow(
                          label: 'Veedor',
                          value: _mesa!.veedorId != null
                              ? 'Asignado'
                              : 'Sin asignar',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _showAsignarVeedorDialog,
                  icon: Icon(_mesa!.veedorId != null
                      ? Icons.swap_horiz
                      : Icons.person_add),
                  label: Text(_mesa!.veedorId != null
                      ? 'Reasignar Veedor'
                      : 'Asignar Veedor'),
                ),
                const SizedBox(height: 16),
                if (_mesa!.hasActa && state is! ActaPorMesaLoaded)
                  const Center(child: CircularProgressIndicator()),
                if (state is ActaPorMesaLoaded) ...[
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Acta Registrada',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          _InfoRow(
                            label: 'Dignidad',
                            value: state.acta.dignidad,
                          ),
                          _InfoRow(
                            label: 'Total Sufragantes',
                            value: '${state.acta.totalSufragantes}',
                          ),
                          _InfoRow(
                            label: 'Votos Válidos',
                            value: '${state.acta.votosValidos}',
                          ),
                          _InfoRow(
                            label: 'Votos Nulos',
                            value: '${state.acta.votosNulos}',
                          ),
                          _InfoRow(
                            label: 'Votos Blancos',
                            value: '${state.acta.votosBlancos}',
                          ),
                          if (state.acta.fotoUrl != null) ...[
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => Dialog(
                                    child: InteractiveViewer(
                                      child: Image.network(
                                        state.acta.fotoUrl!,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(8),
                                child: Image.network(
                                  state.acta.fotoUrl!,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, _, _) =>
                                          const Icon(Icons.broken_image,
                                              size: 80),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      BlocProvider.value(
                                    value:
                                        context.read<RecintoBloc>(),
                                    child: DetalleActaPage(
                                      acta: state.acta,
                                    ),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Corregir Acta'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (!_mesa!.hasActa)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.info_outline,
                              size: 48, color: Colors.orange),
                          const SizedBox(height: 8),
                          const Text(
                            'Esta mesa aún no tiene un acta registrada',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
