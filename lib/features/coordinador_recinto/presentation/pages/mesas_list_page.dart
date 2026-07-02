import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/status_badge.dart';
import '../bloc/recinto_bloc.dart';
import '../bloc/recinto_event.dart';
import '../bloc/recinto_state.dart';
import 'detalle_mesa_page.dart';

class MesasListPage extends StatefulWidget {
  final String recintoId;

  const MesasListPage({super.key, required this.recintoId});

  @override
  State<MesasListPage> createState() => _MesasListPageState();
}

class _MesasListPageState extends State<MesasListPage> {
  @override
  void initState() {
    super.initState();
    context.read<RecintoBloc>().add(LoadMesas(recintoId: widget.recintoId));
  }

  void _showAsignarVeedorDialog(String mesaId) {
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              context.read<RecintoBloc>().add(AsignarVeedor(mesaId: mesaId, veedorCedula: cedulaController.text.trim()));
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
      appBar: AppBar(title: const Text('Mesas del Recinto')),
      body: BlocConsumer<RecintoBloc, RecintoState>(
        listener: (context, state) {
          if (state is VeedorAsignado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Veedor asignado correctamente'), backgroundColor: Colors.green),
            );
            context.read<RecintoBloc>().add(LoadMesas(recintoId: widget.recintoId));
          }
          if (state is RecintoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is RecintoLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is RecintoError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, textAlign: TextAlign.center, style: AppTypography.bodyMedium),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<RecintoBloc>().add(LoadMesas(recintoId: widget.recintoId)),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          if (state is MesasLoaded) {
            if (state.mesas.isEmpty) {
              return Center(child: Text('No hay mesas registradas en este recinto', style: AppTypography.bodyMedium));
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<RecintoBloc>().add(LoadMesas(recintoId: widget.recintoId));
              },
              child: ListView.builder(
                itemCount: state.mesas.length,
                itemBuilder: (context, index) {
                  final mesa = state.mesas[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: mesa.hasActa ? AppColors.success.withAlpha(25) : AppColors.warning.withAlpha(25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          mesa.hasActa ? Icons.check_circle_rounded : Icons.cancel_rounded,
                          color: mesa.hasActa ? AppColors.success : AppColors.warning,
                          size: 24,
                        ),
                      ),
                      title: Text('JRV ${mesa.numeroJrv}', style: AppTypography.labelLarge),
                      subtitle: mesa.hasActa
                          ? StatusBadge.completed(label: 'Con acta')
                          : StatusBadge.pending(label: 'Sin acta'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.person_add_alt_rounded, size: 20, color: AppColors.textSecondary),
                            tooltip: 'Reasignar veedor',
                            onPressed: () => _showAsignarVeedorDialog(mesa.id),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.surfaceVariant,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.visibility_rounded, size: 20, color: AppColors.textSecondary),
                            tooltip: 'Ver detalle',
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<RecintoBloc>(),
                                    child: DetalleMesaPage(recintoId: widget.recintoId, mesaId: mesa.id, numeroJrv: mesa.numeroJrv),
                                  ),
                                ),
                              );
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.surfaceVariant,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
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
