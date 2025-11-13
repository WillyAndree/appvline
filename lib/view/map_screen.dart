import 'package:appvline/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapaClienteScreen extends StatefulWidget {
  const MapaClienteScreen({super.key});

  @override
  State<MapaClienteScreen> createState() => _MapaClienteScreenState();
}

class _MapaClienteScreenState extends State<MapaClienteScreen> {
  GoogleMapController? _mapController;
  LatLng _posicionInicial = const LatLng(-12.0464, -77.0428); // Ej: Lima
  Marker? _vehiculoMarker;

  @override
  void initState() {
    super.initState();
    _escucharUbicacion();
  }

  void _escucharUbicacion() {
    final ref = FirebaseDatabase.instance.ref('ubicaciones/vehiculo123');

    ref.onValue.listen((event) {
      final value = event.snapshot.value;
      if (value is Map || value is Map<Object?, Object?>) {
        final data = Map<String, dynamic>.from(value as Map);

        final lat = double.tryParse(data['lat'].toString());
        final lng = double.tryParse(data['lng'].toString());

        if (lat != null && lng != null) {
          final nuevaPosicion = LatLng(lat, lng);

          setState(() {
            _vehiculoMarker = Marker(
              markerId: const MarkerId('vehiculo'),
              position: nuevaPosicion,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              infoWindow: const InfoWindow(title: 'Vehículo Delivery'),
            );

            _mapController?.animateCamera(CameraUpdate.newLatLng(nuevaPosicion));
          });
        }
      }
    }, onError: (error) {
      debugPrint('Error al escuchar ubicación: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: azulvline,
          foregroundColor: Colors.white,
          title: const Text('Ubicación en tiempo real')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: _posicionInicial, zoom: 15),
        onMapCreated: (controller) => _mapController = controller,
        markers: _vehiculoMarker != null ? {_vehiculoMarker!} : {},
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
