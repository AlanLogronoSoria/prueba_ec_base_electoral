import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/veedor_bloc.dart';
import '../bloc/veedor_event.dart';
import '../bloc/veedor_state.dart';

class MisMesasPage extends StatefulWidget {
  const MisMesasPage({super.key});

  @override
  State<MisMesasPage> createState() => _MisMesasPageState();
}

class _MisMesasPageState extends State<MisMesasPage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context
          .read<VeedorBloc>()
          .add(LoadMesasVeedor(veedorId: authState.usuario.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Mesas')),
      body: BlocBuilder<VeedorBloc, VeedorState>(
        builder: (context, state) {
          if (state is VeedorLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is VeedorError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final authState =
                          context.read<AuthBloc>().state;
                      if (authState is AuthAuthenticated) {
                        context.read<VeedorBloc>().add(
                              LoadMesasVeedor(
                                  veedorId: authState.usuario.id),
                            );
                      }
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          if (state is MesasVeedorLoaded) {
            if (state.mesas.isEmpty) {
              return const Center(
                child: Text('No tienes mesas asignadas'),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  context.read<VeedorBloc>().add(
                        LoadMesasVeedor(veedorId: authState.usuario.id),
                      );
                }
              },
              child: ListView.builder(
                itemCount: state.mesas.length,
                itemBuilder: (context, index) {
                  final item = state.mesas[index];
                  final mesa = item['mesa'] as Map<String, dynamic>;
                  final recinto =
                      item['recinto'] as Map<String, dynamic>;
                  final actas = item['actas'] as List;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ExpansionTile(
                      title: Text('JRV ${mesa['numero_jrv']}'),
                      subtitle: Text(recinto['nombre'] as String),
                      children: [
                        if (actas.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Sin actas registradas',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        else
                          ...actas.map(
                            (acta) => ListTile(
                              title: Text(
                                  'Acta: ${acta['dignidad']}'),
                              subtitle: Text(
                                'Total: ${acta['total_sufragantes']}',
                              ),
                            ),
                          ),
                      ],
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
