import 'package:equatable/equatable.dart';

class Recinto extends Equatable {
  final String id;
  final String canton;
  final String parroquia;
  final String nombre;
  final String? numeroJrv;
  final String? coordinadorRecintoId;

  const Recinto({
    required this.id,
    required this.canton,
    required this.parroquia,
    required this.nombre,
    this.numeroJrv,
    this.coordinadorRecintoId,
  });

  @override
  List<Object?> get props => [
        id,
        canton,
        parroquia,
        nombre,
        numeroJrv,
        coordinadorRecintoId,
      ];
}
