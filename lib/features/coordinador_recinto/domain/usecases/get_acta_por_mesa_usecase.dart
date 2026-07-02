import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../features/veedor/domain/entities/acta.dart';
import '../repositories/recinto_repository.dart';

class GetActaPorMesaUseCase
    implements UseCase<Acta, GetActaPorMesaParams> {
  final RecintoRepository repository;

  GetActaPorMesaUseCase(this.repository);

  @override
  Future<Either<Failure, Acta>> call(GetActaPorMesaParams params) {
    return repository.getActaPorMesa(params.mesaId);
  }
}

class GetActaPorMesaParams extends Equatable {
  final String mesaId;

  const GetActaPorMesaParams({required this.mesaId});

  @override
  List<Object?> get props => [mesaId];
}
