import 'package:flutter_test/flutter_test.dart';
import 'package:control_electoral_2026/core/utils/cedula_validator.dart';

void main() {
  group('CedulaValidator', () {
    test('debe aceptar una cédula válida de Pichincha (17)', () {
      expect(CedulaValidator.isValid('1723456784'), isTrue);
    });

    test('debe aceptar cédula válida con dígito verificador 0', () {
      expect(CedulaValidator.isValid('1750000000'), isTrue);
    });

    test('debe aceptar cédula válida de provincia 01 (Azuay)', () {
      expect(CedulaValidator.isValid('0101234565'), isTrue);
    });

    test('debe aceptar cédula válida de provincia 24 (Santa Elena)', () {
      expect(CedulaValidator.isValid('2407863147'), isTrue);
    });

    test('debe rechazar cédula con menos de 10 dígitos', () {
      expect(CedulaValidator.isValid('123456789'), isFalse);
    });

    test('debe rechazar cédula con más de 10 dígitos', () {
      expect(CedulaValidator.isValid('12345678901'), isFalse);
    });

    test('debe rechazar cédula con letras', () {
      expect(CedulaValidator.isValid('12A4567890'), isFalse);
    });

    test('debe rechazar cédula vacía', () {
      expect(CedulaValidator.isValid(''), isFalse);
    });

    test('debe rechazar cédula con provincia 00', () {
      expect(CedulaValidator.isValid('0034567890'), isFalse);
    });

    test('debe rechazar cédula con provincia 25', () {
      expect(CedulaValidator.isValid('2534567890'), isFalse);
    });

    test('debe rechazar cédula con tercer dígito >= 6', () {
      expect(CedulaValidator.isValid('1763456789'), isFalse);
    });

    test('debe rechazar cédula con dígito verificador incorrecto', () {
      expect(CedulaValidator.isValid('1723456780'), isFalse);
    });

    test('debe rechazar cédula con todos dígitos iguales', () {
      expect(CedulaValidator.isValid('1111111111'), isFalse);
    });
  });
}
