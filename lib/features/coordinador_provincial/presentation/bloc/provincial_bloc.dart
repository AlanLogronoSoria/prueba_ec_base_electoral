import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/create_coordinador_recinto_usecase.dart';
import '../../domain/usecases/create_recinto_usecase.dart';
import '../../domain/usecases/get_actas_por_recinto_usecase.dart';
import '../../domain/usecases/get_avance_recinto_usecase.dart';
import '../../domain/usecases/get_detalle_acta_usecase.dart';
import '../../domain/usecases/get_recintos_sin_coordinador_usecase.dart';
import '../../domain/usecases/get_recintos_usecase.dart';
import '../../domain/usecases/get_votos_consolidados_usecase.dart';
import 'provincial_event.dart';
import 'provincial_state.dart';

class ProvincialBloc extends Bloc<ProvincialEvent, ProvincialState> {
  final GetRecintosUseCase getRecintosUseCase;
  final CreateRecintoUseCase createRecintoUseCase;
  final CreateCoordinadorRecintoUseCase createCoordinadorRecintoUseCase;
  final GetAvanceRecintoUseCase getAvanceRecintoUseCase;
  final GetRecintosSinCoordinadorUseCase getRecintosSinCoordinadorUseCase;
  final GetVotosConsolidadosUseCase getVotosConsolidadosUseCase;
  final GetDetalleActaUseCase getDetalleActaUseCase;
  final GetActasPorRecintoUseCase getActasPorRecintoUseCase;

  ProvincialBloc({
    required this.getRecintosUseCase,
    required this.createRecintoUseCase,
    required this.createCoordinadorRecintoUseCase,
    required this.getAvanceRecintoUseCase,
    required this.getRecintosSinCoordinadorUseCase,
    required this.getVotosConsolidadosUseCase,
    required this.getDetalleActaUseCase,
    required this.getActasPorRecintoUseCase,
  }) : super(const ProvincialInitial()) {
    on<LoadRecintos>(_onLoadRecintos);
    on<CreateRecinto>(_onCreateRecinto);
    on<CreateCoordinadorRecinto>(_onCreateCoordinadorRecinto);
    on<LoadAvanceRecinto>(_onLoadAvanceRecinto);
    on<LoadRecintosSinCoordinador>(_onLoadRecintosSinCoordinador);
    on<LoadVotosConsolidados>(_onLoadVotosConsolidados);
    on<LoadActasPorRecinto>(_onLoadActasPorRecinto);
    on<LoadDetalleActa>(_onLoadDetalleActa);
  }

  Future<void> _onLoadRecintos(
    LoadRecintos event,
    Emitter<ProvincialState> emit,
  ) async {
    emit(const ProvincialLoading());
    final result = await getRecintosUseCase(const NoParams());
    result.fold(
      (failure) => emit(ProvincialError(message: failure.message)),
      (recintos) => emit(RecintosLoaded(recintos: recintos)),
    );
  }

  Future<void> _onCreateRecinto(
    CreateRecinto event,
    Emitter<ProvincialState> emit,
  ) async {
    emit(const ProvincialLoading());
    final result = await createRecintoUseCase(
      CreateRecintoParams(
        canton: event.canton,
        parroquia: event.parroquia,
        nombre: event.nombre,
        numeroJrv: event.numeroJrv,
      ),
    );
    result.fold(
      (failure) => emit(ProvincialError(message: failure.message)),
      (recinto) => emit(RecintoCreated(recinto: recinto)),
    );
  }

  Future<void> _onCreateCoordinadorRecinto(
    CreateCoordinadorRecinto event,
    Emitter<ProvincialState> emit,
  ) async {
    emit(const ProvincialLoading());
    final result = await createCoordinadorRecintoUseCase(
      CreateCoordinadorRecintoParams(
        recintoId: event.recintoId,
        cedula: event.cedula,
        nombres: event.nombres,
        apellidos: event.apellidos,
        telefono: event.telefono,
        correo: event.correo,
        creadoPor: event.creadoPor,
      ),
    );
    result.fold(
      (failure) => emit(ProvincialError(message: failure.message)),
      (_) => emit(const CoordinadorRecintoCreated()),
    );
  }

  Future<void> _onLoadAvanceRecinto(
    LoadAvanceRecinto event,
    Emitter<ProvincialState> emit,
  ) async {
    emit(const ProvincialLoading());
    final result = await getAvanceRecintoUseCase(
      GetAvanceRecintoParams(recintoId: event.recintoId),
    );
    result.fold(
      (failure) => emit(ProvincialError(message: failure.message)),
      (avance) => emit(AvanceRecintoLoaded(
        totalMesas: avance['total_mesas'] ?? 0,
        actasRegistradas: avance['actas_registradas'] ?? 0,
      )),
    );
  }

  Future<void> _onLoadRecintosSinCoordinador(
    LoadRecintosSinCoordinador event,
    Emitter<ProvincialState> emit,
  ) async {
    emit(const ProvincialLoading());
    final result = await getRecintosSinCoordinadorUseCase(const NoParams());
    result.fold(
      (failure) => emit(ProvincialError(message: failure.message)),
      (recintos) =>
          emit(RecintosSinCoordinadorLoaded(recintos: recintos)),
    );
  }

  Future<void> _onLoadVotosConsolidados(
    LoadVotosConsolidados event,
    Emitter<ProvincialState> emit,
  ) async {
    emit(const ProvincialLoading());
    final result = await getVotosConsolidadosUseCase(
      GetVotosConsolidadosParams(recintoId: event.recintoId),
    );
    result.fold(
      (failure) => emit(ProvincialError(message: failure.message)),
      (votos) => emit(VotosConsolidadosLoaded(votos: votos)),
    );
  }

  Future<void> _onLoadActasPorRecinto(
    LoadActasPorRecinto event,
    Emitter<ProvincialState> emit,
  ) async {
    emit(const ProvincialLoading());
    final result = await getActasPorRecintoUseCase(
      GetActasPorRecintoParams(recintoId: event.recintoId),
    );
    result.fold(
      (failure) => emit(ProvincialError(message: failure.message)),
      (actas) => emit(ActasPorRecintoLoaded(actas: actas)),
    );
  }

  Future<void> _onLoadDetalleActa(
    LoadDetalleActa event,
    Emitter<ProvincialState> emit,
  ) async {
    emit(const ProvincialLoading());
    final result = await getDetalleActaUseCase(
      GetDetalleActaParams(actaId: event.actaId, mesaId: event.mesaId),
    );
    result.fold(
      (failure) => emit(ProvincialError(message: failure.message)),
      (detalle) => emit(DetalleActaLoaded(detalle: detalle)),
    );
  }
}
