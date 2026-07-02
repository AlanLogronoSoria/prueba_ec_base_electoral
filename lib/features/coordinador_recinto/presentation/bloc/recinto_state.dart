import 'package:equatable/equatable.dart';
import '../../../veedor/domain/entities/acta.dart';
import '../../../veedor/domain/entities/organizacion_politica.dart';
import '../../domain/entities/mesa.dart';

sealed class RecintoState extends Equatable {
  const RecintoState();

  @override
  List<Object?> get props => [];
}

class RecintoInitial extends RecintoState {
  const RecintoInitial();
}

class RecintoLoading extends RecintoState {
  const RecintoLoading();
}

class MesasLoaded extends RecintoState {
  final List<Mesa> mesas;

  const MesasLoaded({required this.mesas});

  @override
  List<Object?> get props => [mesas];
}

class VeedorCreated extends RecintoState {
  const VeedorCreated();
}

class VeedorAsignado extends RecintoState {
  const VeedorAsignado();
}

class OrganizacionesLoaded extends RecintoState {
  final List<OrganizacionPolitica> organizaciones;

  const OrganizacionesLoaded({required this.organizaciones});

  @override
  List<Object?> get props => [organizaciones];
}

class ActaPorMesaLoaded extends RecintoState {
  final Acta acta;

  const ActaPorMesaLoaded({required this.acta});

  @override
  List<Object?> get props => [acta];
}

class ActaCorregida extends RecintoState {
  const ActaCorregida();
}

class FotoSubida extends RecintoState {
  final String fotoUrl;

  const FotoSubida({required this.fotoUrl});

  @override
  List<Object?> get props => [fotoUrl];
}

class AvanceLoaded extends RecintoState {
  final int totalMesas;
  final int actasRegistradas;

  const AvanceLoaded({
    required this.totalMesas,
    required this.actasRegistradas,
  });

  @override
  List<Object?> get props => [totalMesas, actasRegistradas];
}

class RecintoError extends RecintoState {
  final String message;

  const RecintoError({required this.message});

  @override
  List<Object?> get props => [message];
}
