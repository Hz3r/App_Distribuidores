import 'package:material_ui/material_ui.dart';

import '../../../config/tema_panel.dart';
import '../../../shared/widgets/pagina_panel.dart';
import 'pestana_marca.dart';
import 'pestana_negocio.dart';
import 'pestana_plan.dart';

/// Configuración del distribuidor (solo admin): datos del negocio, marca
/// que ven los clientes y plan.
class ConfiguracionScreen extends StatelessWidget {
  const ConfiguracionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: PaginaPanel(
        titulo: 'Configuración',
        descripcion:
            'Datos de tu negocio, la marca que ven tus clientes y tu plan.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: ColoresPanel.neutro200),
                ),
              ),
              child: const TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                dividerHeight: 0,
                labelColor: ColoresPanel.primario700,
                unselectedLabelColor: ColoresPanel.neutro500,
                indicatorColor: ColoresPanel.primario500,
                labelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                tabs: [
                  Tab(text: 'Negocio'),
                  Tab(text: 'Marca'),
                  Tab(text: 'Plan'),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [PestanaNegocio(), PestanaMarca(), PestanaPlan()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
