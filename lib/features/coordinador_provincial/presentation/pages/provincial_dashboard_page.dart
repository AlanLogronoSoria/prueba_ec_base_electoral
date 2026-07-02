import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/provincial_bloc.dart';
import 'create_coordinador_page.dart';
import 'create_recinto_page.dart';
import 'recintos_list_page.dart';
import 'votos_consolidados_page.dart';

class ProvincialDashboardPage extends StatelessWidget {
  const ProvincialDashboardPage({super.key});

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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
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
                      child: const Icon(
                        Icons.assignment_rounded,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Control Electoral',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Coordinador Provincial',
                      style: TextStyle(fontSize: 13, color: Color(0xFFBFDBFE)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Acciones', style: AppTypography.labelMedium),
              const SizedBox(height: 8),
              DashboardCard(
                icon: Icons.business_rounded,
                label: 'Gestionar Recintos',
                iconColor: AppColors.primary,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<ProvincialBloc>(),
                        child: const RecintosListPage(),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              DashboardCard(
                icon: Icons.add_location_alt_rounded,
                label: 'Crear Recinto',
                iconColor: AppColors.success,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<ProvincialBloc>(),
                        child: const CreateRecintoPage(),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              DashboardCard(
                icon: Icons.person_add_alt_rounded,
                label: 'Crear Coordinador de Recinto',
                iconColor: AppColors.accent,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<ProvincialBloc>(),
                        child: const CreateCoordinadorPage(),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              DashboardCard(
                icon: Icons.pie_chart_rounded,
                label: 'Votos Consolidados',
                iconColor: AppColors.secondary,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<ProvincialBloc>(),
                        child: const VotosConsolidadosPage(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
