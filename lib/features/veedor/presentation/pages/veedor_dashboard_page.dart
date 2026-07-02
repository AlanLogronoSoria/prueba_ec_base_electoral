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

class VeedorDashboardPage extends StatefulWidget {
  const VeedorDashboardPage({super.key});

  @override
  State<VeedorDashboardPage> createState() => _VeedorDashboardPageState();
}

class _VeedorDashboardPageState extends State<VeedorDashboardPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

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
                          color: conectado
                              ? AppColors.warning
                              : AppColors.textTertiary,
                          size: 20,
                        ),
                      ),
                    )
                  else
                    Icon(
                      Icons.cloud_done_rounded,
                      color: conectado
                          ? AppColors.success
                          : AppColors.textTertiary,
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
            return FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeroHeader(usuario.nombreCompleto),
                    const SizedBox(height: 20),
                    _buildSyncSection(),
                    const SizedBox(height: 28),
                    _buildSectionHeader('Acciones'),
                    const SizedBox(height: 10),
                    _buildActionCard(
                      icon: Icons.table_chart_rounded,
                      label: 'Mis Mesas',
                      subtitle:
                          'Ver las mesas que tienes asignadas como veedor',
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
                    _buildActionCard(
                      icon: Icons.note_add_rounded,
                      label: 'Registrar Acta',
                      subtitle:
                          'Capturar los votos de una mesa con foto y GPS',
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
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHeroHeader(String nombre) {
    return AppCard(
      backgroundColor: AppColors.success,
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.visibility_rounded,
              size: 36,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: AppTypography.plusJakarta(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'VEEDOR',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncSection() {
    return BlocBuilder<SyncBloc, SyncState>(
      builder: (context, syncState) {
        if (syncState is SyncIdle && syncState.pendientesCount > 0) {
          return AppCard(
            backgroundColor: AppColors.warningLight,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withAlpha(40),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.sync_rounded,
                      color: AppColors.warning, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${syncState.pendientesCount} acta(s) pendiente(s)',
                        style: AppTypography.labelLarge,
                      ),
                      if (syncState.conflictosCount > 0)
                        Text(
                          '${syncState.conflictosCount} con conflicto',
                          style: const TextStyle(
                              color: AppColors.error, fontSize: 12),
                        ),
                    ],
                  ),
                ),
                syncState.isConnected
                    ? TextButton(
                        onPressed: () =>
                            context.read<SyncBloc>().add(const StartSync()),
                        child: const Text('Sincronizar'),
                      )
                    : const Icon(Icons.wifi_off_rounded,
                        color: AppColors.textTertiary),
              ],
            ),
          );
        }
        if (syncState is SyncInProgress) {
          return AppCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text(
                  'Sincronizando... ${syncState.procesados}/${syncState.total}',
                  style: AppTypography.labelMedium,
                ),
              ],
            ),
          );
        }
        if (syncState is SyncCompletado) {
          return AppCard(
            backgroundColor: AppColors.successLight,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(40),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.check_circle_rounded,
                      color: AppColors.success, size: 24),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${syncState.sincronizados} sincronizado(s)',
                      style: AppTypography.labelMedium,
                    ),
                    if (syncState.conflictos > 0)
                      Text(
                        '${syncState.conflictos} conflicto(s)',
                        style: const TextStyle(
                            color: AppColors.error, fontSize: 12),
                      ),
                  ],
                ),
              ],
            ),
          );
        }
        if (syncState is SyncError) {
          return AppCard(
            backgroundColor: AppColors.errorLight,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Icon(Icons.error_rounded,
                    color: AppColors.error, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child:
                      Text(syncState.message, style: AppTypography.labelMedium),
                ),
              ],
            ),
          );
        }
        if (syncState is SyncPartialError) {
          return AppCard(
            backgroundColor: AppColors.warningLight,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Icon(Icons.sync_problem_rounded,
                    color: AppColors.warning, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${syncState.pendientes} pendiente(s) - ${syncState.errores} error(es)',
                        style: AppTypography.labelMedium,
                      ),
                      Text(syncState.motivo, style: AppTypography.caption),
                    ],
                  ),
                ),
                if (syncState.pendientes > 0)
                  TextButton(
                    onPressed: () =>
                        context.read<SyncBloc>().add(const StartSync()),
                    child: const Text('Reintentar'),
                  ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textTertiary,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(35),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.labelLarge),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTypography.caption),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: AppColors.textTertiary, size: 22),
        ],
      ),
    );
  }
}
