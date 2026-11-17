# Contrato: esquema, modelos, estados y tema

> **Estado: BORRADOR.** Pendiente de revisión conjunta (Hz3r + Jair103).
> Nada de esto está aplicado al proyecto remoto DEV ni PROD. La migración solo se probó en PostgreSQL 16 local.

Este documento es la fuente de verdad del contrato entre la app móvil, el panel web y Supabase.
Si cambias un campo, un estado o una regla aquí, avisa al otro socio antes de tocar código.

---

## 1. Convenciones

| Tema | Regla |
|---|---|
| Multi-tenant | Toda tabla de negocio tiene `distribuidor_id`. RLS activo en todas. |
| Montos | Enteros en **céntimos** (`*_centimos`). Nunca `double`. |
| Nombres en BD | `snake_case`, en español. |
| Nombres en Dart | `camelCase`. El mapeo a `snake_case` es automático (`build.yaml` de `core`). |
| Fechas | `timestamptz` en UTC. |
| IDs | `uuid`, generados con `gen_random_uuid()`. |
| Cambios de esquema | Solo con una migración nueva en `supabase/migrations/`. Nunca se edita una migración ya aplicada. |

---

## 2. Esquema de base de datos

Migración: `supabase/migrations/20261117120000_esquema_inicial.sql`

### Tipos (enums)

| Enum | Valores |
|---|---|
| `rol_usuario` | `admin`, `cliente`, `repartidor` |
| `tipo_presentacion` | `botella`, `six_pack`, `caja` |
| `estado_pedido` | `recibido`, `confirmado`, `en_camino`, `listo_recojo`, `entregado`, `cancelado` |
| `despacho_pedido` | `recojo`, `reparto` |

### Tablas

| Tabla | Propósito | Columnas clave |
|---|---|---|
| `distribuidores` | Tenant | `id`, `nombre`, `config_tema` (jsonb = ConfigTema) |
| `usuarios` | Perfil ligado a `auth.users` | `id` (= auth.uid), `distribuidor_id`, `rol`, `nombre`, `telefono` |
| `clientes_negocio` | Bodega o licorería | `distribuidor_id`, `usuario_id`, `nombre_negocio`, `direccion` |
| `categorias` | Ron, pisco, whisky... | `distribuidor_id`, `nombre`, `orden` |
| `productos` | Catálogo | `distribuidor_id`, `categoria_id`, `nombre`, `descripcion`, `imagen_url`, `activo` |
| `presentaciones` | Lo que se vende | `producto_id`, `tipo`, `nombre`, `precio_base_centimos`, `stock`, `unidades_por_presentacion` |
| `precios_volumen` | Descuento por cantidad | `presentacion_id`, `cantidad_minima`, `precio_centimos` |
| `pedidos` | Pedido de un cliente | `cliente_id`, `repartidor_id`, `estado`, `despacho`, `total_centimos` |
| `pedido_items` | Líneas del pedido | `pedido_id`, `presentacion_id`, `cantidad`, `precio_unitario_centimos` |

Notas:
- `presentaciones.distribuidor_id` está duplicado a propósito, para que RLS no necesite joins.
- `pedido_items.precio_unitario_centimos` guarda el precio **de la compra**. Cambiar el precio después no altera pedidos viejos.
- `stock` está en unidades de la presentación (una caja descuenta `1` de stock de cajas, no 12 botellas). **Por confirmar.**

### Helpers de RLS

| Función | Devuelve |
|---|---|
| `mi_distribuidor_id()` | Distribuidor del usuario autenticado |
| `mi_rol()` | Rol del usuario autenticado |
| `mi_cliente_id()` | Id de `clientes_negocio` si el usuario es un cliente |

Son `security definer` para evitar recursión de RLS.

### Matriz de permisos (RLS)

| Tabla | Admin | Cliente | Repartidor |
|---|---|---|---|
| distribuidores | lee y edita el suyo | lee el suyo | lee el suyo |
| usuarios | gestiona los de su distribuidor | lee los de su distribuidor | lee los de su distribuidor |
| clientes_negocio | gestiona los suyos | lee solo su negocio | no |
| categorias, productos, presentaciones, precios_volumen | lee y escribe | lee | lee |
| pedidos | lee y gestiona todos | lee los suyos | lee los asignados |
| pedido_items | los de sus pedidos | los de sus pedidos | los de sus pedidos asignados |

Reglas clave:
- **El cliente nunca escribe stock ni inserta pedidos directamente.** Lo hace solo `crear_pedido()`.
- **No hay política de INSERT en `pedidos` para clientes.**

---

## 3. Función transaccional: `crear_pedido`

```sql
public.crear_pedido(p_items jsonb, p_despacho despacho_pedido default 'recojo') returns uuid
```

- **Entrada:** `p_items = [{"presentacion_id": "<uuid>", "cantidad": <int>}, ...]`
- **Quién puede llamarla:** solo `authenticated` con un `clientes_negocio` asociado. `anon` no tiene permiso.
- **Qué hace, en una sola transacción:**
  1. Valida que haya ítems y que cada cantidad sea mayor a cero.
  2. Bloquea las filas de `presentaciones` en orden fijo (`FOR UPDATE`) para evitar deadlocks.
  3. Valida que cada presentación exista y pertenezca al distribuidor del cliente.
  4. Crea el pedido en estado `recibido` con total `0`.
  5. Por cada ítem: valida stock (con el stock ya descontado por los ítems anteriores del mismo pedido), aplica precio por volumen (mayor `cantidad_minima` ≤ cantidad) o precio base, descuenta stock, crea la línea.
  6. Actualiza el total y devuelve el id del pedido.
- **Si algo falla:** se revierte todo. No queda pedido ni descuento parcial.

Códigos de error:

| SQLSTATE | Caso |
|---|---|
| `42501` | El usuario no es cliente, o no tiene permiso |
| `22023` | Sin ítems, o cantidad ≤ 0, o despacho inválido |
| `P0002` | Presentación inexistente o de otro distribuidor |
| `P0001` | Stock insuficiente (el mensaje indica cuánto había y cuánto se pidió) |

Pruebas: `supabase/tests/crear_pedido_test.sql` (6 casos: éxito con precio por volumen, rechazo por stock sin cambios, validación acumulada dentro del pedido, aislamiento RLS entre clientes, cliente sin escritura directa de stock, `anon` bloqueado).

---

## 4. Estados del pedido

Enum `EstadoPedido` en Dart (`packages/core/lib/src/models/enums.dart`):

| Estado (BD) | Dart | Quién lo pone | Significado |
|---|---|---|---|
| `recibido` | `recibido` | Sistema, al crear | El cliente envió el pedido |
| `confirmado` | `confirmado` | Admin | El distribuidor lo acepta |
| `en_camino` | `enCamino` | Admin o repartidor | Va hacia el cliente (despacho `reparto`) |
| `listo_recojo` | `listoRecojo` | Admin | Listo para que el cliente lo recoja (despacho `recojo`) |
| `entregado` | `entregado` | Admin o repartidor | Cerrado con éxito |
| `cancelado` | `cancelado` | Admin | Anulado. Devuelve stock. **Por definir.** |

**Pendiente:** validar transiciones válidas (por ejemplo, no pasar de `entregado` a `recibido`) con un trigger, y definir si cancelar devuelve el stock. Hoy la BD no impone transiciones.

---

## 5. Modelos (Dart, `packages/core`)

Todos son `freezed` con JSON en `snake_case`.

| Modelo | Campos |
|---|---|
| `Distribuidor` | id, nombre, configTema? |
| `ConfigTema` | nombre, logoUrl?, colorPrimario, colorSecundario |
| `Usuario` | id, distribuidorId, rol, nombre, telefono? |
| `ClienteNegocio` | id, distribuidorId, nombreNegocio, usuarioId?, direccion? |
| `Categoria` | id, distribuidorId, nombre, orden |
| `Producto` | id, distribuidorId, categoriaId, nombre, descripcion?, imagenUrl?, activo |
| `Presentacion` | id, productoId, tipo, nombre, precioBaseCentimos, stock, unidadesPorPresentacion |
| `PrecioVolumen` | id, presentacionId, cantidadMinima, precioCentimos |
| `Pedido` | id, distribuidorId, clienteId, estado, totalCentimos, creadoEn, items |
| `PedidoItem` | id, pedidoId, presentacionId, cantidad, precioUnitarioCentimos |

Nota: `Pedido` y `PedidoItem` de Dart no tienen todavía `despacho` ni `repartidorId`. Hay que añadirlos al modelo cuando se implemente la pantalla.

---

## 6. JSON de tema (`config_tema`)

Se guarda en `distribuidores.config_tema` (jsonb):

```json
{
  "nombre": "Licores del Norte",
  "logo_url": "https://.../logo.png",
  "color_primario": "#1F3A5F",
  "color_secundario": "#F2A900"
}
```

- Colores en `#RRGGBB`. `ThemeBuilder.desde()` rechaza otros formatos con `FormatException`.
- `logo_url` puede ser `null`.

---

## 7. Rol del usuario en la app

La redirección por rol lee `app_metadata.rol` de la sesión (`apps/*/lib/src/router/app_router.dart`).

- `app_metadata` solo lo escribe el servidor. El cliente no puede cambiarlo.
- **Pendiente (Jair):** cómo se sincroniza con `usuarios.rol`. Opciones: un trigger en BD que copie el rol a `auth.users.raw_app_meta_data`, o un hook de Auth.

---

## 8. Seed de desarrollo

`supabase/seed.sql` (solo local y DEV):
- 1 distribuidor: "Licores del Norte (demo)"
- 30 productos en 5 categorías (ron, pisco, whisky, cerveza, vino)
- 66 presentaciones (botella, caja x12; six pack x6 para cervezas)
- 60 precios por volumen
- 1 admin, 3 clientes, 1 repartidor (cuentas en `auth.users` **sin contraseña**: sirven para RLS, no para iniciar sesión)

---

## 9. Pendiente antes de aprobar este contrato

- [ ] Confirmar `stock` por unidad de presentación (vs. por botella).
- [ ] Definir transiciones válidas de `estado_pedido` y si cancelar devuelve stock.
- [ ] Decidir cómo se sincroniza el rol a `app_metadata`.
- [ ] Añadir `despacho` y `repartidor_id` al modelo `Pedido` de Dart.
- [ ] Validar la migración con `supabase db reset` cuando haya Supabase CLI y Docker.
- [ ] Confirmar que los usuarios del seed se pueden insertar en el `auth.users` real de Supabase local.
- [ ] Revisar las políticas RLS con `get_advisors` (Supabase) una vez aplicadas a DEV.
