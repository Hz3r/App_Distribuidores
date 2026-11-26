import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../config/rutas.dart';
import '../../../shared/tema_app.dart';

/// Primera pantalla sin sesión: entrar con un código o con una cuenta.
class BienvenidaScreen extends StatelessWidget {
  const BienvenidaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: ColoresApp.marino,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _Marca(),
                    const SizedBox(height: 32),
                    const _Ilustracion(),
                    const SizedBox(height: 32),
                    Text(
                      'Pide a tu distribuidor en segundos',
                      style: textos.headlineMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Catálogo, precios mayoristas y seguimiento de tus '
                      'pedidos, solo con el código que te dio tu proveedor.',
                      style: textos.bodyLarge?.copyWith(
                        color: ColoresApp.textoSobreMarino,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: 32),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: ColoresApp.turquesa,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => context.push(AppRutas.codigo),
                      child: const Text('Tengo un código de invitación'),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: ColoresApp.azulSuave,
                        foregroundColor: ColoresApp.marino,
                      ),
                      onPressed: () => context.push(AppRutas.auth),
                      child: const Text('Ya tengo cuenta · Ingresar'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay directorio público: solo entras con el código '
                      'de tu distribuidor.',
                      textAlign: TextAlign.center,
                      style: textos.bodySmall?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Insignia con el camión y el nombre de la marca.
class _Marca extends StatelessWidget {
  const _Marca();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: ColoresApp.turquesa,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.local_shipping,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'DistriApp',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

/// Tarjeta con los tres iconos y su leyenda. Decorativa: los lectores de
/// pantalla solo leen la leyenda.
class _Ilustracion extends StatelessWidget {
  const _Ilustracion();

  static const _iconos = [
    Icons.storefront_outlined,
    Icons.local_shipping_outlined,
    Icons.inventory_2_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      decoration: BoxDecoration(
        color: ColoresApp.marinoClaro,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          ExcludeSemantics(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final (i, icono) in _iconos.indexed) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: ColoresApp.marino,
                      borderRadius: BorderRadius.circular(radioApp),
                    ),
                    child: Icon(icono, color: ColoresApp.turquesaClaro),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tu distribuidor · Tu catálogo · Tu pedido',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
