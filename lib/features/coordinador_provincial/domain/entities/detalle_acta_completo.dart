import 'package:equatable/equatable.dart';
import '../../../veedor/domain/entities/acta.dart';

class DetalleActaCompleto extends Equatable {
  final Acta acta;
  final String mesaNumero;
  final List<VotoConOrganizacion> votos;

  const DetalleActaCompleto({
    required this.acta,
    required this.mesaNumero,
    required this.votos,
  });

  @override
  List<Object?> get props => [acta, mesaNumero, votos];
}

class VotoConOrganizacion extends Equatable {
  final String organizacionId;
  final String nombreOrganizacion;
  final String candidato;
  final int votos;

  const VotoConOrganizacion({
    required this.organizacionId,
    required this.nombreOrganizacion,
    required this.candidato,
    required this.votos,
  });

  @override
  List<Object?> get props => [
        organizacionId,
        nombreOrganizacion,
        candidato,
        votos,
      ];
}
