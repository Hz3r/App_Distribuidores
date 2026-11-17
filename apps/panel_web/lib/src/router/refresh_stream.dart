import 'dart:async';

import 'package:flutter/foundation.dart';

/// Notifica a go_router cada vez que cambia la sesión de Supabase.
class RefrescoDesdeStream extends ChangeNotifier {
  RefrescoDesdeStream(Stream<dynamic> stream) {
    _suscripcion = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _suscripcion;

  @override
  void dispose() {
    _suscripcion.cancel();
    super.dispose();
  }
}
