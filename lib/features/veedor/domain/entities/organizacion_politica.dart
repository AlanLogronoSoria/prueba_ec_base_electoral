import 'package:equatable/equatable.dart';

class OrganizacionPolitica extends Equatable {
  final String id;
  final String nombre;
  final String dignidad;
  final String candidato;

  const OrganizacionPolitica({
    required this.id,
    required this.nombre,
    required this.dignidad,
    required this.candidato,
  });

  @override
  List<Object?> get props => [id, nombre, dignidad, candidato];
}
