import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            icon: const Icon(Icons.logout),
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.assignment, size: 48, color: Colors.blue),
                      const SizedBox(height: 8),
                      const Text(
                        'Control Electoral',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Coordinador Provincial',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _DashboardButton(
                icon: Icons.business,
                label: 'Gestionar Recintos',
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
              const SizedBox(height: 12),
              _DashboardButton(
                icon: Icons.add_location,
                label: 'Crear Recinto',
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
              const SizedBox(height: 12),
              _DashboardButton(
                icon: Icons.person_add,
                label: 'Crear Coordinador de Recinto',
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
              const SizedBox(height: 12),
              _DashboardButton(
                icon: Icons.pie_chart,
                label: 'Votos Consolidados',
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

class _DashboardButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DashboardButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32, color: Colors.blue),
        title: Text(label, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
