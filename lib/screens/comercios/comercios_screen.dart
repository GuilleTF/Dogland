import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dogland/widgets/comercio_card.dart';
import 'package:dogland/services/location_based_service.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../../data/tags.dart';

class ComerciosScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onComercioSelected;

  const ComerciosScreen({Key? key, required this.onComercioSelected}) : super(key: key);

  @override
  _ComerciosScreenState createState() => _ComerciosScreenState();
}

class _ComerciosScreenState extends State<ComerciosScreen> {
  final LocationBasedService _locationBasedService = LocationBasedService();

  List<Map<String, dynamic>> _nearbyComercios = [];
  List<String> _selectedTags = [];
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
        _nearbyComercios = _applyTagFilter(comercios);
        _isLoading = false;
      });
    } catch (e) {
      print("Error al cargar comercios cercanos: $e");
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _applyTagFilter(List<Map<String, dynamic>> comercios) {
    if (_selectedTags.isEmpty) return comercios;
    return comercios.where((comercio) {
      List<dynamic>? tags = comercio['tags'] as List<dynamic>?;
      return tags != null && tags.any((tag) => _selectedTags.contains(tag));
    }).toList();
  }

  void _onTagFilterChanged(List<String> selectedTags) {
    setState(() {
      _selectedTags = selectedTags;
    });
    _loadNearbyComercios();
  }

  void _clearFilters() {
    setState(() {
      _selectedTags = [];
    });
    _loadNearbyComercios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MultiSelectDialogField(
              items: etiquetasDeComercio.map((tag) => MultiSelectItem(tag, tag)).toList(),
              title: Text("Selecciona etiquetas"),
              buttonText: Text("Filtrar por Etiquetas"),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
              onConfirm: _onTagFilterChanged,
              initialValue: _selectedTags,
            ),
          ),
          if (_selectedTags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ElevatedButton.icon(
                icon: Icon(Icons.clear),
                label: Text('Quitar Filtros'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: _clearFilters,
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
