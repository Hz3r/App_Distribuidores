import 'package:app_movil/src/features/sesion/domain/acceso.dart';
import 'package:app_movil/src/features/sesion/presentation/control_acceso.dart';

/// Controlador de acceso falso cuyo estado fija la prueba con [fijar]. No
/// toca `Supabase.instance`.
class ControlAccesoFijo extends ControlAcceso {
  ControlAccesoFijo(this.inicial);

  final Acceso inicial;

  @override
  Acceso build() => inicial;

  /// Cambia el acceso, como lo haría una carga o un cambio de sesión.
  void fijar(Acceso acceso) => state = acceso;
}
