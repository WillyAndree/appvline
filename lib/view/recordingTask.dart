import 'package:appvline/model/util/location_notification_services.dart';
import 'package:flutter/material.dart';
//import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:appvline/main.dart';

class RecordatoriosScreen extends StatefulWidget {
  @override
  _RecordatoriosScreenState createState() => _RecordatoriosScreenState();
}

class _RecordatoriosScreenState extends State<RecordatoriosScreen> {
  final _tareaController = TextEditingController();
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;
 // final _dbRef = FirebaseDatabase.instance.ref('recordatorios');

  @override
  void dispose() {
    _tareaController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _pedirPermisoNotificaciones();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Lima'));

    // Inicializar notificaciones
    LocalNotificationService().initNotifications();

    // Notificación de prueba para 2 minutos en el futuro
    final ahora = DateTime.now().add(Duration(minutes: 2));
    print('🕒 Probando notificación para: $ahora');
    _programarNotificacion("Notificación de prueba", ahora);
  }

  Future<void> _programarNotificacion(String tarea, DateTime fechaHora) async {
    try {
      final permiso = await _verificarPermisoExactAlarm();
      if (!permiso) {
        print("⛔ El usuario no permitió alarmas exactas");
        return;
      }

      // Si la fecha está en el pasado, la movemos a 10 seg en el futuro
      DateTime fechaNotificacion = fechaHora;
      if (fechaNotificacion.isBefore(DateTime.now())) {
        print("⚠ La fecha estaba en el pasado, ajustando para 10 seg en el futuro...");
        fechaNotificacion = DateTime.now().add(Duration(seconds: 10));
      }

      final tzDateTime = tz.TZDateTime.from(fechaNotificacion, tz.local);

      print('📅 Programando notificación:');
      print('   Tarea: $tarea');
      print('   Hora tarea: $fechaHora');
      print('   Hora notificación: $tzDateTime');
      print('Zona horaria actual: ${tz.local.name}');
      print('Hora actual del sistema: ${DateTime.now()}');

      await LocalNotificationService().scheduleNotification(
        id: fechaNotificacion.millisecondsSinceEpoch ~/ 1000,
        title: 'Recordatorio de tarea',
        body: 'En 30 minutos: $tarea',
        scheduledDate: tzDateTime, // Ahora va en formato TZ
      );

    } catch (e) {
      print("❌ Error al programar notificación: $e");
    }
  }



  Future<void> _seleccionarFecha() async {
    DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );

    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
      });
    }
  }

  Future<void> _seleccionarHora() async {
    TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (hora != null) {
      setState(() {
        _horaSeleccionada = hora;
      });
    }
  }

  Future<bool> _verificarPermisoExactAlarm() async {
    if (Platform.isAndroid) {
      if (await Permission.scheduleExactAlarm.isDenied) {
        return await Permission.scheduleExactAlarm.request().isGranted;
      }
    }
    return true;
  }

  Future<void> _pedirPermisoNotificaciones() async {
    if (Platform.isAndroid) {
      var status = await Permission.notification.status;
      if (!status.isGranted) {
        await Permission.notification.request();
      }
    }
  }


  void _guardarRecordatorio() {
    if (_fechaSeleccionada == null || _horaSeleccionada == null || _tareaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    final fechaHora = DateTime(
      _fechaSeleccionada!.year,
      _fechaSeleccionada!.month,
      _fechaSeleccionada!.day,
      _horaSeleccionada!.hour,
      _horaSeleccionada!.minute,
    );

    /*_dbRef.push().set({
      'tarea': _tareaController.text,
      'fechaHora': fechaHora.toIso8601String(),
    });*/
    _programarNotificacion(_tareaController.text, fechaHora);

    _tareaController.clear();
    setState(() {
      _fechaSeleccionada = null;
      _horaSeleccionada = null;
    });
  }

  String _formatearFechaHora(String fechaIso) {
    final fecha = DateTime.parse(fechaIso);
    return DateFormat('dd/MM/yyyy HH:mm').format(fecha);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recordatorios')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _tareaController,
                  decoration: InputDecoration(labelText: 'Tarea'),
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _seleccionarFecha,
                        child: Text(_fechaSeleccionada == null
                            ? 'Seleccionar Fecha'
                            : DateFormat('dd/MM/yyyy').format(_fechaSeleccionada!)),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _seleccionarHora,
                        child: Text(_horaSeleccionada == null
                            ? 'Seleccionar Hora'
                            : _horaSeleccionada!.format(context)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _guardarRecordatorio,
                  child: Text('Guardar Recordatorio'),
                ),
              ],
            ),
          ),
          Divider(),
          /*Expanded(
            child: StreamBuilder(
              stream: _dbRef.onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                  return Center(child: Text("No hay recordatorios"));
                }

                final data = Map<String, dynamic>.from(
                  (snapshot.data! as DatabaseEvent).snapshot.value as Map,
                );

                final lista = data.entries.map((e) {
                  final value = Map<String, dynamic>.from(e.value as Map);
                  return {
                    'id': e.key,
                    'tarea': value['tarea'],
                    'fechaHora': value['fechaHora'],
                  };
                }).toList();

                lista.sort((a, b) => a['fechaHora'].compareTo(b['fechaHora']));

                return ListView.builder(
                  itemCount: lista.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(lista[index]['tarea']),
                      subtitle: Text(_formatearFechaHora(lista[index]['fechaHora'])),
                    );
                  },
                );
              },
            ),
          ),*/
        ],
      ),
    );
  }
}
