// screens/comercios_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dogland/widgets/comercio_card.dart';
import 'package:dogland/widgets/custom_search_bar.dart';
import 'package:dogland/services/location_based_service.dart';

class ComerciosScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onComercioSelected;

  const ComerciosScreen({Key? key, required this.onComercioSelected}) : super(key: key);

  @override
  _ComerciosScreenState createState() => _ComerciosScreenState();
}

class _ComerciosScreenState extends State<ComerciosScreen> {
  final TextEditingController _searchController = TextEditingController();
  final LocationBasedService _locationBasedService = LocationBasedService();

  List<Map<String, dynamic>> _nearbyComercios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNearbyComercios();
    _searchController.addListener(_filterComercios);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterComercios);
    _searchController.dispose();
    super.dispose();
  }

  void _loadNearbyComercios() async {
    try {
      List<Map<String, dynamic>> comercios = await _locationBasedService.getNearbyItems('Comercio');
      setState(() {
        _nearbyComercios = comercios;
        _isLoading = false;
      });
    } catch (e) {
      print("Error al cargar comercios cercanos: $e");
    }
  }

  void _filterComercios() {
    String query = _searchController.text.toLowerCase();

    setState(() {
      _nearbyComercios = _nearbyComercios.where((comercio) {
        final titleMatch = (comercio['username'] ?? '').toLowerCase().contains(query);
        final descriptionMatch = (comercio['description'] ?? '').toLowerCase().contains(query);
        return titleMatch || descriptionMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomSearchBar(
            searchController: _searchController,
            onSearchChanged: (query) => _filterComercios(),
            onLocationFilterPressed: _loadNearbyComercios,
            razas: [], // No se usa en comercios
            onRazaFilterChanged: (_) {},
            onSexoFilterChanged: (_) {},
            onPriceFilterChanged: (_) {},
            showFilters: false,
            showLocationFilter: true,
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
