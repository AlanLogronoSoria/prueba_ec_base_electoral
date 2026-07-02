import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/asignar_veedor_usecase.dart';
import '../../domain/usecases/corregir_acta_usecase.dart';
import '../../domain/usecases/create_veedor_usecase.dart';
import '../../domain/usecases/get_acta_por_mesa_usecase.dart';
import '../../domain/usecases/get_avance_usecase.dart';
import '../../domain/usecases/get_mesas_usecase.dart';
import '../../domain/usecases/get_organizaciones_usecase.dart';
import '../../domain/usecases/subir_foto_acta_usecase.dart' as recinto;
import 'recinto_event.dart';
import 'recinto_state.dart';

class RecintoBloc extends Bloc<RecintoEvent, RecintoState> {
  final GetMesasUseCase getMesasUseCase;
  final CreateVeedorUseCase createVeedorUseCase;
  final AsignarVeedorUseCase asignarVeedorUseCase;
  final CorregirActaUseCase corregirActaUseCase;
  final GetOrganizacionesRecintoUseCase getOrganizacionesUseCase;
  final GetActaPorMesaUseCase getActaPorMesaUseCase;
  final recinto.SubirFotoActaRecintoUseCase subirFotoActaUseCase;
  final GetAvanceUseCase getAvanceUseCase;

  RecintoBloc({
    required this.getMesasUseCase,
    required this.createVeedorUseCase,
    required this.asignarVeedorUseCase,
    required this.corregirActaUseCase,
    required this.getOrganizacionesUseCase,
    required this.getActaPorMesaUseCase,
    required this.subirFotoActaUseCase,
    required this.getAvanceUseCase,
  }) : super(const RecintoInitial()) {
    on<LoadMesas>(_onLoadMesas);
    on<CreateVeedor>(_onCreateVeedor);
    on<AsignarVeedor>(_onAsignarVeedor);
    on<LoadOrganizaciones>(_onLoadOrganizaciones);
    on<LoadActaPorMesa>(_onLoadActaPorMesa);
    on<CorregirActa>(_onCorregirActa);
    on<SubirFotoActa>(_onSubirFotoActa);
    on<LoadAvance>(_onLoadAvance);
  }

  Future<void> _onLoadMesas(
    LoadMesas event,
    Emitter<RecintoState> emit,
  ) async {
    emit(const RecintoLoading());
    final result =
        await getMesasUseCase(GetMesasParams(recintoId: event.recintoId));
    result.fold(
      (failure) => emit(RecintoError(message: failure.message)),
      (mesas) => emit(MesasLoaded(mesas: mesas)),
    );
  }

  Future<void> _onCreateVeedor(
    CreateVeedor event,
    Emitter<RecintoState> emit,
  ) async {
    debugPrint('[BLOC:rec] EVENT: CreateVeedor cedula=${event.cedula}');
    emit(const RecintoLoading());
    final result = await createVeedorUseCase(
      CreateVeedorParams(
        cedula: event.cedula,
        nombres: event.nombres,
        apellidos: event.apellidos,
        telefono: event.telefono,
        correo: event.correo,
        creadoPor: event.creadoPor,
        mesaId: event.mesaId,
      ),
    );
    debugPrint('[BLOC:rec] Usecase result: ${result.isRight() ? "SUCCESS" : "FAILURE"}');
    result.fold(
      (failure) => emit(RecintoError(message: failure.message)),
      (_) => emit(const VeedorCreated()),
    );
  }

  Future<void> _onAsignarVeedor(
    AsignarVeedor event,
    Emitter<RecintoState> emit,
  ) async {
    emit(const RecintoLoading());
    final result = await asignarVeedorUseCase(
      AsignarVeedorParams(
        mesaId: event.mesaId,
        veedorCedula: event.veedorCedula,
      ),
    );
    result.fold(
      (failure) => emit(RecintoError(message: failure.message)),
      (_) => emit(const VeedorAsignado()),
    );
  }

  Future<void> _onLoadOrganizaciones(
    LoadOrganizaciones event,
    Emitter<RecintoState> emit,
  ) async {
    emit(const RecintoLoading());
    final result = await getOrganizacionesUseCase(const NoParams());
    result.fold(
      (failure) => emit(RecintoError(message: failure.message)),
      (organizaciones) =>
          emit(OrganizacionesLoaded(organizaciones: organizaciones)),
    );
  }

  Future<void> _onLoadActaPorMesa(
    LoadActaPorMesa event,
    Emitter<RecintoState> emit,
  ) async {
    emit(const RecintoLoading());
    final result = await getActaPorMesaUseCase(
      GetActaPorMesaParams(mesaId: event.mesaId),
    );
    result.fold(
      (failure) => emit(RecintoError(message: failure.message)),
      (acta) => emit(ActaPorMesaLoaded(acta: acta)),
    );
  }

  Future<void> _onCorregirActa(
    CorregirActa event,
    Emitter<RecintoState> emit,
  ) async {
    emit(const RecintoLoading());
    final result = await corregirActaUseCase(
      CorregirActaParams(
        actaId: event.actaId,
        totalSufragantes: event.totalSufragantes,
        votosNulos: event.votosNulos,
        votosBlancos: event.votosBlancos,
        votosPorOrganizacion: event.votosPorOrganizacion,
        modificadoPor: event.modificadoPor,
      ),
    );
    result.fold(
      (failure) => emit(RecintoError(message: failure.message)),
      (_) => emit(const ActaCorregida()),
    );
  }

  Future<void> _onSubirFotoActa(
    SubirFotoActa event,
    Emitter<RecintoState> emit,
  ) async {
    emit(const RecintoLoading());
    final result = await subirFotoActaUseCase(
      recinto.SubirFotoActaParams(
        filePath: event.filePath,
        actaId: event.actaId,
      ),
    );
    result.fold(
      (failure) => emit(RecintoError(message: failure.message)),
      (fotoUrl) => emit(FotoSubida(fotoUrl: fotoUrl)),
    );
  }

  Future<void> _onLoadAvance(
    LoadAvance event,
    Emitter<RecintoState> emit,
  ) async {
    emit(const RecintoLoading());
    final result =
        await getAvanceUseCase(GetAvanceParams(recintoId: event.recintoId));
    result.fold(
      (failure) => emit(RecintoError(message: failure.message)),
      (avance) => emit(AvanceLoaded(
        totalMesas: avance['total_mesas'] ?? 0,
        actasRegistradas: avance['actas_registradas'] ?? 0,
      )),
    );
  }
}
