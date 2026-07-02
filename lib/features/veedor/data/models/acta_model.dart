import '../../domain/entities/acta.dart';

class ActaModel extends Acta {
  const ActaModel({
    required super.id,
    required super.mesaId,
    required super.dignidad,
    required super.totalSufragantes,
    required super.votosNulos,
    required super.votosBlancos,
    super.fotoUrl,
    super.gpsLatitud,
    super.gpsLongitud,
    required super.registradoPor,
    super.estado,
    super.updatedAt,
  });

  factory ActaModel.fromMap(Map<String, dynamic> map, String id) {
    return ActaModel(
      id: id,
      mesaId: map['mesa_id'] as String,
      dignidad: map['dignidad'] as String,
      totalSufragantes: map['total_sufragantes'] as int,
      votosNulos: map['votos_nulos'] as int,
      votosBlancos: map['votos_blancos'] as int,
      fotoUrl: map['foto_url'] as String?,
      gpsLatitud: (map['gps_lat'] as num?)?.toDouble(),
      gpsLongitud: (map['gps_lng'] as num?)?.toDouble(),
      registradoPor: map['created_by'] as String,
      estado: map['estado'] as String? ?? 'pendiente',
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mesa_id': mesaId,
      'dignidad': dignidad,
      'total_sufragantes': totalSufragantes,
      'votos_nulos': votosNulos,
      'votos_blancos': votosBlancos,
      if (fotoUrl != null) 'foto_url': fotoUrl,
      if (gpsLatitud != null) 'gps_lat': gpsLatitud,
      if (gpsLongitud != null) 'gps_lng': gpsLongitud,
      'created_by': registradoPor,
      'estado': estado,
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}
