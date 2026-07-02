import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../features/veedor/domain/entities/organizacion_politica.dart';
import '../repositories/recinto_repository.dart';

class GetOrganizacionesRecintoUseCase
    implements UseCase<List<OrganizacionPolitica>, NoParams> {
  final RecintoRepository repository;

  GetOrganizacionesRecintoUseCase(this.repository);

  @override
  Future<Either<Failure, List<OrganizacionPolitica>>> call(NoParams params) {
    return repository.getOrganizaciones();
  }
}
