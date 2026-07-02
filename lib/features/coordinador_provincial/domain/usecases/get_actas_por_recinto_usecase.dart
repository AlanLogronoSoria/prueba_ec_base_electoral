import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../features/veedor/domain/entities/acta.dart';
import '../repositories/provincial_repository.dart';

class GetActasPorRecintoUseCase
    implements UseCase<List<Acta>, GetActasPorRecintoParams> {
  final ProvincialRepository repository;

  GetActasPorRecintoUseCase(this.repository);

  @override
  Future<Either<Failure, List<Acta>>> call(
      GetActasPorRecintoParams params) {
    return repository.getActasPorRecinto(params.recintoId);
  }
}

class GetActasPorRecintoParams extends Equatable {
  final String recintoId;

  const GetActasPorRecintoParams({required this.recintoId});

  @override
  List<Object?> get props => [recintoId];
}
