import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

class TrackingScreen extends StatefulWidget {
  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  late DatabaseReference _ubicacionRef;
  Stream<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _ubicacionRef = FirebaseDatabase.instance.ref().child('ubicaciones/vehiculo123');
    _iniciarSeguimiento();
  }

  Future<bool> _iniciarSeguimiento() async {
    bool servicioActivo = await Geolocator.isLocationServiceEnabled();
    if (!servicioActivo) {
      return Geolocator.openLocationSettings();
    }

    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied || permiso == LocationPermission.deniedForever) {
      permiso = await Geolocator.requestPermission();
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );

    _positionStream!.listen((Position position) {
      _ubicacionRef.set({
        'lat': position.latitude,
        'lng': position.longitude,
        'timestamp': ServerValue.timestamp,
      });
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Seguimiento Vehículo')),
      body: Center(child: Text('Enviando ubicación en tiempo real...')),
    );
  }
}
