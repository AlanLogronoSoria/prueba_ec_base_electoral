import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/mesa.dart';
import '../repositories/recinto_repository.dart';

class GetMesasUseCase implements UseCase<List<Mesa>, GetMesasParams> {
  final RecintoRepository repository;

  GetMesasUseCase(this.repository);

  @override
  Future<Either<Failure, List<Mesa>>> call(GetMesasParams params) {
    return repository.getMesas(params.recintoId);
  }
}

class GetMesasParams extends Equatable {
  final String recintoId;

  const GetMesasParams({required this.recintoId});

  @override
  List<Object?> get props => [recintoId];
}
