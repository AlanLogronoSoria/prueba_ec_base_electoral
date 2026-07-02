import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/provincial_bloc.dart';
import '../bloc/provincial_event.dart';
import '../bloc/provincial_state.dart';
import 'actas_por_recinto_page.dart';
import 'avance_recinto_page.dart';
import 'create_coordinador_page.dart';
import 'create_recinto_page.dart';
import 'recintos_list_page.dart';
import 'votos_consolidados_page.dart';

class ProvincialDashboardPage extends StatefulWidget {
  const ProvincialDashboardPage({super.key});

  @override
  State<ProvincialDashboardPage> createState() =>
      _ProvincialDashboardPageState();
}

class _ProvincialDashboardPageState extends State<ProvincialDashboardPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    context.read<ProvincialBloc>().add(const LoadRecintos());
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
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
        title: const Text('Panel Provincial'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, size: 20),
            onPressed: () {
              context.read<AuthBloc>().add(const LogoutRequested());
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeroHeader(),
                const SizedBox(height: 24),
                _buildQuickStats(context),
                const SizedBox(height: 28),
                _buildSectionHeader('Gestión Electoral'),
                const SizedBox(height: 10),
                _buildActionCard(
                  icon: Icons.business_rounded,
                  label: 'Gestionar Recintos',
                  subtitle: 'Ver, crear y administrar recintos electorales',
                  iconColor: AppColors.primary,
                  onTap: () => _navigate(context, const RecintosListPage()),
                ),
                const SizedBox(height: 8),
                _buildActionCard(
                  icon: Icons.add_location_alt_rounded,
                  label: 'Crear Recinto',
                  subtitle: 'Registrar un nuevo recinto electoral',
                  iconColor: AppColors.success,
                  onTap: () => _navigate(context, const CreateRecintoPage()),
                ),
                const SizedBox(height: 8),
                _buildActionCard(
                  icon: Icons.person_add_alt_rounded,
                  label: 'Crear Coordinador de Recinto',
                  subtitle: 'Asignar coordinador a un recinto',
                  iconColor: AppColors.accent,
                  onTap: () =>
                      _navigate(context, const CreateCoordinadorPage()),
                ),
                const SizedBox(height: 8),
                _buildActionCard(
                  icon: Icons.pie_chart_rounded,
                  label: 'Votos Consolidados',
                  subtitle: 'Ver resultados totalizados por dignidad',
                  iconColor: AppColors.secondary,
                  onTap: () =>
                      _navigate(context, const VotosConsolidadosPage()),
                ),
                const SizedBox(height: 8),
                _buildActionCard(
                  icon: Icons.trending_up_rounded,
                  label: 'Avance de Recinto',
                  subtitle: 'Ver progreso de actas registradas',
                  iconColor: AppColors.info,
                  onTap: () => _showRecintoPicker(
                    onSelected: (id, nombre) => _navigate(context,
                        AvanceRecintoPage(
                            recintoId: id, recintoNombre: nombre)),
                  ),
                ),
                const SizedBox(height: 8),
                _buildActionCard(
                  icon: Icons.location_on_rounded,
                  label: 'Actas por Recinto',
                  subtitle: 'Ver actas enviadas con ubicacion GPS',
                  iconColor: AppColors.warning,
                  onTap: () => _showRecintoPicker(
                    onSelected: (id, nombre) => _navigate(context,
                        ActasPorRecintoPage(
                            recintoId: id, recintoNombre: nombre)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ProvincialBloc>(),
          child: page,
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
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
              Icons.how_to_vote_rounded,
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
                  'Control Electoral',
                  style: AppTypography.plusJakarta(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withAlpha(180),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'COORDINADOR PROVINCIAL',
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppCard(
            onTap: () => _navigate(context, const RecintosListPage()),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
            child: Column(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(40),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.business_rounded,
                      color: AppColors.primary, size: 22),
                ),
                const SizedBox(height: 10),
                Text('Recintos', style: AppTypography.statValue),
                const SizedBox(height: 2),
                Text('Gestión', style: AppTypography.statLabel),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppCard(
            onTap: () =>
                _navigate(context, const VotosConsolidadosPage()),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
            child: Column(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withAlpha(40),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.bar_chart_rounded,
                      color: AppColors.secondary, size: 22),
                ),
                const SizedBox(height: 10),
                Text('Votos', style: AppTypography.statValue),
                const SizedBox(height: 2),
                Text('Consolidados', style: AppTypography.statLabel),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppCard(
            onTap: () =>
                _navigate(context, const CreateCoordinadorPage()),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
            child: Column(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withAlpha(40),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.people_rounded,
                      color: AppColors.accent, size: 22),
                ),
                const SizedBox(height: 10),
                Text('Coord.', style: AppTypography.statValue),
                const SizedBox(height: 2),
                Text('Asignar', style: AppTypography.statLabel),
              ],
            ),
          ),
        ),
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
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

  void _showRecintoPicker({
    required void Function(String id, String nombre) onSelected,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => BlocBuilder<ProvincialBloc, ProvincialState>(
        builder: (context, state) {
          if (state is ProvincialLoading) {
            return const AlertDialog(
              content: SizedBox(
                height: 60,
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }
          if (state is RecintosLoaded) {
            if (state.recintos.isEmpty) {
              return AlertDialog(
                title: const Text('Sin recintos'),
                content:
                    const Text('No hay recintos registrados.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cerrar'),
                  ),
                ],
              );
            }
            return AlertDialog(
              title: const Text('Seleccionar Recinto'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.recintos.length,
                  itemBuilder: (_, i) {
                    final r = state.recintos[i];
                    return ListTile(
                      title: Text(r.nombre),
                      subtitle:
                          Text('${r.canton} - ${r.parroquia}'),
                      onTap: () {
                        Navigator.pop(ctx);
                        onSelected(r.id, r.nombre);
                      },
                    );
                  },
                ),
              ),
            );
          }
          return const AlertDialog(
            content: Text('Cargando...'),
          );
        },
      ),
    );
  }
}
