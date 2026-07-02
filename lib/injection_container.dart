import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'core/appwrite/appwrite_client.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/change_password_usecase.dart';
import 'features/auth/domain/usecases/complete_recovery_usecase.dart';
import 'features/auth/domain/usecases/create_user_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/recover_password_usecase.dart';
import 'features/auth/domain/usecases/request_recovery_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/recovery_bloc.dart';
import 'features/coordinador_provincial/data/datasources/provincial_remote_datasource.dart';
import 'features/coordinador_provincial/data/repositories/provincial_repository_impl.dart';
import 'features/coordinador_provincial/domain/repositories/provincial_repository.dart';
import 'features/coordinador_provincial/domain/usecases/create_coordinador_recinto_usecase.dart';
import 'features/coordinador_provincial/domain/usecases/create_recinto_usecase.dart';
import 'features/coordinador_provincial/domain/usecases/get_actas_por_recinto_usecase.dart';
import 'features/coordinador_provincial/domain/usecases/get_avance_recinto_usecase.dart';
import 'features/coordinador_provincial/domain/usecases/get_detalle_acta_usecase.dart';
import 'features/coordinador_provincial/domain/usecases/get_recintos_sin_coordinador_usecase.dart';
import 'features/coordinador_provincial/domain/usecases/get_recintos_usecase.dart';
import 'features/coordinador_provincial/domain/usecases/get_votos_consolidados_usecase.dart';
import 'features/coordinador_provincial/presentation/bloc/provincial_bloc.dart';
import 'features/coordinador_recinto/data/datasources/recinto_remote_datasource.dart';
import 'features/coordinador_recinto/data/repositories/recinto_repository_impl.dart';
import 'features/coordinador_recinto/domain/repositories/recinto_repository.dart';
import 'features/coordinador_recinto/domain/usecases/asignar_veedor_usecase.dart';
import 'features/coordinador_recinto/domain/usecases/corregir_acta_usecase.dart';
import 'features/coordinador_recinto/domain/usecases/create_veedor_usecase.dart';
import 'features/coordinador_recinto/domain/usecases/get_acta_por_mesa_usecase.dart';
import 'features/coordinador_recinto/domain/usecases/get_avance_usecase.dart';
import 'features/coordinador_recinto/domain/usecases/get_mesas_usecase.dart';
import 'features/coordinador_recinto/domain/usecases/get_organizaciones_usecase.dart';
import 'features/coordinador_recinto/domain/usecases/subir_foto_acta_usecase.dart' as recinto;
import 'features/coordinador_recinto/presentation/bloc/recinto_bloc.dart';
import 'features/veedor/data/datasources/veedor_local_datasource.dart';
import 'features/veedor/data/datasources/veedor_remote_datasource.dart';
import 'features/veedor/data/repositories/veedor_repository_impl.dart';
import 'features/veedor/domain/repositories/veedor_repository.dart';
import 'features/veedor/domain/usecases/corregir_acta_veedor_usecase.dart';
import 'features/veedor/domain/usecases/get_mesas_veedor_usecase.dart';
import 'features/veedor/domain/usecases/get_organizaciones_usecase.dart';
import 'features/veedor/domain/usecases/registrar_acta_usecase.dart';
import 'features/veedor/domain/usecases/subir_foto_acta_usecase.dart';
import 'features/veedor/presentation/bloc/veedor_bloc.dart';
import 'features/veedor/presentation/sync/sync_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  AppwriteClient.instance.init();

  // Core
  sl.registerLazySingleton(() => AppwriteClient.instance.account);
  sl.registerLazySingleton(() => AppwriteClient.instance.databases);
  sl.registerLazySingleton(() => AppwriteClient.instance.storage);
  sl.registerLazySingleton(() => AppwriteClient.instance.functions);

  // Auth Feature
  sl.registerLazySingleton(() => AuthBloc(
        loginUseCase: sl(),
        logoutUseCase: sl(),
        changePasswordUseCase: sl(),
        recoverPasswordUseCase: sl(),
      ));
  sl.registerFactory(() => RecoveryBloc(
        requestRecoveryUseCase: sl(),
        completeRecoveryUseCase: sl(),
      ));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(sl()));
  sl.registerLazySingleton(() => RecoverPasswordUseCase(sl()));
  sl.registerLazySingleton(() => RequestRecoveryUseCase(sl()));
  sl.registerLazySingleton(() => CompleteRecoveryUseCase(sl()));
  sl.registerLazySingleton(() => CreateUserUseCase(sl()));
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<AuthRemoteDatasource>(
      () => AuthRemoteDatasourceImpl(
            account: sl(),
            databases: sl(),
            functions: sl(),
          ));

  // Provincial Feature
  sl.registerFactory(() => ProvincialBloc(
        getRecintosUseCase: sl(),
        createRecintoUseCase: sl(),
        createCoordinadorRecintoUseCase: sl(),
        getAvanceRecintoUseCase: sl(),
        getRecintosSinCoordinadorUseCase: sl(),
        getVotosConsolidadosUseCase: sl(),
        getDetalleActaUseCase: sl(),
        getActasPorRecintoUseCase: sl(),
      ));
  sl.registerLazySingleton(() => GetRecintosUseCase(sl()));
  sl.registerLazySingleton(() => CreateRecintoUseCase(sl()));
  sl.registerLazySingleton(() => CreateCoordinadorRecintoUseCase(sl()));
  sl.registerLazySingleton(() => GetAvanceRecintoUseCase(sl()));
  sl.registerLazySingleton(() => GetRecintosSinCoordinadorUseCase(sl()));
  sl.registerLazySingleton(() => GetVotosConsolidadosUseCase(sl()));
  sl.registerLazySingleton(() => GetDetalleActaUseCase(sl()));
  sl.registerLazySingleton(() => GetActasPorRecintoUseCase(sl()));
  sl.registerLazySingleton<ProvincialRepository>(
      () => ProvincialRepositoryImpl(sl()));
  sl.registerLazySingleton<ProvincialRemoteDatasource>(
      () => ProvincialRemoteDatasourceImpl(
            databases: sl(),
            account: sl(),
            functions: sl(),
          ));

  // Recinto Feature
  sl.registerFactory(() => RecintoBloc(
        datasource: sl(),
        getMesasUseCase: sl(),
        createVeedorUseCase: sl(),
        asignarVeedorUseCase: sl(),
        corregirActaUseCase: sl(),
        getOrganizacionesUseCase: sl(),
        getActaPorMesaUseCase: sl(),
        subirFotoActaUseCase: sl(),
        getAvanceUseCase: sl(),
      ));
  sl.registerLazySingleton(() => GetMesasUseCase(sl()));
  sl.registerLazySingleton(() => CreateVeedorUseCase(sl()));
  sl.registerLazySingleton(() => AsignarVeedorUseCase(sl()));
  sl.registerLazySingleton(() => CorregirActaUseCase(sl()));
  sl.registerLazySingleton(() => GetActaPorMesaUseCase(sl()));
  sl.registerLazySingleton(() => recinto.SubirFotoActaRecintoUseCase(sl()));
  sl.registerLazySingleton(() => GetOrganizacionesRecintoUseCase(sl()));
  sl.registerLazySingleton(() => GetAvanceUseCase(sl()));
  sl.registerLazySingleton<RecintoRepository>(
      () => RecintoRepositoryImpl(sl()));
  sl.registerLazySingleton<RecintoRemoteDatasource>(
      () => RecintoRemoteDatasourceImpl(
            databases: sl(),
            account: sl(),
            storage: sl(),
            functions: sl(),
          ));

  // Veedor Feature
  sl.registerFactory(() => VeedorBloc(
        getMesasVeedorUseCase: sl(),
        getOrganizacionesUseCase: sl(),
        registrarActaUseCase: sl(),
        subirFotoActaUseCase: sl(),
        corregirActaVeedorUseCase: sl(),
      ));
  sl.registerLazySingleton(() => GetMesasVeedorUseCase(sl()));
  sl.registerLazySingleton(() => GetOrganizacionesUseCase(sl()));
  sl.registerLazySingleton(() => RegistrarActaUseCase(sl()));
  sl.registerLazySingleton(() => SubirFotoActaUseCase(sl()));
  sl.registerLazySingleton(() => CorregirActaVeedorUseCase(sl()));
  sl.registerLazySingleton<VeedorRepository>(
      () => VeedorRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton<VeedorRemoteDatasource>(
      () => VeedorRemoteDatasourceImpl(
            databases: sl(),
            storage: sl(),
          ));
  sl.registerLazySingleton<VeedorLocalDatasource>(
      () => VeedorLocalDatasourceImpl());
  sl.registerLazySingleton(() => Connectivity());
  sl.registerFactory(() => SyncBloc(
        localDatasource: sl(),
        remoteDatasource: sl(),
        connectivity: sl(),
      ));
}
