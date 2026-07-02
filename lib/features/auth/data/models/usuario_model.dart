import '../../domain/entities/usuario.dart';

class UsuarioModel extends Usuario {
  const UsuarioModel({
    required super.id,
    required super.cedula,
    required super.nombres,
    required super.apellidos,
    required super.telefono,
    required super.correo,
    required super.rol,
    required super.primerLogin,
    super.recintoId,
    super.creadoPor,
  });

  factory UsuarioModel.fromMap(Map<String, dynamic> map, String id) {
    return UsuarioModel(
      id: id,
      cedula: map['cedula'] as String,
      nombres: map['nombres'] as String,
      apellidos: map['apellidos'] as String,
      telefono: map['telefono'] as String,
      correo: map['correo'] as String,
      rol: map['rol'] as String,
      primerLogin: (map['primer_login'] as bool?) ?? true,
      recintoId: map['recinto_id'] as String?,
      creadoPor: map['creado_por'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cedula': cedula,
      'nombres': nombres,
      'apellidos': apellidos,
      'telefono': telefono,
      'correo': correo,
      'rol': rol,
      'primer_login': primerLogin,
      if (recintoId != null) 'recinto_id': recintoId,
      if (creadoPor != null) 'creado_por': creadoPor,
    };
  }
}
