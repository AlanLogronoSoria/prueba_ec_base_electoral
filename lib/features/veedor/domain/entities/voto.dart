import 'package:equatable/equatable.dart';

class Voto extends Equatable {
  final String id;
  final String actaId;
  final String organizacionId;
  final int votos;

  const Voto({
    required this.id,
    required this.actaId,
    required this.organizacionId,
    required this.votos,
  });

  @override
  List<Object?> get props => [id, actaId, organizacionId, votos];
}
