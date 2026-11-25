import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../config/tema_panel.dart';
import '../../../shared/widgets/estados.dart';
import '../../../shared/widgets/etiqueta.dart';
import '../../../shared/widgets/pagina_panel.dart';
import '../../../shared/widgets/tabla_panel.dart';
import '../domain/acceso_cliente.dart';
import '../domain/clientes_repositorio.dart';
import 'cliente_formulario.dart';
import 'clientes_providers.dart';
import 'invitar_dialogo.dart';

/// Clientes del distribuidor: los negocios que le compran y si ya pueden
/// pedir desde la app.
class ClientesScreen extends ConsumerStatefulWidget {
  const ClientesScreen({super.key});

  @override
  ConsumerState<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends ConsumerState<ClientesScreen> {
  final _busqueda = TextEditingController();

  /// Null = todos.
  AccesoCliente? _acceso;

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  Future<void> _abrirFormulario([ClienteNegocio? cliente]) async {
    final guardado = await ClienteFormulario.mostrar(context, cliente);
    if (guardado == true && mounted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text(
            cliente == null ? 'Cliente creado.' : 'Cambios guardados.',
          ),
        ),
      );
    }
  }

  Future<void> _invitar(ClienteNegocio cliente) {
    return InvitarDialogo.mostrar(
      context,
      clientes: [cliente],
      cliente: cliente,
    );
  }

  @override
  Widget build(BuildContext context) {
    final consulta = ref.watch(clientesProvider);
    final personas =
        ref.watch(personasClienteProvider).value ?? const <PersonaCliente>[];
    final invitaciones =
        ref.watch(invitacionesProvider).value ?? const <Invitacion>[];
    final ahora = ref.watch(relojProvider)();
    final clientes = consulta.value;

    final Widget cuerpo;
    if (clientes == null) {
      cuerpo = consulta.hasError
          ? EstadoAviso.error(
              alReintentar: () => ref.invalidate(clientesProvider),
            )
          : const EstadoCarga();
    } else if (clientes.isEmpty) {
      cuerpo = EstadoAviso(
        icono: Icons.storefront_outlined,
        titulo: 'Aún no tienes clientes',
        mensaje:
            'Registra a los negocios que te compran y dales un código para '
            'que pidan desde la app.',
        accion: FilledButton.icon(
          onPressed: _abrirFormulario,
          icon: const Icon(Icons.add),
          label: const Text('Nuevo cliente'),
        ),
      );
    } else {
      cuerpo = _lista(clientes, personas, invitaciones, ahora);
    }

    return PaginaPanel(
      titulo: 'Clientes',
      descripcion: clientes == null || clientes.isEmpty
          ? 'Los negocios que te compran.'
          : clientes.length == 1
          ? '1 negocio registrado.'
          : '${clientes.length} negocios registrados.',
      acciones: [
        if (clientes != null && clientes.isNotEmpty)
          FilledButton.icon(
            onPressed: _abrirFormulario,
            icon: const Icon(Icons.add),
            label: const Text('Nuevo cliente'),
          ),
      ],
      child: cuerpo,
    );
  }

  Widget _lista(
    List<ClienteNegocio> clientes,
    List<PersonaCliente> personas,
    List<Invitacion> invitaciones,
    DateTime ahora,
  ) {
    final accesos = {
      for (final c in clientes)
        c.id: accesoDe(
          c,
          personas: personas,
          invitaciones: invitaciones,
          ahora: ahora,
        ),
    };
    int contar(AccesoCliente acceso) =>
        accesos.values.where((a) => a == acceso).length;

    final acceso = _acceso;
    final filtrados = [
      for (final c in filtrarClientes(clientes, _busqueda.text))
        if (acceso == null || accesos[c.id] == acceso) c,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 280,
              child: TextField(
                controller: _busqueda,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Buscar por nombre, RUC o dirección',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
              ),
            ),
            ChoiceChip(
              label: Text('Todos (${clientes.length})'),
              selected: acceso == null,
              onSelected: (_) => setState(() => _acceso = null),
            ),
            for (final opcion in AccesoCliente.values)
              ChoiceChip(
                label: Text('${_plural(opcion)} (${contar(opcion)})'),
                selected: acceso == opcion,
                onSelected: (_) => setState(() => _acceso = opcion),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: filtrados.isEmpty
              ? EstadoAviso(
                  icono: Icons.search_off_rounded,
                  titulo: 'Ningún cliente coincide',
                  mensaje: 'Prueba con otra palabra o quita los filtros.',
                  accion: OutlinedButton(
                    onPressed: () => setState(() {
                      _busqueda.clear();
                      _acceso = null;
                    }),
                    child: const Text('Quitar filtros'),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, limites) => _tabla(
                    filtrados,
                    accesos,
                    personas,
                    amplia: limites.maxWidth >= 860,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _tabla(
    List<ClienteNegocio> clientes,
    Map<String, AccesoCliente> accesos,
    List<PersonaCliente> personas, {
    required bool amplia,
  }) {
    return TablaPanel(
      columnas: [
        const ColumnaTabla('Negocio', flex: 3),
        if (amplia) const ColumnaTabla('Contacto', flex: 3),
        if (amplia) const ColumnaTabla('Pago', ancho: 150),
        const ColumnaTabla('En la app', ancho: 110),
        const ColumnaTabla('', ancho: 160, aLaDerecha: true),
      ],
      cantidadFilas: clientes.length,
      celdasDeFila: (context, indice) {
        final cliente = clientes[indice];
        final acceso = accesos[cliente.id] ?? AccesoCliente.sinAcceso;
        final encargado = personas
            .where((p) => p.clienteNegocioId == cliente.id)
            .map((p) => p.nombre)
            .nonNulls
            .firstOrNull;
        return [
          _DosLineas(
            cliente.nombreNegocio,
            cliente.documento == null
                ? null
                : '${cliente.documento!.length == 8 ? 'DNI' : 'RUC'} '
                      '${cliente.documento}',
            negrita: true,
          ),
          if (amplia)
            _DosLineas(
              [
                ?encargado,
                ?cliente.telefono,
              ].join(' · ').ifEmpty('Sin contacto'),
              cliente.direccion,
            ),
          if (amplia) _CeldaPago(cliente),
          Etiqueta(_singular(acceso), tono: _tono(acceso)),
          // Si no cabe (letra grande), se encoge en vez de salirse.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (acceso == AccesoCliente.sinAcceso ||
                    acceso == AccesoCliente.invitado)
                  TextButton(
                    onPressed: () => _invitar(cliente),
                    child: Text(
                      acceso == AccesoCliente.invitado
                          ? 'Otro código'
                          : 'Invitar',
                    ),
                  ),
                IconButton(
                  tooltip: 'Editar ${cliente.nombreNegocio}',
                  onPressed: () => _abrirFormulario(cliente),
                  icon: const Icon(Icons.edit_outlined, size: 20),
                ),
              ],
            ),
          ),
        ];
      },
    );
  }
}

String _singular(AccesoCliente acceso) => switch (acceso) {
  AccesoCliente.conAcceso => 'Ya entra',
  AccesoCliente.invitado => 'Invitado',
  AccesoCliente.sinAcceso => 'Sin invitar',
  AccesoCliente.inactivo => 'Inactivo',
};

String _plural(AccesoCliente acceso) => switch (acceso) {
  AccesoCliente.conAcceso => 'Ya entran',
  AccesoCliente.invitado => 'Invitados',
  AccesoCliente.sinAcceso => 'Sin invitar',
  AccesoCliente.inactivo => 'Inactivos',
};

TonoEtiqueta _tono(AccesoCliente acceso) => switch (acceso) {
  AccesoCliente.conAcceso => TonoEtiqueta.exito,
  AccesoCliente.invitado => TonoEtiqueta.aviso,
  AccesoCliente.sinAcceso => TonoEtiqueta.neutro,
  AccesoCliente.inactivo => TonoEtiqueta.peligro,
};

extension on String {
  String ifEmpty(String alternativa) => isEmpty ? alternativa : this;
}

class _DosLineas extends StatelessWidget {
  const _DosLineas(this.principal, this.secundaria, {this.negrita = false});

  final String principal;
  final String? secundaria;
  final bool negrita;

  @override
  Widget build(BuildContext context) {
    final secundaria = this.secundaria;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          principal,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: negrita
              ? const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: ColoresPanel.neutro900,
                )
              : null,
        ),
        if (secundaria != null && secundaria.isNotEmpty)
          Text(
            secundaria,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: ColoresPanel.neutro500),
          ),
      ],
    );
  }
}

class _CeldaPago extends StatelessWidget {
  const _CeldaPago(this.cliente);

  final ClienteNegocio cliente;

  @override
  Widget build(BuildContext context) {
    final limite = cliente.limiteCreditoCentimos;
    final plazo = cliente.plazoCreditoDias;
    if (!cliente.creditoHabilitado || limite == null || plazo == null) {
      return const Text('Contado');
    }
    return _DosLineas(
      'Crédito ${limite.formatoSoles}',
      plazo == 1 ? 'Paga en 1 día' : 'Paga en $plazo días',
    );
  }
}
