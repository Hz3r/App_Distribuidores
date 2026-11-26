import 'dart:math' as math;

/// Carrito en memoria: cuántas unidades de cada presentación. Inmutable:
/// cada operación devuelve otro carrito. Lógica pura: sin Flutter ni
/// Supabase. Nunca guarda más de lo disponible que se le indica ni líneas
/// en cero.
class Carrito {
  /// Carrito sin líneas. Es la única forma de crear uno desde fuera: las
  /// líneas solo entran por [agregar] y [fijar], que respetan el invariante.
  const Carrito.vacio() : _cantidades = const {};

  /// [_cantidades] debe ser un mapa nuevo, propio de este carrito, sin
  /// cantidades en cero ni negativas.
  const Carrito._(this._cantidades);

  final Map<String, int> _cantidades;

  /// presentacionId → cantidad (> 0). No modificable.
  Map<String, int> get cantidades => Map.unmodifiable(_cantidades);

  /// Presentaciones distintas en el carrito.
  int get lineas => _cantidades.length;

  int cantidadDe(String presentacionId) => _cantidades[presentacionId] ?? 0;

  /// Suma [cantidad] a la línea y la limita a [disponible]. Con
  /// [disponible] 0 o [cantidad] no positiva, no cambia.
  Carrito agregar(
    String presentacionId,
    int cantidad, {
    required int disponible,
  }) {
    if (disponible <= 0 || cantidad <= 0) return this;
    return fijar(
      presentacionId,
      cantidadDe(presentacionId) + cantidad,
      disponible: disponible,
    );
  }

  /// Reemplaza la cantidad de la línea, limitada a [disponible]. Si queda en
  /// 0 o menos, quita la línea.
  Carrito fijar(
    String presentacionId,
    int cantidad, {
    required int disponible,
  }) {
    final nueva = math.min(cantidad, disponible);
    if (nueva <= 0) return quitar(presentacionId);
    return Carrito._({..._cantidades, presentacionId: nueva});
  }

  Carrito quitar(String presentacionId) {
    if (!_cantidades.containsKey(presentacionId)) return this;
    return Carrito._({..._cantidades}..remove(presentacionId));
  }

  Carrito vaciar() => const Carrito.vacio();

  @override
  bool operator ==(Object other) =>
      other is Carrito &&
      other._cantidades.length == _cantidades.length &&
      _cantidades.entries.every((e) => other._cantidades[e.key] == e.value);

  @override
  int get hashCode => Object.hashAllUnordered(
    _cantidades.entries.map((e) => Object.hash(e.key, e.value)),
  );

  @override
  String toString() => 'Carrito($_cantidades)';
}
