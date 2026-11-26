import 'package:material_ui/material_ui.dart';

import '../../../config/tema_panel.dart';
import '../domain/validaciones.dart';

/// Maqueta de la app del cliente con la marca elegida: barra superior en el
/// color principal, logo y nombre, y un par de productos con el color
/// secundario en la etiqueta de oferta. Es una guía, no la app real.
class VistaPreviaApp extends StatelessWidget {
  const VistaPreviaApp({
    required this.nombre,
    required this.logo,
    required this.colorPrimario,
    required this.colorSecundario,
    super.key,
  });

  final String nombre;
  final Widget? logo;
  final Color colorPrimario;
  final Color colorSecundario;

  @override
  Widget build(BuildContext context) {
    final sobrePrimario = Color(textoSobre(colorPrimario.toARGB32()));
    final sobreSecundario = Color(textoSobre(colorSecundario.toARGB32()));
    final logo = this.logo;

    return Semantics(
      label: 'Vista previa de la app de tus clientes',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ExcludeSemantics(
            child: Container(
              width: 280,
              height: 500,
              decoration: BoxDecoration(
                color: ColoresPanel.neutro50,
                border: Border.all(color: ColoresPanel.neutro900, width: 6),
                borderRadius: BorderRadius.circular(32),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    color: colorPrimario,
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: ColoresPanel.blanco,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(3),
                          child:
                              logo ??
                              Icon(
                                Icons.storefront_outlined,
                                size: 18,
                                color: colorPrimario,
                              ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            nombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: sobrePrimario,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 20,
                          color: sobrePrimario,
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Catálogo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ColoresPanel.neutro900,
                      ),
                    ),
                  ),
                  for (final (producto, precio, oferta) in const [
                    ('Cerveza Lager', 'Caja x12 · S/ 54.00', true),
                    ('Ron Añejo', 'Botella · S/ 45.90', false),
                    ('Agua sin gas', 'Paquete x6 · S/ 9.50', false),
                  ])
                    _Producto(
                      nombre: producto,
                      precio: precio,
                      oferta: oferta,
                      colorPrimario: colorPrimario,
                      sobrePrimario: sobrePrimario,
                      colorSecundario: colorSecundario,
                      sobreSecundario: sobreSecundario,
                    ),
                  const Spacer(),
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: colorPrimario,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Ver carrito · S/ 54.00',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: sobrePrimario,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Así se verá la app de tus clientes.',
            style: TextStyle(fontSize: 12, color: ColoresPanel.neutro500),
          ),
        ],
      ),
    );
  }
}

class _Producto extends StatelessWidget {
  const _Producto({
    required this.nombre,
    required this.precio,
    required this.oferta,
    required this.colorPrimario,
    required this.sobrePrimario,
    required this.colorSecundario,
    required this.sobreSecundario,
  });

  final String nombre;
  final String precio;
  final bool oferta;
  final Color colorPrimario;
  final Color sobrePrimario;
  final Color colorSecundario;
  final Color sobreSecundario;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ColoresPanel.blanco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColoresPanel.neutro200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ColoresPanel.neutro100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.local_drink_outlined,
              size: 20,
              color: ColoresPanel.neutro500,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ColoresPanel.neutro900,
                        ),
                      ),
                    ),
                    if (oferta) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: colorSecundario,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Oferta',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: sobreSecundario,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  precio,
                  style: const TextStyle(
                    fontSize: 11,
                    color: ColoresPanel.neutro500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: colorPrimario,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add_rounded, size: 18, color: sobrePrimario),
          ),
        ],
      ),
    );
  }
}
