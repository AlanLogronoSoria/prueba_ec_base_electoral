import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../features/veedor/domain/entities/acta.dart';
import '../../domain/entities/detalle_acta_completo.dart';
import '../../domain/entities/recinto.dart';
import '../../domain/entities/votos_consolidados.dart';

abstract class ProvincialRepository {
  Future<Either<Failure, List<Recinto>>> getRecintos();
  Future<Either<Failure, List<Recinto>>> getRecintosSinCoordinador();
  Future<Either<Failure, Recinto>> createRecinto(
    String canton,
    String parroquia,
    String nombre,
    String? numeroJrv,
  );
  Future<Either<Failure, Null>> createCoordinadorRecinto(
    String recintoId,
    String cedula,
    String nombres,
    String apellidos,
    String telefono,
    String correo,
    String creadoPor,
  );
  Future<Either<Failure, Map<String, int>>> getAvanceRecinto(
    String recintoId,
  );
  Future<Either<Failure, List<Acta>>> getActasPorRecinto(
    String recintoId,
  );
  Future<Either<Failure, List<VotosConsolidados>>> getVotosConsolidados(
    String? recintoId,
  );
  Future<Either<Failure, DetalleActaCompleto>> getDetalleActa(
    String actaId,
    String mesaId,
  );
}
