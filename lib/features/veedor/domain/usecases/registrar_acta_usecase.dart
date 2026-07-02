import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/acta.dart';
import '../repositories/veedor_repository.dart';

class RegistrarActaUseCase
    implements UseCase<Acta, RegistrarActaParams> {
  final VeedorRepository repository;

  RegistrarActaUseCase(this.repository);

  @override
  Future<Either<Failure, Acta>> call(RegistrarActaParams params) {
    return repository.registrarActa(
      params.mesaId,
      params.dignidad,
      params.totalSufragantes,
      params.votosNulos,
      params.votosBlancos,
      params.gpsLatitud,
      params.gpsLongitud,
      params.registradoPor,
      params.votosPorOrganizacion,
    );
  }
}

class RegistrarActaParams extends Equatable {
  final String mesaId;
  final String dignidad;
  final int totalSufragantes;
  final int votosNulos;
  final int votosBlancos;
  final double gpsLatitud;
  final double gpsLongitud;
  final String registradoPor;
  final Map<String, int> votosPorOrganizacion;

  const RegistrarActaParams({
    required this.mesaId,
    required this.dignidad,
    required this.totalSufragantes,
    required this.votosNulos,
    required this.votosBlancos,
    required this.gpsLatitud,
    required this.gpsLongitud,
    required this.registradoPor,
    required this.votosPorOrganizacion,
  });

  @override
  List<Object?> get props => [
        mesaId,
        dignidad,
        totalSufragantes,
        votosNulos,
        votosBlancos,
        gpsLatitud,
        gpsLongitud,
        registradoPor,
        votosPorOrganizacion,
      ];
}
