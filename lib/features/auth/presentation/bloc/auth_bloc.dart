import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/recover_password_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final ChangePasswordUseCase changePasswordUseCase;
  final RecoverPasswordUseCase recoverPasswordUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.changePasswordUseCase,
    required this.recoverPasswordUseCase,
  }) : super(const AuthInitial()) {
    on<LoginRequested>(_onLogin);
    on<LogoutRequested>(_onLogout);
    on<ChangePasswordRequested>(_onChangePassword);
    on<RecoverPasswordRequested>(_onRecoverPassword);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<ResetAuthState>(_onResetAuthState);
  }

  Future<void> _onLogin(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('[AUTH_BLOC] _onLogin: cedula=${event.cedula} email=${event.email}');
    emit(const AuthLoading());
    try {
      debugPrint('[AUTH_BLOC] Llamando loginUseCase...');
      final result = await loginUseCase(
        LoginParams(cedula: event.cedula, email: event.email, password: event.password),
      );
      debugPrint('[AUTH_BLOC] loginUseCase completado');
      result.fold(
        (failure) {
          debugPrint('[AUTH_BLOC] Login falló: ${failure.message}');
          emit(AuthError(message: failure.message));
        },
        (usuario) {
          debugPrint('[AUTH_BLOC] Login exitoso: id=${usuario.id} rol=${usuario.rol} primerLogin=${usuario.primerLogin}');
          if (event.selectedRole != null && usuario.rol != event.selectedRole) {
            emit(AuthError(
              message: 'El usuario no tiene el rol "${_labelRol(event.selectedRole!)}"',
            ));
            return;
          }
          if (usuario.primerLogin) {
            emit(AuthRequiresPasswordChange(usuario: usuario));
          } else {
            emit(AuthAuthenticated(usuario: usuario));
          }
        },
      );
    } catch (e, stack) {
      debugPrint('[AUTH_BLOC] Excepción: $e\n$stack');
      emit(AuthError(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  Future<void> _onLogout(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await logoutUseCase(const NoParams());
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onChangePassword(
    ChangePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('[AUTH_BLOC] _onChangePassword');
    emit(const AuthLoading());
    try {
      final result = await changePasswordUseCase(
        ChangePasswordParams(
          currentPassword: event.currentPassword,
          newPassword: event.newPassword,
        ),
      );
      result.fold(
        (failure) {
          debugPrint('[AUTH_BLOC] ChangePassword falló: ${failure.message}');
          emit(AuthError(message: failure.message));
        },
        (_) {
          debugPrint('[AUTH_BLOC] ChangePassword exitoso, redirigiendo a login');
          emit(const AuthUnauthenticated());
        },
      );
    } catch (e, stack) {
      debugPrint('[AUTH_BLOC] Excepción en changePassword: $e\n$stack');
      emit(AuthError(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  Future<void> _onRecoverPassword(
    RecoverPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await recoverPasswordUseCase(
      RecoverPasswordParams(email: event.email),
    );
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await loginUseCase.repository.getCurrentUser();
    if (result.isLeft()) {
      await logoutUseCase(const NoParams());
      emit(const AuthUnauthenticated());
      return;
    }
    final usuario = result.getOrElse(() => throw Exception());
    if (usuario.primerLogin) {
      emit(AuthRequiresPasswordChange(usuario: usuario));
    } else {
      emit(AuthAuthenticated(usuario: usuario));
    }
  }

  String _labelRol(String rol) {
    return switch (rol) {
      'coordinador_provincial' => 'Coordinador Provincial',
      'coordinador_recinto' => 'Coordinador de Recinto',
      'veedor' => 'Veedor',
      _ => rol,
    };
  }

  Future<void> _onResetAuthState(
    ResetAuthState event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthInitial());
  }
}
