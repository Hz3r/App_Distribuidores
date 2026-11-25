/// Convierte lo que la persona escribe como precio a céntimos, sin pasar por
/// `double`. Acepta `62.90`, `62,90`, `S/ 62.90`, `1,234.50` y `1234`.
/// Devuelve null si no es un monto válido (negativo, más de 2 decimales, texto).
int? parsearSoles(String texto) {
  var limpio = texto.replaceAll(RegExp(r'\s'), '');
  if (limpio.toUpperCase().startsWith('S/')) limpio = limpio.substring(2);
  if (limpio.isEmpty) return null;

  if (limpio.contains(',') && limpio.contains('.')) {
    // Con los dos signos, la coma separa miles: 1,234.50.
    limpio = limpio.replaceAll(',', '');
  } else if (RegExp(r'^\d+,\d{1,2}$').hasMatch(limpio)) {
    // Solo coma con 1 o 2 cifras después: es el decimal (62,90).
    limpio = limpio.replaceFirst(',', '.');
  } else if (RegExp(r'^\d{1,3}(,\d{3})+$').hasMatch(limpio)) {
    // Solo comas en grupos de 3: son miles (1,234).
    limpio = limpio.replaceAll(',', '');
  }

  final partes = RegExp(r'^(\d{1,9})(?:\.(\d{1,2}))?$').firstMatch(limpio);
  if (partes == null) return null;
  final soles = int.parse(partes.group(1)!);
  final decimales = (partes.group(2) ?? '').padRight(2, '0');
  return soles * 100 + int.parse(decimales);
}

/// Céntimos como texto editable, sin símbolo: `6290` → `62.90`.
String solesEditables(int centimos) {
  final soles = centimos ~/ 100;
  final resto = (centimos % 100).toString().padLeft(2, '0');
  return '$soles.$resto';
}

/// Entero no negativo escrito por la persona, o null. Tope: 9 cifras.
int? parsearEntero(String texto) {
  final limpio = texto.trim();
  if (!RegExp(r'^\d{1,9}$').hasMatch(limpio)) return null;
  return int.parse(limpio);
}

/// Plural simple de una unidad: agrega "s" tras vocal y "es" tras
/// consonante; las abreviaturas (`kg`, `ml`) y lo que ya termina en "s" no
/// cambian. `botella` → `botellas`, `unidad` → `unidades`.
String pluralDe(String unidad) {
  final limpia = unidad.trim();
  if (limpia.length <= 2) return limpia;
  final ultima = limpia[limpia.length - 1].toLowerCase();
  if (ultima == 's') return limpia;
  return 'aeiouáéíóú'.contains(ultima) ? '${limpia}s' : '${limpia}es';
}

/// `1 botella`, `12 botellas`, `3 unidades`.
String cantidadConUnidad(int cantidad, String unidad) {
  final limpia = unidad.trim();
  if (limpia.isEmpty) return '$cantidad';
  return '$cantidad ${cantidad == 1 ? limpia : pluralDe(limpia)}';
}

const _sinTilde = {
  'á': 'a',
  'é': 'e',
  'í': 'i',
  'ó': 'o',
  'ú': 'u',
  'ü': 'u',
  'ñ': 'n',
};

/// Texto en minúsculas y sin tildes, para buscar sin que importe cómo se
/// escribió ("anejo" encuentra "Añejo").
String normalizarBusqueda(String texto) {
  final salida = StringBuffer();
  for (final caracter in texto.trim().toLowerCase().split('')) {
    salida.write(_sinTilde[caracter] ?? caracter);
  }
  return salida.toString();
}

const _meses = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'set',
  'oct',
  'nov',
  'dic',
];

/// Fecha corta en la hora del dispositivo: `24 nov 2026`.
String fechaCorta(DateTime fecha) {
  final local = fecha.toLocal();
  return '${local.day} ${_meses[local.month - 1]} ${local.year}';
}

/// Fecha y hora cortas en la hora del dispositivo: `24 nov, 10:05`.
String fechaHoraCorta(DateTime fecha) {
  final local = fecha.toLocal();
  final hora = '${local.hour}'.padLeft(2, '0');
  final minuto = '${local.minute}'.padLeft(2, '0');
  return '${local.day} ${_meses[local.month - 1]}, $hora:$minuto';
}

const _mesesCompletos = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'setiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

const _diasCortos = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];

const _diasCompletos = [
  'lunes',
  'martes',
  'miércoles',
  'jueves',
  'viernes',
  'sábado',
  'domingo',
];

/// Nombre del mes (1 a 12): `noviembre`.
String nombreMes(int mes) => _mesesCompletos[mes - 1];

/// Día de la semana abreviado: `lun`.
String diaCorto(DateTime fecha) => _diasCortos[fecha.weekday - 1];

/// Fecha larga en la hora del dispositivo: `miércoles 25 de noviembre`.
String fechaLarga(DateTime fecha) {
  final local = fecha.toLocal();
  return '${_diasCompletos[local.weekday - 1]} ${local.day} de '
      '${nombreMes(local.month)}';
}
