import 'package:equatable/equatable.dart';
import '../../domain/entities/acta.dart';

sealed class VeedorState extends Equatable {
  const VeedorState();

  @override
  List<Object?> get props => [];
}

class VeedorInitial extends VeedorState {
  const VeedorInitial();
}

class VeedorLoading extends VeedorState {
  const VeedorLoading();
}

class MesasVeedorLoaded extends VeedorState {
  final List<Map<String, dynamic>> mesas;

  const MesasVeedorLoaded({required this.mesas});

  @override
  List<Object?> get props => [mesas];
}

class OrganizacionesLoaded extends VeedorState {
  final List<Map<String, dynamic>> organizaciones;

  const OrganizacionesLoaded({required this.organizaciones});

  @override
  List<Object?> get props => [organizaciones];
}

class ActaRegistrada extends VeedorState {
  final Acta acta;

  const ActaRegistrada({required this.acta});

  @override
  List<Object?> get props => [acta];
}

class FotoSubida extends VeedorState {
  final String fotoUrl;

  const FotoSubida({required this.fotoUrl});

  @override
  List<Object?> get props => [fotoUrl];
}

class ActaCorregida extends VeedorState {
  const ActaCorregida();
}

class VeedorError extends VeedorState {
  final String message;

  const VeedorError({required this.message});

  @override
  List<Object?> get props => [message];
}
