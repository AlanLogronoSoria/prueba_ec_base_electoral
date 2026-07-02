import '../../domain/entities/voto.dart';

class VotoModel extends Voto {
  const VotoModel({
    required super.id,
    required super.actaId,
    required super.organizacionId,
    required super.votos,
  });

  factory VotoModel.fromMap(Map<String, dynamic> map, String id) {
    return VotoModel(
      id: id,
      actaId: map['acta_id'] as String,
      organizacionId: map['organizacion_id'] as String,
      votos: (map['cantidad_votos'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'acta_id': actaId,
      'organizacion_id': organizacionId,
      'cantidad_votos': votos,
    };
  }
}
