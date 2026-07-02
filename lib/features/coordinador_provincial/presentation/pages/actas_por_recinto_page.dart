import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../bloc/provincial_bloc.dart';
import '../bloc/provincial_event.dart';
import '../bloc/provincial_state.dart';
import 'detalle_acta_page.dart';

class ActasPorRecintoPage extends StatefulWidget {
  final String recintoId;
  final String recintoNombre;

  const ActasPorRecintoPage({super.key, required this.recintoId, required this.recintoNombre});

  @override
  State<ActasPorRecintoPage> createState() => _ActasPorRecintoPageState();
}

class _ActasPorRecintoPageState extends State<ActasPorRecintoPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProvincialBloc>().add(LoadActasPorRecinto(recintoId: widget.recintoId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Actas - ${widget.recintoNombre}')),
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
                    onPressed: () => context.read<ProvincialBloc>().add(LoadActasPorRecinto(recintoId: widget.recintoId)),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          if (state is ActasPorRecintoLoaded) {
            if (state.actas.isEmpty) {
              return const Center(child: Text('No hay actas registradas en este recinto', style: AppTypography.bodyMedium));
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProvincialBloc>().add(LoadActasPorRecinto(recintoId: widget.recintoId));
              },
              child: ListView.builder(
                itemCount: state.actas.length,
                itemBuilder: (context, index) {
                  final acta = state.actas[index];
                  final hasGps = acta.gpsLatitud != null;
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: hasGps ? AppColors.success.withAlpha(25) : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          hasGps ? Icons.location_on_rounded : Icons.description_rounded,
                          color: hasGps ? AppColors.success : AppColors.textTertiary,
                          size: 22,
                        ),
                      ),
                      title: Text('Mesa: ${acta.mesaId}', style: AppTypography.labelLarge),
                      subtitle: Text('${acta.dignidad} - ${acta.estado}', style: AppTypography.caption),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<ProvincialBloc>(),
                              child: DetalleActaPage(actaId: acta.id, mesaId: acta.mesaId),
                            ),
                          ),
                        );
                      },
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
