import '../../domain/entities/recinto.dart';

class RecintoModel extends Recinto {
  const RecintoModel({
    required super.id,
    required super.canton,
    required super.parroquia,
    required super.nombre,
    super.numeroJrv,
    super.coordinadorRecintoId,
  });

  factory RecintoModel.fromMap(Map<String, dynamic> map, String id) {
    return RecintoModel(
      id: id,
      canton: map['canton'] as String,
      parroquia: map['parroquia'] as String,
      nombre: map['nombre'] as String,
      numeroJrv: map['numero_jrv']?.toString(),
      coordinadorRecintoId: map['coordinador_recinto_id'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'canton': canton,
      'parroquia': parroquia,
      'nombre': nombre,
      if (numeroJrv != null) 'numero_jrv': numeroJrv,
      if (coordinadorRecintoId != null) 'coordinador_recinto_id': coordinadorRecintoId,
    };
  }
}
