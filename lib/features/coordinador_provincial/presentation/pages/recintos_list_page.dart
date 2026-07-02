import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../bloc/provincial_bloc.dart';
import '../bloc/provincial_event.dart';
import '../bloc/provincial_state.dart';
import 'avance_recinto_page.dart';

class RecintosListPage extends StatefulWidget {
  const RecintosListPage({super.key});

  @override
  State<RecintosListPage> createState() => _RecintosListPageState();
}

class _RecintosListPageState extends State<RecintosListPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProvincialBloc>().add(const LoadRecintos());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recintos')),
      body: BlocBuilder<ProvincialBloc, ProvincialState>(
        builder: (context, state) {
          if (state is ProvincialLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProvincialError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, textAlign: TextAlign.center, style: AppTypography.bodyMedium),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ProvincialBloc>().add(const LoadRecintos()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          if (state is RecintosLoaded) {
            if (state.recintos.isEmpty) {
              return const Center(
                child: Text('No hay recintos registrados', style: AppTypography.bodyMedium),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProvincialBloc>().add(const LoadRecintos());
              },
              child: ListView.builder(
                itemCount: state.recintos.length,
                itemBuilder: (context, index) {
                  final recinto = state.recintos[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.business_rounded, color: AppColors.primary, size: 22),
                      ),
                      title: Text(recinto.nombre, style: AppTypography.labelLarge),
                      subtitle: Text('${recinto.canton} - ${recinto.parroquia}', style: AppTypography.caption),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<ProvincialBloc>(),
                              child: AvanceRecintoPage(recintoId: recinto.id, recintoNombre: recinto.nombre),
                            ),
                          ),
                        );
                      },
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
