import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/veedor_repository.dart';

class CorregirActaVeedorUseCase
    implements UseCase<Null, CorregirActaVeedorParams> {
  final VeedorRepository repository;

  CorregirActaVeedorUseCase(this.repository);

  @override
  Future<Either<Failure, Null>> call(CorregirActaVeedorParams params) {
    return repository.corregirActaVeedor(
      params.actaId,
      params.totalSufragantes,
      params.votosNulos,
      params.votosBlancos,
      params.votosPorOrganizacion,
      params.modificadoPor,
    );
  }
}

class CorregirActaVeedorParams extends Equatable {
  final String actaId;
  final int totalSufragantes;
  final int votosNulos;
  final int votosBlancos;
  final Map<String, int> votosPorOrganizacion;
  final String modificadoPor;

  const CorregirActaVeedorParams({
    required this.actaId,
    required this.totalSufragantes,
    required this.votosNulos,
    required this.votosBlancos,
    required this.votosPorOrganizacion,
    required this.modificadoPor,
  });

  @override
  List<Object?> get props => [
        actaId,
        totalSufragantes,
        votosNulos,
        votosBlancos,
        votosPorOrganizacion,
        modificadoPor,
      ];
}
