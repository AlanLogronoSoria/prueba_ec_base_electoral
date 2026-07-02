import 'package:equatable/equatable.dart';

sealed class RecintoEvent extends Equatable {
  const RecintoEvent();

  @override
  List<Object?> get props => [];
}

class LoadMesas extends RecintoEvent {
  final String recintoId;

  const LoadMesas({required this.recintoId});

  @override
  List<Object?> get props => [recintoId];
}

class CreateVeedor extends RecintoEvent {
  final String cedula;
  final String nombres;
  final String apellidos;
  final String telefono;
  final String correo;
  final String creadoPor;
  final String? mesaId;

  const CreateVeedor({
    required this.cedula,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.correo,
    required this.creadoPor,
    this.mesaId,
  });

  @override
  List<Object?> get props => [
        cedula,
        nombres,
        apellidos,
        telefono,
        correo,
        creadoPor,
        mesaId,
      ];
}

class AsignarVeedor extends RecintoEvent {
  final String mesaId;
  final String veedorCedula;

  const AsignarVeedor({
    required this.mesaId,
    required this.veedorCedula,
  });

  @override
  List<Object?> get props => [mesaId, veedorCedula];
}

class LoadOrganizaciones extends RecintoEvent {
  const LoadOrganizaciones();
}

class LoadActaPorMesa extends RecintoEvent {
  final String mesaId;

  const LoadActaPorMesa({required this.mesaId});

  @override
  List<Object?> get props => [mesaId];
}

class CorregirActa extends RecintoEvent {
  final String actaId;
  final int totalSufragantes;
  final int votosNulos;
  final int votosBlancos;
  final Map<String, int> votosPorOrganizacion;
  final String modificadoPor;

  const CorregirActa({
    required this.actaId,
    required this.totalSufragantes,
    required this.votosNulos,
    required this.votosBlancos,
    required this.votosPorOrganizacion,
    required this.modificadoPor,
  });

  @override
  List<Object?> get props => [
        actaId,
        totalSufragantes,
        votosNulos,
        votosBlancos,
        votosPorOrganizacion,
        modificadoPor,
      ];
}

class SubirFotoActa extends RecintoEvent {
  final String filePath;
  final String actaId;

  const SubirFotoActa({
    required this.filePath,
    required this.actaId,
  });

  @override
  List<Object?> get props => [filePath, actaId];
}

class LoadAvance extends RecintoEvent {
  final String recintoId;

  const LoadAvance({required this.recintoId});

  @override
  List<Object?> get props => [recintoId];
}
