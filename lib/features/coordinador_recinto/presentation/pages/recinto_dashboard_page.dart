import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            icon: const Icon(Icons.logout),
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
                  context
                      .read<RecintoBloc>()
                      .add(LoadAvance(recintoId: recintoId));
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(Icons.person,
                                size: 48, color: Colors.teal),
                            const SizedBox(height: 8),
                            Text(
                              usuario.nombreCompleto,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Coordinador de Recinto',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<RecintoBloc, RecintoState>(
                      builder: (context, state) {
                        if (state is AvanceLoaded) {
                          return Card(
                            color: Colors.teal.shade50,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _AvanceItem(
                                    label: 'Mesas',
                                    value: '${state.totalMesas}',
                                    icon: Icons.table_chart,
                                  ),
                                  _AvanceItem(
                                    label: 'Actas',
                                    value: '${state.actasRegistradas}',
                                    icon: Icons.description,
                                  ),
                                  _AvanceItem(
                                    label: 'Pendientes',
                                    value:
                                        '${state.totalMesas - state.actasRegistradas}',
                                    icon: Icons.pending,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        if (state is RecintoLoading) {
                          return const Center(
                              child: LinearProgressIndicator());
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 24),
                    _DashboardButton(
                      icon: Icons.table_chart,
                      label: 'Gestionar Mesas',
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
                    const SizedBox(height: 12),
                    _DashboardButton(
                      icon: Icons.person_add,
                      label: 'Crear Veedor',
                      onTap: () {
                        if (recintoId == null) return;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<RecintoBloc>(),
                              child: CreateVeedorPage(
                                  recintoId: recintoId),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _DashboardButton(
                      icon: Icons.search,
                      label: 'Buscar Mesa por JRV',
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

  void _showBuscarMesaDialog(
      BuildContext context, String recintoId) {
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

class _AvanceItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _AvanceItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.teal, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
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
        leading: Icon(icon, size: 32, color: Colors.teal),
        title: Text(label, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
