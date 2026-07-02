import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:control_electoral_2026/core/error/failure.dart';
import 'package:control_electoral_2026/features/coordinador_provincial/domain/usecases/create_coordinador_recinto_usecase.dart';
import 'package:control_electoral_2026/features/coordinador_provincial/presentation/bloc/provincial_bloc.dart';
import 'package:control_electoral_2026/features/coordinador_provincial/presentation/bloc/provincial_event.dart';
import 'package:control_electoral_2026/features/coordinador_provincial/presentation/bloc/provincial_state.dart';

class MockCreateCoordinadorRecintoUseCase extends Mock
    implements CreateCoordinadorRecintoUseCase {}

void main() {
  late MockCreateCoordinadorRecintoUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockCreateCoordinadorRecintoUseCase();
  });

  ProvincialBloc buildBloc() {
    return ProvincialBloc(
      getRecintosUseCase: MockGetRecintosUseCase(),
      createRecintoUseCase: MockCreateRecintoUseCase(),
      createCoordinadorRecintoUseCase: mockUseCase,
      getAvanceRecintoUseCase: MockGetAvanceRecintoUseCase(),
      getRecintosSinCoordinadorUseCase: MockGetRecintosSinCoordinadorUseCase(),
      getVotosConsolidadosUseCase: MockGetVotosConsolidadosUseCase(),
      getDetalleActaUseCase: MockGetDetalleActaUseCase(),
      getActasPorRecintoUseCase: MockGetActasPorRecintoUseCase(),
    );
  }

  group('CreateCoordinadorRecinto', () {
    const event = CreateCoordinadorRecinto(
      recintoId: 'recinto-1',
      cedula: '1727419184',
      nombres: 'Alan',
      apellidos: 'Logrono',
      telefono: '0999999999',
      correo: 'alan@test.com',
      creadoPor: 'admin-id',
    );

    final params = CreateCoordinadorRecintoParams(
      recintoId: event.recintoId,
      cedula: event.cedula,
      nombres: event.nombres,
      apellidos: event.apellidos,
      telefono: event.telefono,
      correo: event.correo,
      creadoPor: event.creadoPor,
    );

    blocTest<ProvincialBloc, ProvincialState>(
      'Caso 1 — Éxito: emite loading -> CoordinadorRecintoCreated',
      build: () {
        when(() => mockUseCase(params)).thenAnswer(
          (_) async => const Right(null),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        const ProvincialLoading(),
        const CoordinadorRecintoCreated(),
      ],
      verify: (_) {
        verify(() => mockUseCase(params)).called(1);
      },
    );

    blocTest<ProvincialBloc, ProvincialState>(
      'Caso 2 — Cédula inválida: emite error sin llamar al datasource',
      build: () {
        when(() => mockUseCase(params)).thenAnswer(
          (_) async => const Left(ValidationFailure('Cédula inválida')),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        const ProvincialLoading(),
        const ProvincialError(message: 'Cédula inválida'),
      ],
      verify: (_) {
        verify(() => mockUseCase(params)).called(1);
      },
    );

    blocTest<ProvincialBloc, ProvincialState>(
      'Caso 3 — Rol no autorizado (403): emite PermissionFailure',
      build: () {
        when(() => mockUseCase(params)).thenAnswer(
          (_) async => const Left(PermissionFailure(
            'Solo coordinador provincial puede crear coordinadores',
          )),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        const ProvincialLoading(),
        ProvincialError(
          message: 'Solo coordinador provincial puede crear coordinadores',
        ),
      ],
      verify: (_) {
        verify(() => mockUseCase(params)).called(1);
      },
    );

    blocTest<ProvincialBloc, ProvincialState>(
      'Caso 4 — Cédula/correo duplicado (409): emite ServerFailure',
      build: () {
        when(() => mockUseCase(params)).thenAnswer(
          (_) async => const Left(ServerFailure(
            'Ya existe un usuario con la cédula 1727419184',
          )),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        const ProvincialLoading(),
        ProvincialError(
          message: 'Ya existe un usuario con la cédula 1727419184',
        ),
      ],
      verify: (_) {
        verify(() => mockUseCase(params)).called(1);
      },
    );

    blocTest<ProvincialBloc, ProvincialState>(
      'Caso 5 — Falla de red/timeout: emite NetworkFailure, no queda en loading',
      build: () {
        when(() => mockUseCase(params)).thenAnswer(
          (_) async => const Left(NetworkFailure(
            'Error de conexión',
          )),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        const ProvincialLoading(),
        const ProvincialError(message: 'Error de conexión'),
      ],
      verify: (_) {
        verify(() => mockUseCase(params)).called(1);
      },
    );
  });
}

class MockGetRecintosUseCase extends Mock {}
class MockCreateRecintoUseCase extends Mock {}
class MockGetAvanceRecintoUseCase extends Mock {}
class MockGetRecintosSinCoordinadorUseCase extends Mock {}
class MockGetVotosConsolidadosUseCase extends Mock {}
class MockGetDetalleActaUseCase extends Mock {}
class MockGetActasPorRecintoUseCase extends Mock {}
