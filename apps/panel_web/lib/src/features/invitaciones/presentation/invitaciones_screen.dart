import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../config/tema_panel.dart';
import '../../../shared/formato.dart';
import '../../../shared/widgets/estados.dart';
import '../../../shared/widgets/etiqueta.dart';
import '../../../shared/widgets/pagina_panel.dart';
import '../../../shared/widgets/tabla_panel.dart';
import '../../clientes/domain/acceso_cliente.dart';
import '../../clientes/presentation/clientes_providers.dart';
import '../../clientes/presentation/invitar_dialogo.dart';

/// Códigos con los que los clientes entran a la app: cuáles siguen
/// vigentes, cuáles ya se usaron y cuáles vencieron.
class InvitacionesScreen extends ConsumerStatefulWidget {
  const InvitacionesScreen({super.key});

  @override
  ConsumerState<InvitacionesScreen> createState() => _InvitacionesScreenState();
}

class _InvitacionesScreenState extends ConsumerState<InvitacionesScreen> {
  /// Null = todas.
  EstadoInvitacion? _estado;

  Future<void> _nueva(List<ClienteNegocio> clientes) {
    return InvitarDialogo.mostrar(
      context,
      clientes: [
        for (final c in clientes)
          if (c.activo) c,
      ],
    );
  }

  Future<void> _copiar(Invitacion invitacion) async {
    final avisos = ScaffoldMessenger.maybeOf(context);
    await Clipboard.setData(ClipboardData(text: invitacion.codigo));
    avisos?.showSnackBar(const SnackBar(content: Text('Código copiado.')));
  }

  Future<void> _revocar(Invitacion invitacion, String negocio) async {
    final avisos = ScaffoldMessenger.maybeOf(context);
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('Anular código'),
        content: Text(
          'El código ${invitacion.codigo} de $negocio dejará de servir. Esto '
          'no se puede deshacer; si hace falta, generas otro.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(false),
            child: const Text('Conservar código'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: ColoresPanel.peligro500,
            ),
            onPressed: () => Navigator.of(contexto).pop(true),
            child: const Text('Anular código'),
          ),
        ],
      ),
    );
    if (confirmado != true) return;
    try {
      await ref.read(accionesClientesProvider).revocar(invitacion);
      avisos?.showSnackBar(const SnackBar(content: Text('Código anulado.')));
    } catch (e) {
      avisos?.showSnackBar(SnackBar(content: Text(mensajeDeClientes(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final consulta = ref.watch(invitacionesProvider);
    final clientes =
        ref.watch(clientesProvider).value ?? const <ClienteNegocio>[];
    final ahora = ref.watch(relojProvider)();
    final invitaciones = consulta.value;
    final hayClientesActivos = clientes.any((c) => c.activo);

    final nueva = FilledButton.icon(
      onPressed: hayClientesActivos ? () => _nueva(clientes) : null,
      icon: const Icon(Icons.key_outlined),
      label: const Text('Nueva invitación'),
    );

    final Widget cuerpo;
    if (invitaciones == null) {
      cuerpo = consulta.hasError
          ? EstadoAviso.error(
              alReintentar: () => ref.invalidate(invitacionesProvider),
            )
          : const EstadoCarga();
    } else if (invitaciones.isEmpty) {
      cuerpo = EstadoAviso(
        icono: Icons.key_outlined,
        titulo: 'Aún no generaste códigos',
        mensaje: hayClientesActivos
            ? 'Genera un código para un cliente y envíaselo: con eso entra a '
                  'la app y ve solo tu catálogo.'
            : 'Primero registra a tus clientes en la sección Clientes.',
        accion: hayClientesActivos ? nueva : null,
      );
    } else {
      cuerpo = _lista(invitaciones, clientes, ahora);
    }

    return PaginaPanel(
      titulo: 'Invitaciones',
      descripcion:
          'Cada código sirve una sola vez. Tu cliente lo escribe en la app y '
          'queda vinculado a tu negocio.',
      acciones: [if (invitaciones != null && invitaciones.isNotEmpty) nueva],
      child: cuerpo,
    );
  }

  Widget _lista(
    List<Invitacion> invitaciones,
    List<ClienteNegocio> clientes,
    DateTime ahora,
  ) {
    final negocios = {for (final c in clientes) c.id: c.nombreNegocio};
    final estados = {for (final i in invitaciones) i.id: estadoDe(i, ahora)};
    int contar(EstadoInvitacion estado) =>
        estados.values.where((e) => e == estado).length;

    final estado = _estado;
    final filtradas = [
      for (final i in invitaciones)
        if (estado == null || estados[i.id] == estado) i,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: Text('Todas (${invitaciones.length})'),
              selected: estado == null,
              onSelected: (_) => setState(() => _estado = null),
            ),
            for (final opcion in EstadoInvitacion.values)
              ChoiceChip(
                label: Text('${_plural(opcion)} (${contar(opcion)})'),
                selected: estado == opcion,
                onSelected: (_) => setState(() => _estado = opcion),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: filtradas.isEmpty
              ? EstadoAviso(
                  icono: Icons.filter_alt_off_outlined,
                  titulo: 'No hay códigos en este estado',
                  mensaje: 'Mira todos para ver el resto.',
                  accion: OutlinedButton(
                    onPressed: () => setState(() => _estado = null),
                    child: const Text('Ver todas'),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, limites) {
                    final amplia = limites.maxWidth >= 760;
                    return TablaPanel(
                      columnas: [
                        const ColumnaTabla('Código', ancho: 120),
                        const ColumnaTabla('Cliente', flex: 3),
                        if (amplia) const ColumnaTabla('Creado', ancho: 100),
                        const ColumnaTabla('Vence', ancho: 100),
                        const ColumnaTabla('Estado', ancho: 96),
                        const ColumnaTabla('', ancho: 150, aLaDerecha: true),
                      ],
                      cantidadFilas: filtradas.length,
                      celdasDeFila: (context, indice) {
                        final invitacion = filtradas[indice];
                        final actual =
                            estados[invitacion.id] ?? EstadoInvitacion.vencida;
                        final negocio =
                            negocios[invitacion.clienteNegocioId] ?? 'Cliente';
                        final vigente = actual == EstadoInvitacion.vigente;
                        return [
                          Text(
                            invitacion.codigo,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                              color: vigente
                                  ? ColoresPanel.primario500
                                  : ColoresPanel.neutro500,
                            ),
                          ),
                          Text(
                            negocio,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (amplia) Text(fechaCorta(invitacion.creadoEn)),
                          Text(fechaCorta(invitacion.venceEn)),
                          Etiqueta(_singular(actual), tono: _tono(actual)),
                          if (vigente)
                            // Si no cabe (letra grande), se encoge en vez de
                            // salirse de la columna.
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip:
                                        'Copiar código ${invitacion.codigo}',
                                    onPressed: () => _copiar(invitacion),
                                    icon: const Icon(
                                      Icons.copy_rounded,
                                      size: 18,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        _revocar(invitacion, negocio),
                                    child: const Text('Anular'),
                                  ),
                                ],
                              ),
                            )
                          else
                            const SizedBox.shrink(),
                        ];
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

String _singular(EstadoInvitacion estado) => switch (estado) {
  EstadoInvitacion.vigente => 'Vigente',
  EstadoInvitacion.usada => 'Usada',
  EstadoInvitacion.vencida => 'Vencida',
  EstadoInvitacion.revocada => 'Anulada',
};

String _plural(EstadoInvitacion estado) => switch (estado) {
  EstadoInvitacion.vigente => 'Vigentes',
  EstadoInvitacion.usada => 'Usadas',
  EstadoInvitacion.vencida => 'Vencidas',
  EstadoInvitacion.revocada => 'Anuladas',
};

TonoEtiqueta _tono(EstadoInvitacion estado) => switch (estado) {
  EstadoInvitacion.vigente => TonoEtiqueta.info,
  EstadoInvitacion.usada => TonoEtiqueta.exito,
  EstadoInvitacion.vencida => TonoEtiqueta.neutro,
  EstadoInvitacion.revocada => TonoEtiqueta.peligro,
};
