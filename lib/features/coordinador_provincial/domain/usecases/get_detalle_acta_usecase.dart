import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/detalle_acta_completo.dart';
import '../repositories/provincial_repository.dart';

class GetDetalleActaUseCase
    implements UseCase<DetalleActaCompleto, GetDetalleActaParams> {
  final ProvincialRepository repository;

  GetDetalleActaUseCase(this.repository);

  @override
  Future<Either<Failure, DetalleActaCompleto>> call(
      GetDetalleActaParams params) {
    return repository.getDetalleActa(params.actaId, params.mesaId);
  }
}

class GetDetalleActaParams extends Equatable {
  final String actaId;
  final String mesaId;

  const GetDetalleActaParams({
    required this.actaId,
    required this.mesaId,
  });

  @override
  List<Object?> get props => [actaId, mesaId];
}
