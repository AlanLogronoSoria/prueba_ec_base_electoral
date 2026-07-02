import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                          Icons.sync,
                          color: conectado ? Colors.orange : Colors.grey,
                        ),
                      ),
                    )
                  else
                    Icon(
                      Icons.cloud_done,
                      color: conectado ? Colors.green : Colors.grey,
                    ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      context
                          .read<AuthBloc>()
                          .add(const LogoutRequested());
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
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.visibility,
                              size: 48, color: Colors.green),
                          const SizedBox(height: 8),
                          Text(
                            usuario.nombreCompleto,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Veedor',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<SyncBloc, SyncState>(
                    builder: (context, syncState) {
                      if (syncState is SyncIdle &&
                          syncState.pendientesCount > 0) {
                        return Card(
                          color: Colors.orange.shade50,
                          child: ListTile(
                            leading: const Icon(Icons.sync,
                                color: Colors.orange),
                            title: Text(
                              '${syncState.pendientesCount} acta(s) pendiente(s) de sincronización',
                              style: const TextStyle(fontSize: 13),
                            ),
                            subtitle: syncState.conflictosCount > 0
                                ? Text(
                                    '${syncState.conflictosCount} con conflicto',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  )
                                : null,
                            trailing: syncState.isConnected
                                ? TextButton(
                                    onPressed: () => context
                                        .read<SyncBloc>()
                                        .add(const StartSync()),
                                    child: const Text('Sincronizar'),
                                  )
                                : const Icon(Icons.wifi_off,
                                    color: Colors.grey),
                          ),
                        );
                      }
                      if (syncState is SyncInProgress) {
                        return Card(
                          child: ListTile(
                            leading: const CircularProgressIndicator(
                                strokeWidth: 2),
                            title: Text(
                              'Sincronizando... ${syncState.procesados}/${syncState.total}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        );
                      }
                      if (syncState is SyncCompletado) {
                        return Card(
                          color: Colors.green.shade50,
                          child: ListTile(
                            leading: const Icon(Icons.check_circle,
                                color: Colors.green),
                            title: Text(
                              '${syncState.sincronizados} sincronizado(s), ${syncState.conflictos} conflicto(s)',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        );
                      }
                      if (syncState is SyncError) {
                        return Card(
                          color: Colors.red.shade50,
                          child: ListTile(
                            leading: const Icon(Icons.error,
                                color: Colors.red),
                            title: Text(
                              syncState.message,
                              style:
                                  const TextStyle(fontSize: 13),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 8),
                  _DashboardButton(
                    icon: Icons.table_chart,
                    label: 'Mis Mesas',
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
                  const SizedBox(height: 12),
                  _DashboardButton(
                    icon: Icons.note_add,
                    label: 'Registrar Acta',
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
        leading: Icon(icon, size: 32, color: Colors.green),
        title: Text(label, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
