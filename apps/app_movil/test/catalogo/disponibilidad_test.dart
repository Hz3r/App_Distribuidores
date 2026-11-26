import 'package:app_movil/src/features/catalogo/domain/disponibilidad.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  int disponible(int fisico, int comprometido, int factor) =>
      disponiblePresentacion(
        stockFisico: fisico,
        stockComprometido: comprometido,
        factor: factor,
      );

  test('(120, 30, 12) → 7', () => expect(disponible(120, 30, 12), 7));
  test('(5, 0, 12) → 0', () => expect(disponible(5, 0, 12), 0));
  test('(12, 0, 12) → 1', () => expect(disponible(12, 0, 12), 1));
  test('(10, 10, 1) → 0', () => expect(disponible(10, 10, 1), 0));
  test('comprometido mayor que físico → 0', () {
    expect(disponible(5, 20, 1), 0);
    expect(disponible(5, 40, 12), 0);
  });
}
