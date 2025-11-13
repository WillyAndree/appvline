import 'package:appvline/constants.dart';
import 'package:appvline/view/loginpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PrincipalPage extends StatefulWidget {
  const PrincipalPage({super.key});

  @override
  State<PrincipalPage> createState() => _PrincipalPageState();
}

class _PrincipalPageState extends State<PrincipalPage> {



  String idusuarioActual ="";
  String idempresaActual = "";
  String nombresActual = "";
  String tipoUsuarioActual = "";
  String dniUsuarioActual = "";



  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar tu sesión?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FilledButton(
              child: const Text('Sí, Cerrar Sesión'),
              onPressed: () {
                // Lógica de cierre de sesión aquí
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sesión cerrada.')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: /*Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.business_center_rounded, color: Theme.of(context).colorScheme.primary, size: 28), // Logo placeholder
            const SizedBox(width: 8),
            Text(
              'Vyrutech Pro', // Nombre de la App
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),*/
        Container(
          width: MediaQuery.sizeOf(context).width*0.3,
          height: MediaQuery.sizeOf(context).height*0.15,
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                  "assets/images/vyru.png",
                ),
                fit: BoxFit.fill),
          ),),

        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {
            },
          ),

          IconButton(
            icon: const Icon(Icons.exit_to_app_rounded),
            onPressed: () => _showLogoutConfirmationDialog(context),
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Foto de usuario (Placeholder)
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,

                    child: ClipOval(
                      child: Container(
                        width: 60.0,
                        height: 60.0,

                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage("https://$subdominio.vlinesys.com/app/imagenes/$foto_const"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.sizeOf(context).width*0.7,
                        child: Text(
                          '¡Hola, $nombreUsuario!',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      Text(
                        'Resumen de Indicadores Clave (KPI)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis ,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const SalesMetricsSection(),
              const SizedBox(height: 24),

              const SalesChartCard(),
              const SizedBox(height: 24),

              Text(
                'Accesos Rápidos',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              const MenuGridSection(),
            ],
          ),
        ),
      ),
    );
  }
}


class SalesMetricsSection extends StatelessWidget {
  const SalesMetricsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 800;

    final crossAxisCount = isLargeScreen ? 3 : 1;

    if (!isLargeScreen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: salesMetrics.map((data) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: MetricCard(data: data),
        )).toList(),
      );
    }

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16.0,
      mainAxisSpacing: 16.0,
      childAspectRatio: 2.8,
      children: salesMetrics.map((data) => MetricCard(data: data)).toList(),
    );
  }
}

class MetricCard extends StatelessWidget {
  final SalesData data;
  const MetricCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: data.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(data.icon, color: data.color, size: 30),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  data.metric,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class SalesChartCard extends StatelessWidget {
  const SalesChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recordatorios',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: MediaQuery.sizeOf(context).height * 0.1,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant)
              ),
              child: const Center(
                child: Text(
                  'Aquí irían los datos del recordatorio! =)',
                  style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Ver Recordatorio completo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class MenuGridSection extends StatelessWidget {
  const MenuGridSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount;
    if (screenWidth < 600) {
      crossAxisCount = 2;
    } else if (screenWidth < 1000) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 4;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 1.0,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return MenuGridItem(item: item);
      },
    );
  }
}
class MenuGridItem extends StatelessWidget {
  final DashboardItem item;
  const MenuGridItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print('Navegando a: ${item.descripcion}');
        Navigator.pushNamed(context, item.descripcion);
      },
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: item.color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                item.icon,
                size: 36,
                color: item.color.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                item.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class DashboardItem {
  final String title;
  final IconData icon;
  final Color color;
  final String descripcion;

  DashboardItem(this.title, this.icon, this.color, this.descripcion);
}

class SalesData {
  final String metric;
  final String value;
  final IconData icon;
  final Color color;


  SalesData(this.metric, this.value, this.icon, this.color);
}

final List<DashboardItem> menuItems = [
  DashboardItem('Ventas', Icons.trending_up_rounded, Colors.teal, '/productList'),
  DashboardItem('Caja', Icons.shopping_cart_rounded, Colors.blueGrey,'/caja'),
  DashboardItem('Cuentas por Cobrar', Icons.account_balance_wallet_rounded, Colors.deepOrange,'/cobros'),
  DashboardItem('Cotización', Icons.people_alt_rounded, Colors.indigo,'/cotizacion'),
  DashboardItem('Asistencia de Personal', Icons.group_work_rounded, Colors.purple,'/asistencia'),
];

List menu  = [{
  "ICONO":"truck.png",
  "DESCRIPCION":"GENERAR VIAJE",
  "VIEW":"tracking"
},
  {
    "ICONO":"mapa.png",
    "DESCRIPCION":"SEGUIMIENTO TRANSPORTE",
    "VIEW":"mapa-cliente"
  },
];

final List<SalesData> salesMetrics = [
  SalesData('Ventas Hoy', '\$12,450', Icons.attach_money_rounded, Colors.teal.shade400),
  SalesData('Objetivo Mensual', '85%', Icons.bar_chart_rounded, Colors.blue.shade400),
  SalesData('Clientes Nuevos', '23', Icons.person_add_alt_1_rounded, Colors.orange.shade400),
];
