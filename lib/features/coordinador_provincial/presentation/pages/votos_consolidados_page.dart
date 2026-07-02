import 'package:fl_chart/fl_chart.dart';
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
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.how_to_vote_rounded, size: 80, color: AppColors.textTertiary.withAlpha(60)),
                    const SizedBox(height: 16),
                    Text('Aún no hay actas registradas', style: AppTypography.bodyLarge),
                    const SizedBox(height: 8),
                    Text('Los resultados aparecerán cuando se registren actas', style: AppTypography.caption),
                  ],
                ),
              );
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
                  final maxVotos = grupo.resultados
                      .fold<int>(0, (max, r) => r.totalVotos > max ? r.totalVotos : max)
                      .toDouble();
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
                            Text(grupo.dignidad.toUpperCase(),
                                style: AppTypography.headingMedium.copyWith(color: AppColors.primary)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: grupo.resultados.length * 44.0,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.center,
                              maxY: maxVotos * 1.2,
                              barTouchData: BarTouchData(
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                    return BarTooltipItem(
                                      '${rod.toY.toInt()} votos',
                                      const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                    );
                                  },
                                ),
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final idx = value.toInt();
                                      if (idx < 0 || idx >= grupo.resultados.length) {
                                        return const SizedBox.shrink();
                                      }
                                      final nombre = grupo.resultados[idx].nombreOrganizacion;
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          nombre.length > 12 ? '${nombre.substring(0, 10)}...' : nombre,
                                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              barGroups: grupo.resultados.asMap().entries.map((entry) {
                                final colorIndex = entry.key % _barColors.length;
                                return BarChartGroupData(
                                  x: entry.key,
                                  barRods: [
                                    BarChartRodData(
                                      toY: entry.value.totalVotos.toDouble(),
                                      color: _barColors[colorIndex],
                                      width: 24,
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total', style: AppTypography.headingSmall),
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

const _barColors = [
  Color(0xFF0D47A1),
  Color(0xFF1976D2),
  Color(0xFF42A5F5),
  Color(0xFF90CAF9),
  Color(0xFF1565C0),
  Color(0xFF2196F3),
  Color(0xFF64B5F6),
  Color(0xFFBBDEFB),
  Color(0xFF1E88E5),
  Color(0xFF0D47A1),
];
