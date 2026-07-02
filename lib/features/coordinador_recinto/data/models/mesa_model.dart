import '../../domain/entities/mesa.dart';

class MesaModel extends Mesa {
  const MesaModel({
    required super.id,
    required super.numeroJrv,
    required super.recintoId,
    super.veedorId,
    super.hasActa,
  });

  factory MesaModel.fromMap(Map<String, dynamic> map, String id, {bool hasActa = false}) {
    return MesaModel(
      id: id,
      numeroJrv: map['numero_jrv'] as String,
      recintoId: map['recinto_id'] as String,
      veedorId: map['veedor_id'] as String?,
      hasActa: hasActa,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'numero_jrv': numeroJrv,
      'recinto_id': recintoId,
      if (veedorId != null) 'veedor_id': veedorId,
    };
  }
}
