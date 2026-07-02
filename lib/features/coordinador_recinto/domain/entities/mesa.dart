import 'package:equatable/equatable.dart';

class Mesa extends Equatable {
  final String id;
  final String numeroJrv;
  final String recintoId;
  final String? veedorId;
  final bool hasActa;

  const Mesa({
    required this.id,
    required this.numeroJrv,
    required this.recintoId,
    this.veedorId,
    this.hasActa = false,
  });

  @override
  List<Object?> get props => [id, numeroJrv, recintoId, veedorId, hasActa];
}
