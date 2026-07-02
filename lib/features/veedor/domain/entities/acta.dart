import 'package:equatable/equatable.dart';

class Acta extends Equatable {
  final String id;
  final String mesaId;
  final String dignidad;
  final int totalSufragantes;
  final int votosNulos;
  final int votosBlancos;
  final String? fotoUrl;
  final double? gpsLatitud;
  final double? gpsLongitud;
  final String registradoPor;
  final String estado;
  final DateTime? updatedAt;

  const Acta({
    required this.id,
    required this.mesaId,
    required this.dignidad,
    required this.totalSufragantes,
    required this.votosNulos,
    required this.votosBlancos,
    this.fotoUrl,
    this.gpsLatitud,
    this.gpsLongitud,
    required this.registradoPor,
    this.estado = 'pendiente',
    this.updatedAt,
  });

  int get votosValidos =>
      totalSufragantes - votosNulos - votosBlancos;

  @override
  List<Object?> get props => [
        id,
        mesaId,
        dignidad,
        totalSufragantes,
        votosNulos,
        votosBlancos,
        fotoUrl,
        gpsLatitud,
        gpsLongitud,
        registradoPor,
        estado,
        updatedAt,
      ];
}
