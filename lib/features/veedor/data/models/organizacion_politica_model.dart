import '../../domain/entities/organizacion_politica.dart';

class OrganizacionPoliticaModel extends OrganizacionPolitica {
  const OrganizacionPoliticaModel({
    required super.id,
    required super.nombre,
    required super.dignidad,
    required super.candidato,
  });

  factory OrganizacionPoliticaModel.fromMap(Map<String, dynamic> map, String id) {
    return OrganizacionPoliticaModel(
      id: id,
      nombre: map['nombre'] as String,
      dignidad: map['dignidad'] as String,
      candidato: map['candidato'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'dignidad': dignidad,
      'candidato': candidato,
    };
  }
}
