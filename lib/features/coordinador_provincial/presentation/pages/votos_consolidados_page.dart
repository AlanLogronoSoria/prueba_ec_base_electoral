import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
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
    context.read<ProvincialBloc>().add(const LoadVotosConsolidados());
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
                  Text(state.message, textAlign: TextAlign.center, style: AppTypography.bodyMedium),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ProvincialBloc>().add(const LoadVotosConsolidados()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          if (state is VotosConsolidadosLoaded) {
            if (state.votos.isEmpty) {
              return const Center(child: Text('No hay votos registrados', style: AppTypography.bodyMedium));
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProvincialBloc>().add(const LoadVotosConsolidados());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.votos.length,
                itemBuilder: (context, index) {
                  final grupo = state.votos[index];
                  return AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.how_to_vote_rounded, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(grupo.dignidad.toUpperCase(), style: AppTypography.headingMedium.copyWith(color: AppColors.primary)),
                          ],
                        ),
                        const Divider(height: 24),
                        ...grupo.resultados.map((r) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(r.nombreOrganizacion, style: AppTypography.labelLarge),
                                        if (r.candidato.isNotEmpty)
                                          Text(r.candidato, style: AppTypography.caption),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withAlpha(15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      r.totalVotos.toString(),
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total', style: AppTypography.headingSmall),
                            Text(
                              grupo.resultados.fold<int>(0, (sum, r) => sum + r.totalVotos).toString(),
                              style: AppTypography.headingSmall,
                            ),
                          ],
                        ),
                      ],
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
