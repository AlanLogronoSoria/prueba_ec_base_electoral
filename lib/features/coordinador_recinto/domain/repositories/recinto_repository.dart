import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../features/veedor/domain/entities/acta.dart';
import '../../../../features/veedor/domain/entities/organizacion_politica.dart';
import '../entities/mesa.dart';

abstract class RecintoRepository {
  Future<Either<Failure, List<Mesa>>> getMesas(String recintoId);
  Future<Either<Failure, String>> createVeedor(
    String cedula,
    String nombres,
    String apellidos,
    String telefono,
    String correo,
    String creadoPor,
    String? mesaId,
  );
  Future<Either<Failure, Null>> asignarVeedor(
    String mesaId,
    String veedorCedula,
  );
  Future<Either<Failure, List<OrganizacionPolitica>>> getOrganizaciones();
  Future<Either<Failure, Acta>> getActaPorMesa(String mesaId);
  Future<Either<Failure, Null>> corregirActa(
    String actaId,
    int totalSufragantes,
    int votosNulos,
    int votosBlancos,
    Map<String, int> votosPorOrganizacion,
    String modificadoPor,
  );
  Future<Either<Failure, String>> subirFotoActa(
      String filePath, String actaId);
  Future<Either<Failure, Map<String, int>>> getAvance(String recintoId);
}
