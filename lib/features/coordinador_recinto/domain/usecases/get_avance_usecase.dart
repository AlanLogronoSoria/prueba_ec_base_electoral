import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/recinto_repository.dart';

class GetAvanceUseCase
    implements UseCase<Map<String, int>, GetAvanceParams> {
  final RecintoRepository repository;

  GetAvanceUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, int>>> call(GetAvanceParams params) {
    return repository.getAvance(params.recintoId);
  }
}

class GetAvanceParams extends Equatable {
  final String recintoId;

  const GetAvanceParams({required this.recintoId});

  @override
  List<Object?> get props => [recintoId];
}
