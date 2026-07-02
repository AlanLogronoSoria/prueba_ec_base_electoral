import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/corregir_acta_veedor_usecase.dart';
import '../../domain/usecases/get_mesas_veedor_usecase.dart';
import '../../domain/usecases/get_organizaciones_usecase.dart';
import '../../domain/usecases/registrar_acta_usecase.dart';
import '../../domain/usecases/subir_foto_acta_usecase.dart';
import 'veedor_event.dart';
import 'veedor_state.dart';

class VeedorBloc extends Bloc<VeedorEvent, VeedorState> {
  final GetMesasVeedorUseCase getMesasVeedorUseCase;
  final GetOrganizacionesUseCase getOrganizacionesUseCase;
  final RegistrarActaUseCase registrarActaUseCase;
  final SubirFotoActaUseCase subirFotoActaUseCase;
  final CorregirActaVeedorUseCase corregirActaVeedorUseCase;

  VeedorBloc({
    required this.getMesasVeedorUseCase,
    required this.getOrganizacionesUseCase,
    required this.registrarActaUseCase,
    required this.subirFotoActaUseCase,
    required this.corregirActaVeedorUseCase,
  }) : super(const VeedorInitial()) {
    on<LoadMesasVeedor>(_onLoadMesasVeedor);
    on<LoadOrganizaciones>(_onLoadOrganizaciones);
    on<RegistrarActa>(_onRegistrarActa);
    on<SubirFotoActa>(_onSubirFotoActa);
    on<CorregirActaVeedor>(_onCorregirActaVeedor);
  }

  Future<void> _onLoadMesasVeedor(
    LoadMesasVeedor event,
    Emitter<VeedorState> emit,
  ) async {
    emit(const VeedorLoading());
    final result = await getMesasVeedorUseCase(
      GetMesasVeedorParams(veedorId: event.veedorId),
    );
    result.fold(
      (failure) => emit(VeedorError(message: failure.message)),
      (mesas) => emit(MesasVeedorLoaded(mesas: mesas)),
    );
  }

  Future<void> _onLoadOrganizaciones(
    LoadOrganizaciones event,
    Emitter<VeedorState> emit,
  ) async {
    emit(const VeedorLoading());
    final result = await getOrganizacionesUseCase(const NoParams());
    result.fold(
      (failure) => emit(VeedorError(message: failure.message)),
      (orgs) => emit(OrganizacionesLoaded(organizaciones: orgs)),
    );
  }

  Future<void> _onRegistrarActa(
    RegistrarActa event,
    Emitter<VeedorState> emit,
  ) async {
    debugPrint('[BLOC:veedor] _onRegistrarActa — mesa=${event.mesaId} dignidad=${event.dignidad}');
    emit(const VeedorLoading());
    final result = await registrarActaUseCase(
      RegistrarActaParams(
        mesaId: event.mesaId,
        dignidad: event.dignidad,
        totalSufragantes: event.totalSufragantes,
        votosNulos: event.votosNulos,
        votosBlancos: event.votosBlancos,
        gpsLatitud: event.gpsLatitud,
        gpsLongitud: event.gpsLongitud,
        registradoPor: event.registradoPor,
        votosPorOrganizacion: event.votosPorOrganizacion,
      ),
    );
    debugPrint('[BLOC:veedor] Usecase result: ${result.isRight() ? "SUCCESS" : "FAILURE"}');
    if (result.isLeft()) {
      result.fold((f) => debugPrint('[BLOC:veedor] FAILURE: ${f.message}'), (_) {});
    }
    result.fold(
      (failure) => emit(VeedorError(message: failure.message)),
      (acta) => emit(ActaRegistrada(acta: acta)),
    );
  }

  Future<void> _onSubirFotoActa(
    SubirFotoActa event,
    Emitter<VeedorState> emit,
  ) async {
    emit(const VeedorLoading());
    final result = await subirFotoActaUseCase(
      SubirFotoActaParams(
        filePath: event.filePath,
        actaId: event.actaId,
      ),
    );
    result.fold(
      (failure) => emit(VeedorError(message: failure.message)),
      (url) => emit(FotoSubida(fotoUrl: url)),
    );
  }

  Future<void> _onCorregirActaVeedor(
    CorregirActaVeedor event,
    Emitter<VeedorState> emit,
  ) async {
    emit(const VeedorLoading());
    final result = await corregirActaVeedorUseCase(
      CorregirActaVeedorParams(
        actaId: event.actaId,
        totalSufragantes: event.totalSufragantes,
        votosNulos: event.votosNulos,
        votosBlancos: event.votosBlancos,
        votosPorOrganizacion: event.votosPorOrganizacion,
        modificadoPor: event.modificadoPor,
      ),
    );
    result.fold(
      (failure) => emit(VeedorError(message: failure.message)),
      (_) => emit(const ActaCorregida()),
    );
  }
}
