import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/veedor_bloc.dart';
import '../sync/sync_bloc.dart';
import '../sync/sync_event.dart';
import '../sync/sync_state.dart';
import 'mis_mesas_page.dart';
import 'registrar_acta_page.dart';

class VeedorDashboardPage extends StatelessWidget {
  const VeedorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Veedor'),
        actions: [
          BlocBuilder<SyncBloc, SyncState>(
            builder: (context, syncState) {
              int pendientes = 0;
              bool conectado = true;
              if (syncState is SyncIdle) {
                pendientes = syncState.pendientesCount;
                conectado = syncState.isConnected;
              }
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (pendientes > 0)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Badge(
                        label: Text('$pendientes'),
                        child: Icon(
                          Icons.sync_rounded,
                          color: conectado ? AppColors.warning : AppColors.textTertiary,
                          size: 20,
                        ),
                      ),
                    )
                  else
                    Icon(
                      Icons.cloud_done_rounded,
                      color: conectado ? AppColors.success : AppColors.textTertiary,
                      size: 20,
                    ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, size: 20),
                    onPressed: () {
                      context.read<AuthBloc>().add(const LogoutRequested());
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            final usuario = authState.usuario;
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    backgroundColor: AppColors.success,
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
                          child: const Icon(Icons.visibility_rounded, size: 32, color: Colors.white),
                        ),
                        Text(
                          usuario.nombreCompleto,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Veedor',
                          style: TextStyle(fontSize: 13, color: Color(0xFFA7F3D0)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<SyncBloc, SyncState>(
                    builder: (context, syncState) {
                      if (syncState is SyncIdle && syncState.pendientesCount > 0) {
                        return AppCard(
                          backgroundColor: AppColors.warningLight,
                          child: ListTile(
                            leading: const Icon(Icons.sync_rounded, color: AppColors.warning),
                            title: Text(
                              '${syncState.pendientesCount} acta(s) pendiente(s) de sincronización',
                              style: AppTypography.labelMedium,
                            ),
                            subtitle: syncState.conflictosCount > 0
                                ? Text(
                                    '${syncState.conflictosCount} con conflicto',
                                    style: const TextStyle(color: AppColors.error, fontSize: 12),
                                  )
                                : null,
                            trailing: syncState.isConnected
                                ? TextButton(
                                    onPressed: () => context.read<SyncBloc>().add(const StartSync()),
                                    child: const Text('Sincronizar'),
                                  )
                                : const Icon(Icons.wifi_off_rounded, color: AppColors.textTertiary),
                          ),
                        );
                      }
                      if (syncState is SyncInProgress) {
                        return AppCard(
                          child: ListTile(
                            leading: const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            title: Text(
                              'Sincronizando... ${syncState.procesados}/${syncState.total}',
                              style: AppTypography.labelMedium,
                            ),
                          ),
                        );
                      }
                      if (syncState is SyncCompletado) {
                        return AppCard(
                          backgroundColor: AppColors.successLight,
                          child: ListTile(
                            leading: const Icon(Icons.check_circle_rounded, color: AppColors.success),
                            title: Text(
                              '${syncState.sincronizados} sincronizado(s), ${syncState.conflictos} conflicto(s)',
                              style: AppTypography.labelMedium,
                            ),
                          ),
                        );
                      }
                      if (syncState is SyncError) {
                        return AppCard(
                          backgroundColor: AppColors.errorLight,
                          child: ListTile(
                            leading: const Icon(Icons.error_rounded, color: AppColors.error),
                            title: Text(syncState.message, style: AppTypography.labelMedium),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 20),
                  Text('Acciones', style: AppTypography.labelMedium),
                  const SizedBox(height: 8),
                  DashboardCard(
                    icon: Icons.table_chart_rounded,
                    label: 'Mis Mesas',
                    iconColor: AppColors.primary,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<VeedorBloc>(),
                            child: const MisMesasPage(),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  DashboardCard(
                    icon: Icons.note_add_rounded,
                    label: 'Registrar Acta',
                    iconColor: AppColors.success,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<VeedorBloc>(),
                            child: const RegistrarActaPage(),
                          ),
                        ),
                      );
                    },
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
