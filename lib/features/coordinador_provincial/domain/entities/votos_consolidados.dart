import 'package:equatable/equatable.dart';

class VotosConsolidados extends Equatable {
  final String dignidad;
  final List<ResultadoOrganizacion> resultados;

  const VotosConsolidados({
    required this.dignidad,
    required this.resultados,
  });

  @override
  List<Object?> get props => [dignidad, resultados];
}

class ResultadoOrganizacion extends Equatable {
  final String organizacionId;
  final String nombreOrganizacion;
  final String candidato;
  final int totalVotos;

  const ResultadoOrganizacion({
    required this.organizacionId,
    required this.nombreOrganizacion,
    required this.candidato,
    required this.totalVotos,
  });

  @override
  List<Object?> get props => [
        organizacionId,
        nombreOrganizacion,
        candidato,
        totalVotos,
      ];
}
