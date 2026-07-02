class CedulaValidator {
  CedulaValidator._();

  static bool isValid(String cedula) {
    if (cedula.length != 10) return false;
    if (!RegExp(r'^\d{10}$').hasMatch(cedula)) return false;

    final provincia = int.parse(cedula.substring(0, 2));
    if (provincia < 1 || provincia > 24) return false;

    final tercerDigito = int.parse(cedula[2]);
    if (tercerDigito >= 6) return false;

    final verificador = int.parse(cedula[9]);
    final coeficientes = [2, 1, 2, 1, 2, 1, 2, 1, 2];
    var suma = 0;

    for (var i = 0; i < 9; i++) {
      var producto = int.parse(cedula[i]) * coeficientes[i];
      if (producto >= 10) producto -= 9;
      suma += producto;
    }

    final digitoEsperado = suma % 10 == 0 ? 0 : 10 - (suma % 10);
    return digitoEsperado == verificador;
  }
}
