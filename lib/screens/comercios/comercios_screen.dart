// screens/comercios_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dogland/widgets/comercio_card.dart';
import 'package:dogland/services/location_based_service.dart';

class ComerciosScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onComercioSelected;

  const ComerciosScreen({Key? key, required this.onComercioSelected}) : super(key: key);

  @override
  _ComerciosScreenState createState() => _ComerciosScreenState();
}

class _ComerciosScreenState extends State<ComerciosScreen> {
  final LocationBasedService _locationBasedService = LocationBasedService();

  List<Map<String, dynamic>> _nearbyComercios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNearbyComercios();
  }

  void _loadNearbyComercios() async {
    setState(() => _isLoading = true);
    try {
      List<Map<String, dynamic>> comercios = await _locationBasedService.getNearbyItems('Comercio');
      setState(() {
        _nearbyComercios = comercios;
        _isLoading = false;
      });
    } catch (e) {
      print("Error al cargar comercios cercanos: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Botón de filtro por ubicación
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              icon: Icon(Icons.location_on),
              label: Text('Filtrar por Ubicación'),
              onPressed: _loadNearbyComercios,
            ),
          ),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
                  child: ListView.builder(
                    itemCount: _nearbyComercios.length,
                    itemBuilder: (context, index) {
                      var comercio = _nearbyComercios[index];
                      var distance = comercio['distance'];
                      return ComercioCard(
                        titulo: comercio['username'] ?? 'Sin Nombre',
                        descripcion: comercio['description'] ?? 'Sin Descripción',
                        imagen: comercio['businessImages']?.isNotEmpty == true ? comercio['businessImages'][0] : null,
                        distance: distance != null ? "${(distance / 1000).toStringAsFixed(1)} km de distancia" : "Distancia no disponible",
                        onTap: () => widget.onComercioSelected(comercio),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
