import 'package:equatable/equatable.dart';

class Usuario extends Equatable {
  final String id;
  final String cedula;
  final String nombres;
  final String apellidos;
  final String telefono;
  final String correo;
  final String rol;
  final bool primerLogin;
  final String? recintoId;
  final String? creadoPor;

  const Usuario({
    required this.id,
    required this.cedula,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.correo,
    required this.rol,
    required this.primerLogin,
    this.recintoId,
    this.creadoPor,
  });

  String get nombreCompleto => '$nombres $apellidos';

  @override
  List<Object?> get props => [
        id,
        cedula,
        nombres,
        apellidos,
        telefono,
        correo,
        rol,
        primerLogin,
        recintoId,
        creadoPor,
      ];
}
