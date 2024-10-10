import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPicker extends StatefulWidget {
  final LatLng initialLocation;

  // Constructor que requiere una ubicación inicial
  LocationPicker({required this.initialLocation});

  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  GoogleMapController? mapController;
  late LatLng _selectedLocation;

  @override
  void initState() {
    super.initState();
    // Usar `initialLocation` para definir la ubicación inicial del mapa
    _selectedLocation = widget.initialLocation;
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecciona Ubicación'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _selectedLocation, // Usar la ubicación inicial
          zoom: 10,
        ),
        markers: {
          Marker(
            markerId: MarkerId('selected-location'),
            position: _selectedLocation,
          ),
        },
        onTap: _onTap, // Permite seleccionar una nueva ubicación al tocar el mapa
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context, _selectedLocation); // Retorna la ubicación seleccionada al cerrar
        },
        child: Icon(Icons.check),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
