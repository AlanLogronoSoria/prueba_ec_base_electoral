import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/request_recovery_usecase.dart';
import '../../domain/usecases/complete_recovery_usecase.dart';
import 'recovery_event.dart';
import 'recovery_state.dart';

class RecoveryBloc extends Bloc<RecoveryEvent, RecoveryState> {
  final RequestRecoveryUseCase requestRecoveryUseCase;
  final CompleteRecoveryUseCase completeRecoveryUseCase;

  RecoveryBloc({
    required this.requestRecoveryUseCase,
    required this.completeRecoveryUseCase,
  }) : super(const RecoveryInitial()) {
    on<RequestPasswordReset>(_onRequestPasswordReset);
    on<CompletePasswordReset>(_onCompletePasswordReset);
    on<ResetRecoveryState>(_onResetRecoveryState);
  }

  Future<void> _onRequestPasswordReset(
    RequestPasswordReset event,
    Emitter<RecoveryState> emit,
  ) async {
    emit(const RecoveryLoading());
    final result = await requestRecoveryUseCase(
      RequestRecoveryParams(cedula: event.cedula),
    );
    result.fold(
      (failure) => emit(RecoveryError(message: failure.message)),
      (email) => emit(RecoveryEmailSent(email: email)),
    );
  }

  Future<void> _onCompletePasswordReset(
    CompletePasswordReset event,
    Emitter<RecoveryState> emit,
  ) async {
    emit(const RecoveryLoading());
    final result = await completeRecoveryUseCase(
      CompleteRecoveryParams(
        userId: event.userId,
        secret: event.secret,
        newPassword: event.newPassword,
      ),
    );
    result.fold(
      (failure) => emit(RecoveryError(message: failure.message)),
      (_) => emit(const RecoveryPasswordReset()),
    );
  }

  void _onResetRecoveryState(
    ResetRecoveryState event,
    Emitter<RecoveryState> emit,
  ) {
    emit(const RecoveryInitial());
  }
}
