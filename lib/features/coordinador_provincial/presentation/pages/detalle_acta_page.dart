import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../bloc/provincial_bloc.dart';
import '../bloc/provincial_event.dart';
import '../bloc/provincial_state.dart';

class DetalleActaPage extends StatefulWidget {
  final String actaId;
  final String mesaId;

  const DetalleActaPage({super.key, required this.actaId, required this.mesaId});

  @override
  State<DetalleActaPage> createState() => _DetalleActaPageState();
}

class _DetalleActaPageState extends State<DetalleActaPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProvincialBloc>().add(LoadDetalleActa(actaId: widget.actaId, mesaId: widget.mesaId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Acta')),
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
                    onPressed: () => context.read<ProvincialBloc>().add(LoadDetalleActa(actaId: widget.actaId, mesaId: widget.mesaId)),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          if (state is DetalleActaLoaded) {
            final detalle = state.detalle;
            final acta = detalle.acta;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Información del Acta', style: AppTypography.headingMedium),
                        const SizedBox(height: 12),
                        _InfoRow(label: 'Mesa JRV', value: detalle.mesaNumero),
                        _InfoRow(label: 'Dignidad', value: acta.dignidad),
                        _InfoRow(label: 'Estado', value: acta.estado),
                        _InfoRow(label: 'Total Sufragantes', value: acta.totalSufragantes.toString()),
                        _InfoRow(label: 'Votos Válidos', value: acta.votosValidos.toString()),
                        _InfoRow(label: 'Votos Nulos', value: acta.votosNulos.toString()),
                        _InfoRow(label: 'Votos Blancos', value: acta.votosBlancos.toString()),
                        if (acta.updatedAt != null)
                          _InfoRow(
                            label: 'Actualizado',
                            value: '${acta.updatedAt!.day}/${acta.updatedAt!.month}/${acta.updatedAt!.year} ${acta.updatedAt!.hour}:${acta.updatedAt!.minute.toString().padLeft(2, '0')}',
                          ),
                      ],
                    ),
                  ),
                  if (acta.gpsLatitud != null && acta.gpsLongitud != null) ...[
                    const SizedBox(height: 16),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ubicación GPS', style: AppTypography.headingMedium),
                          const SizedBox(height: 12),
                          _InfoRow(label: 'Latitud', value: acta.gpsLatitud!.toStringAsFixed(6)),
                          _InfoRow(label: 'Longitud', value: acta.gpsLongitud!.toStringAsFixed(6)),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            height: 180,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.location_on_rounded, size: 48, color: AppColors.error),
                                const SizedBox(height: 8),
                                Text(
                                  '${acta.gpsLatitud!.toStringAsFixed(6)}, ${acta.gpsLongitud!.toStringAsFixed(6)}',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.bodySmall,
                                ),
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                                  label: const Text('Ver en Google Maps'),
                                  onPressed: () => _openGoogleMaps(acta.gpsLatitud!, acta.gpsLongitud!),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Votos por Organización', style: AppTypography.headingMedium),
                        const SizedBox(height: 12),
                        ...detalle.votos.map((voto) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(voto.nombreOrganizacion, style: AppTypography.labelLarge),
                                        if (voto.candidato.isNotEmpty)
                                          Text(voto.candidato, style: AppTypography.caption),
                                      ],
                                    ),
                                  ),
                                  Text(voto.votos.toString(), style: AppTypography.statValue.copyWith(fontSize: 18)),
                                ],
                              ),
                            )),
                      ],
                    ),
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

  void _openGoogleMaps(double lat, double lng) {
    final url = 'https://www.google.com/maps?q=$lat,$lng';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Abrir mapa: $url'), duration: const Duration(seconds: 3)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.caption),
          Text(value, style: AppTypography.labelLarge),
        ],
      ),
    );
  }
}
