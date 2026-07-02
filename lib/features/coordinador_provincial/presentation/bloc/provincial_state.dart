import '../../../../features/veedor/domain/entities/acta.dart';
import '../../domain/entities/detalle_acta_completo.dart';
import '../../domain/entities/recinto.dart';
import '../../domain/entities/votos_consolidados.dart';
import 'package:equatable/equatable.dart';

sealed class ProvincialState extends Equatable {
  const ProvincialState();

  @override
  List<Object?> get props => [];
}

class ProvincialInitial extends ProvincialState {
  const ProvincialInitial();
}

class ProvincialLoading extends ProvincialState {
  const ProvincialLoading();
}

class RecintosLoaded extends ProvincialState {
  final List<Recinto> recintos;

  const RecintosLoaded({required this.recintos});

  @override
  List<Object?> get props => [recintos];
}

class RecintosSinCoordinadorLoaded extends ProvincialState {
  final List<Recinto> recintos;

  const RecintosSinCoordinadorLoaded({required this.recintos});

  @override
  List<Object?> get props => [recintos];
}

class AvanceRecintoLoaded extends ProvincialState {
  final int totalMesas;
  final int actasRegistradas;

  const AvanceRecintoLoaded({
    required this.totalMesas,
    required this.actasRegistradas,
  });

  @override
  List<Object?> get props => [totalMesas, actasRegistradas];
}

class RecintoCreated extends ProvincialState {
  final Recinto recinto;

  const RecintoCreated({required this.recinto});

  @override
  List<Object?> get props => [recinto];
}

class CoordinadorRecintoCreated extends ProvincialState {
  const CoordinadorRecintoCreated();
}

class VotosConsolidadosLoaded extends ProvincialState {
  final List<VotosConsolidados> votos;

  const VotosConsolidadosLoaded({required this.votos});

  @override
  List<Object?> get props => [votos];
}

class ActasPorRecintoLoaded extends ProvincialState {
  final List<Acta> actas;

  const ActasPorRecintoLoaded({required this.actas});

  @override
  List<Object?> get props => [actas];
}

class DetalleActaLoaded extends ProvincialState {
  final DetalleActaCompleto detalle;

  const DetalleActaLoaded({required this.detalle});

  @override
  List<Object?> get props => [detalle];
}

class ProvincialError extends ProvincialState {
  final String message;

  const ProvincialError({required this.message});

  @override
  List<Object?> get props => [message];
}
