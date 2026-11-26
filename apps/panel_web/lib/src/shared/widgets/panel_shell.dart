import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../config/menu.dart';
import '../../config/rutas.dart';
import '../../config/tema_panel.dart';
import '../../features/sesion/domain/acceso.dart';
import '../../features/sesion/presentation/cerrar_sesion.dart';
import '../../features/sesion/presentation/control_acceso.dart';
import '../textos.dart';

/// Marco del panel: menú lateral fijo en pantallas anchas y cajón en
/// pantallas angostas, con la sección actual a la derecha.
class PanelShell extends ConsumerWidget {
  const PanelShell({required this.ubicacion, required this.child, super.key});

  /// Ruta actual, para marcar la sección activa del menú.
  final String ubicacion;

  /// Contenido de la sección.
  final Widget child;

  static const double anchoMenu = 248;

  /// Desde este ancho el menú queda fijo; por debajo es un cajón.
  static const double anchoMenuFijo = 960;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final acceso = ref.watch(controlAccesoProvider);
    final activa = acceso is ConAcceso ? acceso.activa : null;
    final variosDistribuidores =
        acceso is ConAcceso && acceso.membresias.length > 1;

    final menu = _MenuLateral(
      ubicacion: ubicacion,
      membresia: activa,
      puedeCambiarDistribuidor: variosDistribuidores,
      correo: ref.watch(autenticacionProvider).correoActual,
    );
    final contenido = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (activa?.distribuidor case final distribuidor?)
          _AvisoEstado(estado: distribuidor.estado),
        Expanded(child: child),
      ],
    );

    return LayoutBuilder(
      builder: (context, limites) {
        if (limites.maxWidth >= anchoMenuFijo) {
          return Scaffold(
            body: Row(
              children: [
                SizedBox(width: anchoMenu, child: menu),
                Expanded(child: contenido),
              ],
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            // El nombre del negocio, no el de la sección: la sección ya
            // pone su propio título debajo.
            title: Text(activa?.distribuidor?.nombreVisible ?? 'Panel'),
            shape: const Border(
              bottom: BorderSide(color: ColoresPanel.neutro200),
            ),
          ),
          drawer: Drawer(
            width: anchoMenu,
            shape: const RoundedRectangleBorder(),
            child: menu,
          ),
          body: contenido,
        );
      },
    );
  }
}

/// Aviso fijo cuando el distribuidor no puede recibir pedidos nuevos.
class _AvisoEstado extends StatelessWidget {
  const _AvisoEstado({required this.estado});

  final EstadoDistribuidor estado;

  @override
  Widget build(BuildContext context) {
    final mensaje = switch (estado) {
      EstadoDistribuidor.suspendido =>
        'Tu cuenta está suspendida: tus clientes no pueden hacer pedidos '
            'nuevos. Regulariza tu suscripción para reactivarla.',
      EstadoDistribuidor.cancelado =>
        'Tu cuenta está cancelada: tus clientes no pueden hacer pedidos '
            'nuevos.',
      EstadoDistribuidor.prueba || EstadoDistribuidor.activo => null,
    };
    if (mensaje == null) return const SizedBox.shrink();

    return Container(
      color: ColoresPanel.aviso100,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: ColoresPanel.aviso500),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              mensaje,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: ColoresPanel.neutro900),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuLateral extends ConsumerWidget {
  const _MenuLateral({
    required this.ubicacion,
    required this.membresia,
    required this.puedeCambiarDistribuidor,
    required this.correo,
  });

  final String ubicacion;
  final Membresia? membresia;
  final bool puedeCambiarDistribuidor;
  final String? correo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rol = membresia?.rol;
    final distribuidor = membresia?.distribuidor;
    final actual = seccionDe(ubicacion);

    void ir(String ruta) {
      Scaffold.maybeOf(context)?.closeDrawer();
      GoRouter.maybeOf(context)?.go(ruta);
    }

    return Material(
      color: ColoresPanel.primario900,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Marca(
                nombre: distribuidor?.nombreVisible ?? 'Panel',
                logoUrl: distribuidor?.configTema.logoUrl,
                estado: distribuidor == null
                    ? null
                    : estadoDistribuidorLegible(distribuidor.estado),
                alCambiar: puedeCambiarDistribuidor
                    ? () => ir(AppRutas.seleccionDistribuidor)
                    : null,
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.only(left: 12, bottom: 6),
                child: Text(
                  'MENÚ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.7,
                    color: ColoresPanel.neutro500,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    for (final seccion in seccionesPanel)
                      if (rol != null &&
                          seccion.enMenu &&
                          seccion.visiblePara(rol))
                        _ItemMenu(
                          seccion: seccion,
                          activo: seccion == actual,
                          alTocar: () => ir(seccion.ruta),
                        ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Usuario(
                correo: correo,
                rol: rol == null ? null : rolLegible(rol),
                activo: actual?.ruta == AppRutas.cuenta,
                alAbrirCuenta: () => ir(AppRutas.cuenta),
                alCerrarSesion: () => cerrarSesionConAviso(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Marca extends StatelessWidget {
  const _Marca({
    required this.nombre,
    required this.logoUrl,
    required this.estado,
    required this.alCambiar,
  });

  final String nombre;
  final String? logoUrl;
  final String? estado;
  final VoidCallback? alCambiar;

  @override
  Widget build(BuildContext context) {
    final estado = this.estado;
    final logoUrl = this.logoUrl;
    const icono = Icon(
      Icons.storefront_outlined,
      size: 20,
      color: ColoresPanel.blanco,
    );
    final fila = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: logoUrl == null
                  ? ColoresPanel.acento500
                  : ColoresPanel.blanco,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.all(logoUrl == null ? 8 : 3),
            clipBehavior: Clip.antiAlias,
            child: logoUrl == null
                ? icono
                : Image.network(
                    logoUrl,
                    fit: BoxFit.contain,
                    semanticLabel: 'Logo de $nombre',
                    // Si el logo no carga, el ícono de siempre.
                    errorBuilder: (_, _, _) => const ColoredBox(
                      color: ColoresPanel.acento500,
                      child: Center(child: icono),
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ColoresPanel.blanco,
                  ),
                ),
                if (estado != null)
                  Text(
                    estado,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: ColoresPanel.acento500,
                    ),
                  ),
              ],
            ),
          ),
          if (alCambiar != null)
            const Icon(
              Icons.unfold_more_rounded,
              size: 18,
              color: ColoresPanel.neutro300,
            ),
        ],
      ),
    );

    if (alCambiar == null) return fila;
    return Tooltip(
      message: 'Cambiar de distribuidor',
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: alCambiar,
        child: fila,
      ),
    );
  }
}

class _ItemMenu extends StatelessWidget {
  const _ItemMenu({
    required this.seccion,
    required this.activo,
    required this.alTocar,
  });

  final SeccionPanel seccion;
  final bool activo;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Semantics(
        selected: activo,
        button: true,
        child: Material(
          color: activo ? ColoresPanel.primario700 : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: alTocar,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    seccion.icono,
                    size: 20,
                    color: activo
                        ? ColoresPanel.acento500
                        : ColoresPanel.neutro300,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      seccion.etiqueta,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: activo ? FontWeight.w600 : FontWeight.w400,
                        color: activo
                            ? ColoresPanel.blanco
                            : ColoresPanel.neutro300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Usuario extends StatelessWidget {
  const _Usuario({
    required this.correo,
    required this.rol,
    required this.activo,
    required this.alAbrirCuenta,
    required this.alCerrarSesion,
  });

  final String? correo;
  final String? rol;

  /// `true` si Mi cuenta es la sección abierta.
  final bool activo;
  final VoidCallback alAbrirCuenta;
  final VoidCallback alCerrarSesion;

  @override
  Widget build(BuildContext context) {
    final correo = this.correo;
    final rol = this.rol;
    final inicial = (correo == null || correo.isEmpty)
        ? '?'
        : correo[0].toUpperCase();

    return Material(
      color: activo ? ColoresPanel.primario500 : ColoresPanel.primario700,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(
              child: Tooltip(
                message: 'Mi cuenta',
                child: Semantics(
                  button: true,
                  selected: activo,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: alAbrirCuenta,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: ColoresPanel.primario500,
                            child: Text(
                              inicial,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: ColoresPanel.blanco,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  correo ?? 'Sesión iniciada',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: ColoresPanel.blanco,
                                  ),
                                ),
                                if (rol != null)
                                  Text(
                                    rol,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: ColoresPanel.neutro300,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Cerrar sesión',
              onPressed: alCerrarSesion,
              icon: const Icon(
                Icons.logout_rounded,
                size: 18,
                color: ColoresPanel.neutro300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
