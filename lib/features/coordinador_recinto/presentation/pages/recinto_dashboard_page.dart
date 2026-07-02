import 'package:fl_chart/fl_chart.dart';
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

class _RecintoDashboardPageState extends State<RecintoDashboardPage>
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

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final recintoId = authState.usuario.recintoId;
      if (recintoId != null) {
        context.read<RecintoBloc>().add(LoadAvance(recintoId: recintoId));
      }
    }
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
            return FadeTransition(
              opacity: _fadeAnim,
              child: RefreshIndicator(
                onRefresh: () async {
                  if (recintoId != null) {
                    context
                        .read<RecintoBloc>()
                        .add(LoadAvance(recintoId: recintoId));
                  }
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeroHeader(usuario.nombreCompleto),
                      const SizedBox(height: 20),
                      _buildSectionHeader('Estadisticas'),
                      const SizedBox(height: 8),
                      _buildStatsSection(),
                      const SizedBox(height: 28),
                      _buildSectionHeader('Acciones'),
                      const SizedBox(height: 10),
                      _buildActionCard(
                        icon: Icons.table_chart_rounded,
                        label: 'Gestionar Mesas',
                        subtitle: 'Ver y administrar las JRV del recinto',
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
                      _buildActionCard(
                        icon: Icons.add_chart_rounded,
                        label: 'Crear Mesa',
                        subtitle: 'Agregar una nueva JRV al recinto',
                        iconColor: AppColors.accent,
                        onTap: () {
                          if (recintoId == null) return;
                          _showCrearMesaSheet(context, recintoId);
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildActionCard(
                        icon: Icons.person_add_alt_rounded,
                        label: 'Crear Veedor',
                        subtitle: 'Registrar nuevo veedor y asignar a mesa',
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
                      _buildActionCard(
                        icon: Icons.search_rounded,
                        label: 'Buscar Mesa por JRV',
                        subtitle: 'Localizar una mesa especifica por numero',
                        iconColor: AppColors.secondary,
                        onTap: () {
                          if (recintoId == null) return;
                          _showBuscarMesaDialog(context, recintoId);
                        },
                      ),
                    ],
                  ),
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
      backgroundColor: AppColors.primary,
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
              Icons.location_city_rounded,
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
                    color: AppColors.accent.withAlpha(180),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'COORDINADOR DE RECINTO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.2,
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

  Widget _buildStatsSection() {
    return BlocBuilder<RecintoBloc, RecintoState>(
      builder: (context, state) {
        if (state is AvanceLoaded) {
          final pendientes = state.totalMesas - state.actasRegistradas;
          final porcentaje = state.totalMesas > 0
              ? (state.actasRegistradas / state.totalMesas * 100)
                  .toStringAsFixed(0)
              : '0';

          return Column(
            children: [
              Row(
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
                    value: '$pendientes',
                    icon: Icons.pending_rounded,
                    color: AppColors.warning,
                  ),
                ],
              ),
              if (state.totalMesas > 0) ...[
                const SizedBox(height: 16),
                AppCard(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.pie_chart_rounded,
                              size: 16, color: AppColors.primaryLight),
                          const SizedBox(width: 6),
                          Text(
                            'Avance: $porcentaje%',
                            style: AppTypography.labelLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 160,
                        child: Row(
                          children: [
                            Expanded(
                              child: PieChart(
                                PieChartData(
                                  centerSpaceRadius: 36,
                                  sectionsSpace: 3,
                                  sections: [
                                    PieChartSectionData(
                                      value:
                                          state.actasRegistradas.toDouble(),
                                      color: AppColors.success,
                                      title:
                                          '${state.actasRegistradas}',
                                      radius: 40,
                                      titleStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    if (pendientes > 0)
                                      PieChartSectionData(
                                        value: pendientes.toDouble(),
                                        color: AppColors.warning,
                                        title: '$pendientes',
                                        radius: 40,
                                        titleStyle: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLegend(
                                    'Completadas', AppColors.success),
                                const SizedBox(height: 8),
                                _buildLegend(
                                    'Pendientes', AppColors.warning),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight
                                        .withAlpha(30),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$porcentaje% completado',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        }
        if (state is RecintoLoading) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: LinearProgressIndicator(),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTypography.caption),
      ],
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

  void _showCrearMesaSheet(BuildContext context, String recintoId) {
    final jrvController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocListener<RecintoBloc, RecintoState>(
        listener: (context, state) {
          if (state is MesaCreada) {
            Navigator.pop(ctx);
            context.read<RecintoBloc>().add(LoadMesas(recintoId: recintoId));
            context
                .read<RecintoBloc>()
                .add(LoadAvance(recintoId: recintoId));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Mesa creada exitosamente'),
                  backgroundColor: AppColors.success),
            );
          }
          if (state is RecintoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary.withAlpha(80),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withAlpha(40),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.table_chart_rounded,
                        color: AppColors.accent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text('Nueva Mesa JRV', style: AppTypography.headingMedium),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: jrvController,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Numero de JRV',
                  hintText: 'Ej: 4',
                  prefixIcon: Icon(Icons.pin_rounded, size: 20),
                ),
              ),
              const SizedBox(height: 24),
              BlocBuilder<RecintoBloc, RecintoState>(
                builder: (context, state) {
                  return FilledButton.icon(
                    onPressed: state is RecintoLoading
                        ? null
                        : () {
                            final jrv = jrvController.text.trim();
                            if (jrv.isEmpty) return;
                            context.read<RecintoBloc>().add(
                                  CrearMesa(
                                      recintoId: recintoId,
                                      numeroJrv: jrv),
                                );
                          },
                    icon: state is RecintoLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.add_rounded, size: 20),
                    label: Text(state is RecintoLoading
                        ? 'Creando...'
                        : 'Crear Mesa'),
                  );
                },
              ),
            ],
          ),
        ),
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
            labelText: 'Numero de JRV',
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
