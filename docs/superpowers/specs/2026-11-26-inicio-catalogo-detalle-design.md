# Diseño: inicio, catálogo y detalle de producto en la app móvil

Fecha: 2026-11-26. Pedido por Hz3r con las maquetas "04 Inicio", "05 Catálogo" y
"06 Detalle de producto". Rama de trabajo: `app_movil`.

## Qué se construye

Lo que ve una bodega al entrar: una pantalla de inicio con su resumen, el catálogo de su
distribuidor con búsqueda y filtros, y el detalle de un producto con sus precios por volumen. Y
la barra inferior de navegación (Inicio, Catálogo, Carrito, Pedidos, Perfil).

## Decisiones tomadas al construir (Hz3r pidió generarlo directamente)

1. **Solo se muestra lo que la base de datos respalda.** La maqueta de inicio tiene un cartel con
   "Entrega en 24 h", "Pedido mínimo S/ 150", "Pide antes de las 6 p.m." y "Promos de la semana".
   Nada de eso existe en la base (no hay pedido mínimo, hora de corte ni promociones), así que
   **el cartel no se construye** hasta que existan esos datos. Lo mismo la campana de
   notificaciones: se muestra el icono, sin acción.
2. **Una tarjeta por producto.** Cada tarjeta muestra la presentación principal del producto (la
   de menor `orden`): su nombre, disponibilidad y precio. El botón "+" agrega una unidad de esa
   presentación. En el detalle se puede elegir otra presentación si el producto tiene varias.
3. **El carrito es solo memoria por ahora.** "+" y "Agregar" llenan un carrito en memoria y la
   barra muestra cuántas líneas tiene. La pantalla del carrito y el checkout son el siguiente
   paso; el carrito se vacía al cerrar la app o cambiar de distribuidor.
4. **El precio lo calcula la app igual que la base** (para mostrarlo; la base vuelve a
   calcularlo al crear el pedido): parte del precio de la lista del cliente si la tiene, o del
   precio base; aplica el precio por volumen que corresponda a la cantidad; cobra el menor.
5. **Disponibilidad** = (stock físico − comprometido) ÷ factor de la presentación, hacia abajo.
   En cero: "Agotado" y no se puede agregar.
6. **Búsqueda y filtros se hacen en la app** sobre el catálogo ya cargado (un distribuidor
   pequeño tiene decenas o cientos de productos). Ordenar: nombre, precio menor, precio mayor.
   Filtro por marca. El filtro "Precio" de la maqueta se resuelve con el orden por precio.
7. **Inicio:** saludo con el nombre de la bodega y del distribuidor; buscador (lleva al
   catálogo); último pedido; comprado este mes con la variación contra el mes anterior;
   categorías; "Lo que más pides" (productos más pedidos en los últimos 90 días). Con cuenta
   nueva, sin pedidos, esas secciones muestran un estado vacío en vez de ceros engañosos.
8. **El inicio del cliente pasa a ser la pantalla Inicio** (antes era el catálogo).

## No-objetivos

Pantalla del carrito, checkout, lista y detalle de pedidos, perfil (siguen como marcadores
dentro de la barra); notificaciones; promociones; pedido mínimo y hora de corte; cambios de base
de datos; cualquier cambio en `apps/panel_web`.

## Anti-objetivos

- Mostrar un precio distinto del que la base cobrará.
- Mostrar como disponible algo agotado, o dejar agregar más de lo disponible.
- Inventar datos (carteles, promociones, cifras) que la base no tiene.

## A criterio de quien construya

Composición de widgets, valores exactos de espaciado, textos de estados vacíos y de error
(en español), y cómo se cachea el catálogo en memoria.
