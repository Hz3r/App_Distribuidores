# App Distribuidores

SaaS de pedidos B2B para pequeños distribuidores. El piloto es un distribuidor de licores:
sus clientes (bodegas y licorerías) ven stock y precios mayoristas en la app, compran, y el
distribuidor recibe una notificación y despacha (recojo o repartidor).

## Estructura

```
apps/
  app_movil/     App Flutter (Android e iOS): rol cliente y rol repartidor
  panel_web/     Panel Flutter Web del distribuidor (rol admin)
packages/
  core/          Modelos, cliente Supabase, tema y utilidades compartidas
supabase/
  migrations/    Esquema de BD (SQL versionado)
  functions/     Edge Functions
  seed.sql       Datos de prueba para local y DEV
  tests/         Pruebas SQL (reglas de negocio, RLS y permisos)
docs/            Arquitectura, flujo de Git y contrato de datos
env/             Entornos (los reales están ignorados por git)
```

Documentación:
- [Arquitectura](docs/arquitectura.md)
- [Flujo de Git](docs/flujo-git.md)
- [Contrato de datos (BORRADOR)](docs/contrato.md)

## Requisitos

| Herramienta | Versión | Notas |
|---|---|---|
| Git | reciente | |
| FVM | 4.x | Gestiona la versión de Flutter del proyecto |
| Flutter | **3.50.0** (vía FVM) | Fijada en `.fvmrc` |
| Dart | 3.14 (incluido con Flutter) | |
| Supabase CLI | reciente | Solo para trabajar en local (`db:reset`) |
| Docker | reciente | Lo necesita `supabase start` |
| Android SDK | — | Solo para compilar APK |
| Xcode | — | Solo para iOS. Requiere macOS. |
| Chrome | — | Para el panel web |

Instalar FVM:

```bash
dart pub global activate fvm
```

## Desde cero

### 1. Clonar y fijar Flutter

```bash
git clone https://github.com/Hz3r/App_Distribuidores.git
cd App_Distribuidores
git checkout main

fvm install 3.50.0
fvm use 3.50.0
```

Después de `fvm use`, usa `fvm flutter` y `fvm dart`, o agrega `.fvm/flutter_sdk/bin` al PATH. VS Code ya apunta a `.fvm/flutter_sdk` (`.vscode/settings.json`).

### 2. Crear tu archivo de entorno

```bash
cp env/dev.example.json env/dev.json
```

Edita `env/dev.json` y pon la URL y la **publishable key** de DEV (pídela a Jair). No pongas nunca la secret key.

```json
{
  "SUPABASE_URL": "https://<project-ref>.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "sb_publishable_..."
}
```

`env/dev.json` y `env/prod.json` están en `.gitignore`. **Nunca los subas al repo.**

### 3. Instalar dependencias y generar código

```bash
dart pub global activate melos   # opcional: para usar `melos` directo
flutter pub get                  # resuelve el workspace completo
dart run melos run gen           # genera freezed, json_serializable y riverpod
```

### 4. Verificar

```bash
dart run melos run analyze
dart run melos run test
```

### 5. Ejecutar

```bash
dart run melos run run:movil     # app móvil con env/dev.json
dart run melos run run:web       # panel web en Chrome con env/dev.json
```

En VS Code usa el panel **Run and Debug** (o `F5`) con una de estas configuraciones:
**App móvil en Chrome (dev)**, **App móvil en dispositivo (dev)** o **Panel web (dev)**.

> No uses el botón "Run" que aparece sobre `main()`: no pasa `env/dev.json` y la app muestra
> "Falta la configuración de Supabase". Lo mismo pasa con `flutter run` sin
> `--dart-define-from-file`.

Para la app móvil en Chrome desde la terminal:

```bash
cd apps/app_movil
flutter run -d chrome --dart-define-from-file=../../env/dev.json
```

## Comandos de Melos

| Comando | Qué hace |
|---|---|
| `dart run melos bootstrap` | Resuelve dependencias del workspace |
| `dart run melos run analyze` | Analiza todos los paquetes |
| `dart run melos run format` | Verifica formato (no modifica). Para aplicar: `dart format apps packages` |
| `dart run melos run test` | Corre los tests de cada paquete |
| `dart run melos run gen` | Corre build_runner en todos los paquetes |
| `dart run melos run run:movil` | Ejecuta la app móvil (DEV) |
| `dart run melos run run:web` | Ejecuta el panel web (DEV) |
| `dart run melos run db:reset` | Reinicia la BD local de Supabase (`supabase db reset`) |
| `dart run melos run db:test` | Corre las pruebas SQL (`bash supabase/tests/run.sh`) |

## Supabase

### Local (recomendado para probar cambios de BD)

Requiere Docker y Supabase CLI.

```bash
supabase start
dart run melos run db:reset      # aplica migraciones y seed
```

### Pruebas SQL

Solo requieren PostgreSQL (16 o 17) y `psql`; no hacen falta Docker ni Supabase CLI. Aplican las
migraciones sobre una base temporal (`distribuidores_test`), corren las pruebas y al final cargan
el seed. Usan `PGHOST`, `PGPORT`, `PGUSER` y `PGPASSWORD` del entorno y terminan con `TODO OK`.

```bash
bash supabase/tests/run.sh       # todo: migraciones, pruebas y seed
bash supabase/tests/run.sh 3     # solo las primeras 3 migraciones y sus pruebas
dart run melos run db:test       # igual que la primera línea
```

En CI corren en el job `sql` (Postgres 17). Detalle en [docs/contrato.md](docs/contrato.md), sección 8.

### Proyecto DEV

- Ref: `srsrgkwkbhhpdhaeiqyt`
- Las migraciones `20261122…` ya están aplicadas en DEV. Las nuevas se aplican (`supabase db push`)
  cuando pasan `supabase/tests/run.sh` y CI.

```bash
supabase login                                          # lo ejecuta cada socio
supabase link --project-ref srsrgkwkbhhpdhaeiqyt        # pide la contraseña de la BD
```

## Firebase (pendiente)

Las dependencias de FCM ya están en `apps/app_movil`, pero **no se inicializan todavía**.
Para activarlas, cada socio debe:

1. Tener acceso al proyecto de Firebase del piloto.
2. Instalar FlutterFire CLI: `dart pub global activate flutterfire_cli`
3. En `apps/app_movil`, ejecutar `flutterfire configure` (es interactivo; elige el proyecto).
4. Esto genera `lib/firebase_options.dart`, que está en `.gitignore`. No lo subas.
5. Agregar `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` en `main.dart`.
6. Configurar las claves APNs (iOS) y el archivo `google-services.json` (Android, ignorado por git).

## Flujo de trabajo

Ramas cortas desde `main` y Pull Request. La aprobación del otro socio es opcional. Ver [docs/flujo-git.md](docs/flujo-git.md).
