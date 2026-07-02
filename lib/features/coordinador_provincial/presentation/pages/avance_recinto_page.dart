import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../bloc/provincial_bloc.dart';
import '../bloc/provincial_event.dart';
import '../bloc/provincial_state.dart';
import 'actas_por_recinto_page.dart';

class AvanceRecintoPage extends StatefulWidget {
  final String recintoId;
  final String recintoNombre;

  const AvanceRecintoPage({super.key, required this.recintoId, required this.recintoNombre});

  @override
  State<AvanceRecintoPage> createState() => _AvanceRecintoPageState();
}

class _AvanceRecintoPageState extends State<AvanceRecintoPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProvincialBloc>().add(LoadAvanceRecinto(recintoId: widget.recintoId));
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
                  Text(state.message, textAlign: TextAlign.center, style: AppTypography.bodyMedium),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ProvincialBloc>().add(LoadAvanceRecinto(recintoId: widget.recintoId)),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          if (state is AvanceRecintoLoaded) {
            final porcentaje = state.totalMesas > 0 ? (state.actasRegistradas / state.totalMesas * 100) : 0.0;
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text('Avance del Recinto', style: AppTypography.headingMedium),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: 160,
                          height: 160,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  sectionsSpace: 4,
                                  centerSpaceRadius: 55,
                                  sections: [
                                    PieChartSectionData(
                                      value: porcentaje,
                                      color: porcentaje >= 100
                                          ? AppColors.success
                                          : AppColors.primary,
                                      showTitle: false,
                                      radius: 8,
                                    ),
                                    PieChartSectionData(
                                      value: 100 - porcentaje,
                                      color: AppColors.surfaceVariant,
                                      showTitle: false,
                                      radius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${porcentaje.toStringAsFixed(1)}%',
                                style: AppTypography.statValue,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _AvanceStat(label: 'Mesas', value: state.totalMesas.toString()),
                            _AvanceStat(label: 'Actas', value: state.actasRegistradas.toString()),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context.read<ProvincialBloc>().add(LoadAvanceRecinto(recintoId: widget.recintoId)),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Actualizar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<ProvincialBloc>(),
                                  child: ActasPorRecintoPage(recintoId: widget.recintoId, recintoNombre: widget.recintoNombre),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.list_alt_rounded, size: 18),
                          label: const Text('Ver Actas'),
                        ),
                      ),
                    ],
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
        Text(value, style: AppTypography.statValue),
        const SizedBox(height: 4),
        Text(label, style: AppTypography.statLabel),
      ],
    );
  }
}
