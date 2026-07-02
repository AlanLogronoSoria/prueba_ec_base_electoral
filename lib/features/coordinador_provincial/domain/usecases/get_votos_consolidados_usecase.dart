import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/votos_consolidados.dart';
import '../repositories/provincial_repository.dart';

class GetVotosConsolidadosUseCase
    implements UseCase<List<VotosConsolidados>, GetVotosConsolidadosParams> {
  final ProvincialRepository repository;

  GetVotosConsolidadosUseCase(this.repository);

  @override
  Future<Either<Failure, List<VotosConsolidados>>> call(
      GetVotosConsolidadosParams params) {
    return repository.getVotosConsolidados(params.recintoId);
  }
}

class GetVotosConsolidadosParams extends Equatable {
  final String? recintoId;

  const GetVotosConsolidadosParams({this.recintoId});

  @override
  List<Object?> get props => [recintoId];
}
