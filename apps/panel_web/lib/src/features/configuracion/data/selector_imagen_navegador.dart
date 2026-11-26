import 'package:file_picker/file_picker.dart';

import '../domain/configuracion_repositorio.dart';

/// [SelectorImagen] con el diálogo de archivos del navegador.
class SelectorImagenNavegador implements SelectorImagen {
  const SelectorImagenNavegador();

  @override
  Future<ImagenElegida?> elegir() async {
    final archivo = await FilePicker.pickFile(
      dialogTitle: 'Elige el logo',
      type: FileType.custom,
      allowedExtensions: const ['png', 'jpg', 'jpeg', 'webp'],
    );
    if (archivo == null) return null;
    return ImagenElegida(
      nombre: archivo.name,
      bytes: await archivo.readAsBytes(),
    );
  }
}
