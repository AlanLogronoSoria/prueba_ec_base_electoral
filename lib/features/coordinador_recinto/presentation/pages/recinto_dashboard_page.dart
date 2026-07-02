import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/recinto_bloc.dart';
import '../bloc/recinto_event.dart';
import '../bloc/recinto_state.dart';
import 'create_veedor_page.dart';
import 'detalle_mesa_page.dart';
import 'mesas_list_page.dart';

class RecintoDashboardPage extends StatefulWidget {
  const RecintoDashboardPage({super.key});

  @override
  State<RecintoDashboardPage> createState() => _RecintoDashboardPageState();
}

class _RecintoDashboardPageState extends State<RecintoDashboardPage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final recintoId = authState.usuario.recintoId;
      if (recintoId != null) {
        context.read<RecintoBloc>().add(LoadAvance(recintoId: recintoId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Recinto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, size: 20),
            onPressed: () {
              context.read<AuthBloc>().add(const LogoutRequested());
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            final usuario = authState.usuario;
            final recintoId = usuario.recintoId;
            return RefreshIndicator(
              onRefresh: () async {
                if (recintoId != null) {
                  context.read<RecintoBloc>().add(LoadAvance(recintoId: recintoId));
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppCard(
                      backgroundColor: AppColors.primary,
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(30),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.person_rounded, size: 32, color: Colors.white),
                          ),
                          Text(
                            usuario.nombreCompleto,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Coordinador de Recinto',
                            style: TextStyle(fontSize: 13, color: Color(0xFFBFDBFE)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<RecintoBloc, RecintoState>(
                      builder: (context, state) {
                        if (state is AvanceLoaded) {
                          return AppCard(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                StatCard(
                                  label: 'Mesas',
                                  value: '${state.totalMesas}',
                                  icon: Icons.table_chart_rounded,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 12),
                                StatCard(
                                  label: 'Actas',
                                  value: '${state.actasRegistradas}',
                                  icon: Icons.description_rounded,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 12),
                                StatCard(
                                  label: 'Pendientes',
                                  value: '${state.totalMesas - state.actasRegistradas}',
                                  icon: Icons.pending_rounded,
                                  color: AppColors.warning,
                                ),
                              ],
                            ),
                          );
                        }
                        if (state is RecintoLoading) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: LinearProgressIndicator(),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text('Acciones', style: AppTypography.labelMedium),
                    const SizedBox(height: 8),
                    DashboardCard(
                      icon: Icons.table_chart_rounded,
                      label: 'Gestionar Mesas',
                      iconColor: AppColors.primary,
                      onTap: () {
                        if (recintoId == null) return;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<RecintoBloc>(),
                              child: MesasListPage(recintoId: recintoId),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    DashboardCard(
                      icon: Icons.person_add_alt_rounded,
                      label: 'Crear Veedor',
                      iconColor: AppColors.success,
                      onTap: () {
                        if (recintoId == null) return;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<RecintoBloc>(),
                              child: CreateVeedorPage(recintoId: recintoId),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    DashboardCard(
                      icon: Icons.search_rounded,
                      label: 'Buscar Mesa por JRV',
                      iconColor: AppColors.secondary,
                      onTap: () {
                        if (recintoId == null) return;
                        _showBuscarMesaDialog(context, recintoId);
                      },
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showBuscarMesaDialog(BuildContext context, String recintoId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Buscar Mesa'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Número de JRV',
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
              Navigator.pop(ctx);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<RecintoBloc>(),
                    child: DetalleMesaPage(
                      recintoId: recintoId,
                      numeroJrv: controller.text.trim(),
                    ),
                  ),
                ),
              );
            },
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }
}
