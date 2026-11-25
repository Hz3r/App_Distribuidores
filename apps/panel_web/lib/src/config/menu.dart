import 'package:core/core.dart';
import 'package:material_ui/material_ui.dart';

import 'rutas.dart';

/// Una sección del panel: su ruta, cómo se muestra en el menú lateral y quién
/// puede entrar.
class SeccionPanel {
  const SeccionPanel({
    required this.ruta,
    required this.etiqueta,
    required this.icono,
    this.soloAdmin = false,
  });

  final String ruta;
  final String etiqueta;
  final IconData icono;

  /// `true` si el vendedor no entra (la BD tampoco le deja escribir ahí).
  final bool soloAdmin;

  bool visiblePara(RolMembresia rol) => !soloAdmin || rol == RolMembresia.admin;
}

/// Secciones del panel en el orden del menú. Única fuente de verdad: el menú,
/// la redirección y el retorno tras iniciar sesión salen de esta lista.
const seccionesPanel = <SeccionPanel>[
  SeccionPanel(
    ruta: AppRutas.dashboard,
    etiqueta: 'Dashboard',
    icono: Icons.bar_chart_rounded,
  ),
  SeccionPanel(
    ruta: AppRutas.productos,
    etiqueta: 'Productos',
    icono: Icons.sell_outlined,
  ),
  SeccionPanel(
    ruta: AppRutas.disponibilidad,
    etiqueta: 'Disponibilidad',
    icono: Icons.inventory_2_outlined,
  ),
  SeccionPanel(
    ruta: AppRutas.clientes,
    etiqueta: 'Clientes',
    icono: Icons.storefront_outlined,
  ),
  SeccionPanel(
    ruta: AppRutas.invitaciones,
    etiqueta: 'Invitaciones',
    icono: Icons.key_outlined,
  ),
  SeccionPanel(
    ruta: AppRutas.pedidos,
    etiqueta: 'Pedidos',
    icono: Icons.receipt_long_outlined,
  ),
  SeccionPanel(
    ruta: AppRutas.reportes,
    etiqueta: 'Reportes',
    icono: Icons.trending_up_rounded,
  ),
  SeccionPanel(
    ruta: AppRutas.configuracion,
    etiqueta: 'Configuración',
    icono: Icons.tune_rounded,
    soloAdmin: true,
  ),
];

/// La sección a la que pertenece [ubicacion] (ella o una subruta), o null.
SeccionPanel? seccionDe(String ubicacion) {
  for (final seccion in seccionesPanel) {
    if (ubicacion == seccion.ruta || ubicacion.startsWith('${seccion.ruta}/')) {
      return seccion;
    }
  }
  return null;
}
