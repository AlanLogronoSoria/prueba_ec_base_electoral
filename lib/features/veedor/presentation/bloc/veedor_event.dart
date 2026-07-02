import 'package:equatable/equatable.dart';

sealed class VeedorEvent extends Equatable {
  const VeedorEvent();

  @override
  List<Object?> get props => [];
}

class LoadMesasVeedor extends VeedorEvent {
  final String veedorId;

  const LoadMesasVeedor({required this.veedorId});

  @override
  List<Object?> get props => [veedorId];
}

class LoadOrganizaciones extends VeedorEvent {
  const LoadOrganizaciones();
}

class RegistrarActa extends VeedorEvent {
  final String mesaId;
  final String dignidad;
  final int totalSufragantes;
  final int votosNulos;
  final int votosBlancos;
  final double gpsLatitud;
  final double gpsLongitud;
  final String registradoPor;
  final Map<String, int> votosPorOrganizacion;

  const RegistrarActa({
    required this.mesaId,
    required this.dignidad,
    required this.totalSufragantes,
    required this.votosNulos,
    required this.votosBlancos,
    required this.gpsLatitud,
    required this.gpsLongitud,
    required this.registradoPor,
    required this.votosPorOrganizacion,
  });

  @override
  List<Object?> get props => [
        mesaId,
        dignidad,
        totalSufragantes,
        votosNulos,
        votosBlancos,
        gpsLatitud,
        gpsLongitud,
        registradoPor,
        votosPorOrganizacion,
      ];
}

class SubirFotoActa extends VeedorEvent {
  final String filePath;
  final String actaId;

  const SubirFotoActa({
    required this.filePath,
    required this.actaId,
  });

  @override
  List<Object?> get props => [filePath, actaId];
}

class CorregirActaVeedor extends VeedorEvent {
  final String actaId;
  final int totalSufragantes;
  final int votosNulos;
  final int votosBlancos;
  final Map<String, int> votosPorOrganizacion;
  final String modificadoPor;

  const CorregirActaVeedor({
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
