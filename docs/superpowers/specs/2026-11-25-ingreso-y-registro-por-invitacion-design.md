# Diseño: bienvenida, código de invitación, registro e ingreso en la app móvil

Fecha: 2026-11-25. Aprobado por Hz3r en conversación, con las maquetas "01 Bienvenida",
"02 Código de invitación" y "03 Registro del negocio". Rama de trabajo: `app_movil`.

## Qué se construye

El camino de una bodega nueva: abre la app, escribe el código que le dio su distribuidor, ve a
quién se une, completa sus datos, crea su cuenta y entra al catálogo. Y el ingreso de quien ya
tiene cuenta.

## Decisiones de Hz3r

1. **Ingreso con correo y contraseña**, igual que el panel. No hay verificación por SMS ni
   pantalla de código de 6 dígitos. El celular del formulario queda como dato de contacto.
2. **El formulario de registro llega con los datos que puso el distribuidor** y la bodega los
   completa o corrige: el nombre del negocio es de solo lectura; el RUC o DNI se puede completar
   solo si está vacío; encargado, celular y dirección son editables.
3. **El código se valida antes de tener cuenta**, como en la maqueta.

## Objetivos

- Las tres pantallas de la maqueta, más una de ingreso con el mismo estilo.
- Una persona sin código no puede descubrir códigos probando al azar.
- La base sigue siendo la que decide: la app no escribe la bodega directamente.

## No-objetivos

- Recuperar la contraseña, cambiar correo, escanear un QR. Quedan para después.
- Textos legales: la casilla de términos es obligatoria y los enlaces quedan sin destino.
- Catálogo y demás pantallas: siguen como marcadores.
- Cualquier cambio en `apps/panel_web`.

## Anti-objetivos

- Que el código sirva de contraseña o dé acceso sin cuenta.
- Que una bodega pueda cambiar su nombre comercial, su lista de precios o su crédito.
- Que un fallo a mitad del registro deje una cuenta creada sin vincular y sin forma de retomar.

## Enfoques

1. **Código primero, cuenta después, como la maqueta (elegido).** Exige una función nueva que
   se puede llamar sin sesión, con freno por dirección de red.
2. Cuenta primero y código después. Más simple y no necesita la consulta anónima, pero rompe la
   maqueta y pide correo y contraseña antes de saber si el código sirve.
3. Que la bodega escriba todos sus datos desde cero. Descartado: cambia el panel de Jair y la
   invitación dejaría de estar atada a una bodega.

## Cómo funciona

**Base de datos (migración nueva; las seis anteriores están aplicadas y no se editan):**

- `consultar_invitacion(código)`: se puede llamar **sin sesión**. Si el código es canjeable
  devuelve el nombre visible del distribuidor, el rol y, para invitaciones de cliente, los datos
  de la bodega (nombre, documento, dirección, referencia, teléfono). Si no, devuelve vacío. Con
  5 consultas fallidas en 15 minutos desde la misma dirección de red, rechaza las siguientes.
  Quien tenga el código ve esos datos antes de registrarse: se acepta porque el código es de un
  solo uso, vence y solo lo tiene la bodega invitada.
- `completar_datos_negocio(...)`: la bodega con sesión actualiza dirección, referencia y
  teléfono de **su** bodega, y el documento solo si estaba vacío. Nunca el nombre.
- El canje sigue siendo `canjear_invitacion`, sin cambios.

**App:**

1. *Bienvenida.* "Tengo un código de invitación" y "Ya tengo cuenta · Ingresar".
2. *Código.* Ocho casillas. Al completarlas se consulta; si es válido muestra "te invita como…"
   y habilita Continuar.
3. *Registro.* Datos de la bodega precargados, más nombre del encargado, celular, correo,
   contraseña y la casilla de términos.
4. Al crear la cuenta, el código y los datos editados viajan guardados en la cuenta como
   **registro pendiente**. En cuanto hay sesión, la app canjea el código, guarda los datos y
   borra el pendiente. Así funciona igual si Supabase exige confirmar el correo (la sesión llega
   después, al ingresar) o no (la sesión llega al instante), y un corte a mitad se retoma solo en
   el siguiente ingreso.
5. Si Supabase exige confirmar el correo, tras crear la cuenta se muestra "Revisa tu correo".
6. *Ingreso.* Correo y contraseña.

Una persona que ya tiene cuenta y recibe un código de otro distribuidor ingresa primero y luego
canjea: en la pantalla de código, con sesión iniciada, "Continuar" canjea directamente.

## A criterio de quien construya

Nombres internos, composición de widgets, valores exactos de color (tomados de la maqueta:
fondo azul marino, acento verde azulado, botón principal azul), animaciones.
