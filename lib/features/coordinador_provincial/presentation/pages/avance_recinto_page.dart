import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/provincial_bloc.dart';
import '../bloc/provincial_event.dart';
import '../bloc/provincial_state.dart';
import 'actas_por_recinto_page.dart';

class AvanceRecintoPage extends StatefulWidget {
  final String recintoId;
  final String recintoNombre;

  const AvanceRecintoPage({
    super.key,
    required this.recintoId,
    required this.recintoNombre,
  });

  @override
  State<AvanceRecintoPage> createState() => _AvanceRecintoPageState();
}

class _AvanceRecintoPageState extends State<AvanceRecintoPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<ProvincialBloc>()
        .add(LoadAvanceRecinto(recintoId: widget.recintoId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.recintoNombre)),
      body: BlocBuilder<ProvincialBloc, ProvincialState>(
        builder: (context, state) {
          if (state is ProvincialLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProvincialError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProvincialBloc>().add(
                            LoadAvanceRecinto(recintoId: widget.recintoId),
                          );
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          if (state is AvanceRecintoLoaded) {
            final porcentaje = state.totalMesas > 0
                ? (state.actasRegistradas / state.totalMesas * 100)
                : 0.0;
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Text(
                            'Avance del Recinto',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 150,
                                  height: 150,
                                  child: CircularProgressIndicator(
                                    value: porcentaje / 100,
                                    strokeWidth: 12,
                                    backgroundColor: Colors.grey[200],
                                  ),
                                ),
                                Text(
                                  '${porcentaje.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _AvanceStat(
                                label: 'Mesas',
                                value: state.totalMesas.toString(),
                              ),
                              _AvanceStat(
                                label: 'Actas',
                                value: state.actasRegistradas.toString(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<ProvincialBloc>().add(
                            LoadAvanceRecinto(recintoId: widget.recintoId),
                          );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Actualizar'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<ProvincialBloc>(),
                            child: ActasPorRecintoPage(
                              recintoId: widget.recintoId,
                              recintoNombre: widget.recintoNombre,
                            ),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.list_alt),
                    label: const Text('Ver Actas'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _AvanceStat extends StatelessWidget {
  final String label;
  final String value;

  const _AvanceStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
