import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../features/carrito/presentation/widgets/icono_carrito.dart';
import '../features/sesion/presentation/sesion_activa.dart';
import '../shared/tema_app.dart';

/// Barra inferior de la bodega: Inicio, Catálogo, Carrito, Pedidos y
/// Perfil, en el orden de las ramas del router.
class BarraCliente extends StatelessWidget {
  const BarraCliente({
    required this.indiceActual,
    required this.alElegir,
    super.key,
  });

  final int indiceActual;
  final ValueChanged<int> alElegir;

  @override
  Widget build(BuildContext context) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        indicatorColor: ColoresApp.azulSuave,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (estados) => estados.contains(WidgetState.selected)
              ? const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: ColoresApp.azul,
                )
              : const TextStyle(fontSize: 12, color: ColoresApp.textoSuave),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (estados) => IconThemeData(
            color: estados.contains(WidgetState.selected)
                ? ColoresApp.azul
                : ColoresApp.textoSuave,
          ),
        ),
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: ColoresApp.borde)),
        ),
        child: NavigationBar(
          selectedIndex: indiceActual,
          onDestinationSelected: alElegir,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              label: 'Catálogo',
            ),
            NavigationDestination(icon: IconoCarrito(), label: 'Carrito'),
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              label: 'Pedidos',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}

/// Estructura de la zona de la bodega: la rama activa del router con la
/// barra inferior. Un repartidor (que solo entra a perfil) la ve sin barra.
class EstructuraCliente extends ConsumerWidget {
  const EstructuraCliente({required this.navegacion, super.key});

  final StatefulNavigationShell navegacion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final esCliente = ref.watch(
      membresiaActivaProvider.select((m) => m?.rol == RolMembresia.cliente),
    );
    return Scaffold(
      body: navegacion,
      bottomNavigationBar: esCliente
          ? BarraCliente(
              indiceActual: navegacion.currentIndex,
              // Tocar la pestaña activa vuelve a su pantalla inicial.
              alElegir: (indice) => navegacion.goBranch(
                indice,
                initialLocation: indice == navegacion.currentIndex,
              ),
            )
          : null,
    );
  }
}
