import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/acta.dart';

abstract class VeedorRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> getMesasVeedor(
    String veedorId,
  );
  Future<Either<Failure, Acta>> registrarActa(
    String mesaId,
    String dignidad,
    int totalSufragantes,
    int votosNulos,
    int votosBlancos,
    double gpsLatitud,
    double gpsLongitud,
    String registradoPor,
    Map<String, int> votosPorOrganizacion,
  );
  Future<Either<Failure, String>> subirFotoActa(
    String filePath,
    String actaId,
  );
  Future<Either<Failure, List<Map<String, dynamic>>>> getOrganizaciones();
  Future<Either<Failure, Null>> corregirActaVeedor(
    String actaId,
    int totalSufragantes,
    int votosNulos,
    int votosBlancos,
    Map<String, int> votosPorOrganizacion,
    String modificadoPor,
  );
}
