import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/provincial_bloc.dart';
import '../bloc/provincial_event.dart';
import '../bloc/provincial_state.dart';

class VotosConsolidadosPage extends StatefulWidget {
  const VotosConsolidadosPage({super.key});

  @override
  State<VotosConsolidadosPage> createState() => _VotosConsolidadosPageState();
}

class _VotosConsolidadosPageState extends State<VotosConsolidadosPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<ProvincialBloc>()
        .add(const LoadVotosConsolidados());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Votos Consolidados')),
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
                            const LoadVotosConsolidados(),
                          );
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          if (state is VotosConsolidadosLoaded) {
            if (state.votos.isEmpty) {
              return const Center(
                child: Text('No hay votos registrados'),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProvincialBloc>().add(
                      const LoadVotosConsolidados(),
                    );
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.votos.length,
                itemBuilder: (context, index) {
                  final grupo = state.votos[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            grupo.dignidad.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const Divider(),
                          ...grupo.resultados.map(
                            (r) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          r.nombreOrganizacion,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (r.candidato.isNotEmpty)
                                          Text(
                                            r.candidato,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      r.totalVotos.toString(),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                grupo.resultados
                                    .fold(0, (sum, r) => sum + r.totalVotos)
                                    .toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
