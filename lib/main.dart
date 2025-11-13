import 'package:appvline/model/util/location_notification_services.dart';
import 'package:appvline/view/cajaList.dart';
import 'package:appvline/view/cobrosList.dart';
import 'package:appvline/view/cotizacionList.dart';
import 'package:appvline/view/loginpage.dart';
import 'package:appvline/view/map_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:appvline/view/productList.dart';
import 'package:appvline/view/recordingTask.dart';
import 'package:appvline/view/tracking_screen.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> _solicitarPermisos() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/Lima')); // Ajusta a tu zona

  await _solicitarPermisos();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  String? lastRoute;
   MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Vyrutech',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade800),
        //colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF081323)),
        useMaterial3: true,
      ),
      initialRoute:  lastRoute ?? '/',
      routes: {
        '/': (context) => LoginPage(),
        "/tracking": (context) =>  TrackingScreen(),
        "/mapa-cliente": (context) =>  MapaClienteScreen(),
        "/productList": (context) =>  ProductListScreen(products_cart: []),
        "/caja": (context) =>  CashboxScreen(),
        "/cotizacion": (context) =>  CotizacionListScreen(),
        "/cobros": (context) =>  CobrosListScreen(),
        "/recordatorio": (context) =>  RecordatoriosScreen()},

    );
  }
}


class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inicio')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/tracking'),
              child: Text('Modo Conductor'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/mapa-cliente'),
              child: Text('Modo Cliente'),
            ),
          ],
        ),
      ),
    );
  }
}

