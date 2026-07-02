import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/provincial_repository.dart';

class GetAvanceRecintoUseCase
    implements UseCase<Map<String, int>, GetAvanceRecintoParams> {
  final ProvincialRepository repository;

  GetAvanceRecintoUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, int>>> call(
      GetAvanceRecintoParams params) {
    return repository.getAvanceRecinto(params.recintoId);
  }
}

class GetAvanceRecintoParams extends Equatable {
  final String recintoId;

  const GetAvanceRecintoParams({required this.recintoId});

  @override
  List<Object?> get props => [recintoId];
}
