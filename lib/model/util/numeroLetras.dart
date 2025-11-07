class NumeroALetras {
  static String convertir(double numero) {
    int parteEntera = numero.floor();
    int parteDecimal = ((numero - parteEntera) * 100).round();

    String textoEntero = _convertirEntero(parteEntera);
    String textoDecimal = parteDecimal.toString().padLeft(2, '0');

    return "$textoEntero con $textoDecimal/100";
  }

  static String _convertirEntero(int numero) {
    if (numero == 0) return 'cero';

    final unidades = [
      '',
      'uno',
      'dos',
      'tres',
      'cuatro',
      'cinco',
      'seis',
      'siete',
      'ocho',
      'nueve'
    ];

    final especiales = [
      'diez',
      'once',
      'doce',
      'trece',
      'catorce',
      'quince',
      'dieciséis',
      'diecisiete',
      'dieciocho',
      'diecinueve'
    ];

    final decenas = [
      '',
      'diez',
      'veinte',
      'treinta',
      'cuarenta',
      'cincuenta',
      'sesenta',
      'setenta',
      'ochenta',
      'noventa'
    ];

    final centenas = [
      '',
      'ciento',
      'doscientos',
      'trescientos',
      'cuatrocientos',
      'quinientos',
      'seiscientos',
      'setecientos',
      'ochocientos',
      'novecientos'
    ];

    String convertirMenorDe1000(int n) {
      if (n < 10) return unidades[n];
      if (n < 20) return especiales[n - 10];
      if (n < 100) {
        final resto = n % 10;
        return resto == 0
            ? decenas[n ~/ 10]
            : '${decenas[n ~/ 10]} y ${unidades[resto]}';
      }
      if (n < 1000) {
        final resto = n % 100;
        if (n == 100) return 'cien'; // SOLO para 100 exacto
        return '${centenas[n ~/ 100]} ${convertirMenorDe1000(resto)}'.trim();
      }
      return '';
    }

    String resultado = '';

    if (numero >= 1000) {
      final miles = numero ~/ 1000;
      resultado += miles == 1
          ? 'mil'
          : '${convertirMenorDe1000(miles)} mil';
      final resto = numero % 1000;
      if (resto > 0) {
        resultado += ' ${convertirMenorDe1000(resto)}';
      }
    } else {
      resultado = convertirMenorDe1000(numero);
    }

    return resultado.trim();
  }
}
