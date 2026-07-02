import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/recinto.dart';
import '../repositories/provincial_repository.dart';

class GetRecintosUseCase implements UseCase<List<Recinto>, NoParams> {
  final ProvincialRepository repository;

  GetRecintosUseCase(this.repository);

  @override
  Future<Either<Failure, List<Recinto>>> call(NoParams params) {
    return repository.getRecintos();
  }
}
