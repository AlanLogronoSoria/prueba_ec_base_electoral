import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:control_electoral_2026/core/error/failure.dart';
import 'package:control_electoral_2026/features/coordinador_recinto/domain/usecases/create_veedor_usecase.dart';
import 'package:control_electoral_2026/features/coordinador_recinto/presentation/bloc/recinto_bloc.dart';
import 'package:control_electoral_2026/features/coordinador_recinto/presentation/bloc/recinto_event.dart';
import 'package:control_electoral_2026/features/coordinador_recinto/presentation/bloc/recinto_state.dart';

class MockCreateVeedorUseCase extends Mock implements CreateVeedorUseCase {}
class MockDatasource extends Mock implements RecintoRemoteDatasource {}
class MockGetMesasUseCase extends Mock {}
class MockAsignarVeedorUseCase extends Mock {}
class MockCorregirActaUseCase extends Mock {}
class MockGetOrganizacionesRecintoUseCase extends Mock {}
class MockGetActaPorMesaUseCase extends Mock {}
class MockSubirFotoActaRecintoUseCase extends Mock {}
class MockGetAvanceUseCase extends Mock {}

void main() {
  late MockCreateVeedorUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockCreateVeedorUseCase();
  });

  RecintoBloc buildBloc() {
    return RecintoBloc(
      datasource: MockDatasource(),
      getMesasUseCase: MockGetMesasUseCase(),
      createVeedorUseCase: mockUseCase,
      asignarVeedorUseCase: MockAsignarVeedorUseCase(),
      corregirActaUseCase: MockCorregirActaUseCase(),
      getOrganizacionesUseCase: MockGetOrganizacionesRecintoUseCase(),
      getActaPorMesaUseCase: MockGetActaPorMesaUseCase(),
      subirFotoActaUseCase: MockSubirFotoActaRecintoUseCase(),
      getAvanceUseCase: MockGetAvanceUseCase(),
    );
  }

  group('CreateVeedor', () {
    const event = CreateVeedor(
      cedula: '1112223334',
      nombres: 'Jose',
      apellidos: 'Vera',
      telefono: '0997000001',
      correo: 'jose@test.com',
      creadoPor: 'coord-id',
      mesaId: 'mesa-1',
    );

    final params = CreateVeedorParams(
      cedula: event.cedula,
      nombres: event.nombres,
      apellidos: event.apellidos,
      telefono: event.telefono,
      correo: event.correo,
      creadoPor: event.creadoPor,
      mesaId: event.mesaId,
    );

    blocTest<RecintoBloc, RecintoState>(
      'Caso 1 — Éxito: emite loading -> VeedorCreated',
      build: () {
        when(() => mockUseCase(params)).thenAnswer(
          (_) async => const Right('veedor-id-123'),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        const RecintoLoading(),
        const VeedorCreated(),
      ],
      verify: (_) {
        verify(() => mockUseCase(params)).called(1);
      },
    );

    blocTest<RecintoBloc, RecintoState>(
      'Caso 2 — Cédula inválida: emite error sin llamar al datasource',
      build: () {
        when(() => mockUseCase(params)).thenAnswer(
          (_) async => const Left(ValidationFailure('Cédula inválida')),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        const RecintoLoading(),
        const RecintoError(message: 'Cédula inválida'),
      ],
      verify: (_) {
        verify(() => mockUseCase(params)).called(1);
      },
    );

    blocTest<RecintoBloc, RecintoState>(
      'Caso 3 — Rol no autorizado (403): emite PermissionFailure',
      build: () {
        when(() => mockUseCase(params)).thenAnswer(
          (_) async => const Left(PermissionFailure(
            'Solo coordinador de recinto puede crear veedores',
          )),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        const RecintoLoading(),
        RecintoError(
          message: 'Solo coordinador de recinto puede crear veedores',
        ),
      ],
      verify: (_) {
        verify(() => mockUseCase(params)).called(1);
      },
    );

    blocTest<RecintoBloc, RecintoState>(
      'Caso 4 — Cédula/correo duplicado (409): emite ServerFailure',
      build: () {
        when(() => mockUseCase(params)).thenAnswer(
          (_) async => const Left(ServerFailure(
            'Ya existe un usuario con la cédula 1112223334',
          )),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        const RecintoLoading(),
        RecintoError(
          message: 'Ya existe un usuario con la cédula 1112223334',
        ),
      ],
      verify: (_) {
        verify(() => mockUseCase(params)).called(1);
      },
    );

    blocTest<RecintoBloc, RecintoState>(
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
        const RecintoLoading(),
        const RecintoError(message: 'Error de conexión'),
      ],
      verify: (_) {
        verify(() => mockUseCase(params)).called(1);
      },
    );
  });
}
