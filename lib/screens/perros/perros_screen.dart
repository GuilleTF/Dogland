// screens/perros/perros_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dogland/widgets/custom_search_bar.dart';
import 'package:dogland/widgets/comercio_card.dart';
import 'package:dogland/services/location_based_service.dart';
import 'package:dogland/data/razas.dart';

class PerrosScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onCriadorSelected;

  const PerrosScreen({Key? key, required this.onCriadorSelected}) : super(key: key);

  @override
  _PerrosScreenState createState() => _PerrosScreenState();
}

class _PerrosScreenState extends State<PerrosScreen> {
  final LocationBasedService _locationBasedService = LocationBasedService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _allCriadores = [];
  List<Map<String, dynamic>> _filteredCriadores = [];
  List<Map<String, dynamic>> _nearbyCriadores = [];
  bool _isLoading = true;

  String? _selectedRaza;
  String? _selectedSexo;
  int? _minPrice;
  int? _maxPrice;

  @override
  void initState() {
    super.initState();
    _loadCriadores();
    _searchController.addListener(_filterCriadores);
  }

  void _loadCriadores() async {
    setState(() => _isLoading = true);
    FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Criador')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _allCriadores = snapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();
        _filteredCriadores = _allCriadores;
        _isLoading = false;
      });
    });
  }

  void _loadNearbyCriadores() async {
    setState(() => _isLoading = true);
    try {
      List<Map<String, dynamic>> criadores = await _locationBasedService.getNearbyItems('Criador');
      setState(() {
        _nearbyCriadores = criadores;
        _filteredCriadores = criadores;  // Mostrar sólo los cercanos
        _isLoading = false;
      });
    } catch (e) {
      print("Error al cargar criadores cercanos: $e");
      setState(() => _isLoading = false);
    }
  }

  void _filterCriadores() {
    String query = _searchController.text.toLowerCase();

    setState(() {
      _filteredCriadores = _allCriadores.where((criador) {
        bool matchesSearch = criador['username']?.toLowerCase().contains(query) ?? false;
        bool matchesRaza = _selectedRaza == null || criador['perros'].any((p) => p['raza'] == _selectedRaza);
        bool matchesSexo = _selectedSexo == null || criador['perros'].any((p) => p['genero'] == _selectedSexo);
        bool matchesPrice = criador['perros'].any((p) =>
            (_minPrice == null || p['precio'] >= _minPrice!) &&
            (_maxPrice == null || p['precio'] <= _maxPrice!));

        return matchesSearch && matchesRaza && matchesSexo && matchesPrice;
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
            onSearchChanged: (query) => _filterCriadores(),
            onLocationFilterPressed: _loadNearbyCriadores,
            razas: razasDePerros,
            onRazaFilterChanged: (value) {
              setState(() => _selectedRaza = value);
              _filterCriadores();
            },
            onSexoFilterChanged: (value) {
              setState(() => _selectedSexo = value);
              _filterCriadores();
            },
            onMinPriceChanged: (value) {
              setState(() => _minPrice = value);
              _filterCriadores();
            },
            onMaxPriceChanged: (value) {
              setState(() => _maxPrice = value);
              _filterCriadores();
            },
            showFilters: true,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              icon: Icon(Icons.location_on),
              label: Text('Filtrar por Ubicación'),
              onPressed: _loadNearbyCriadores,
            ),
          ),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
                  child: ListView.builder(
                    itemCount: _filteredCriadores.length,
                    itemBuilder: (context, index) {
                      var criadorData = _filteredCriadores[index];
                      var distance = criadorData['distance'];
                      return ComercioCard(
                        titulo: criadorData['username'] ?? 'Nombre no disponible',
                        descripcion: criadorData['description'] ?? 'Descripción no disponible',
                        imagen: (criadorData['businessImages'] != null && criadorData['businessImages'].isNotEmpty)
                            ? criadorData['businessImages'][0]
                            : null,
                        distance: distance != null ? "${(distance / 1000).toStringAsFixed(1)} km de distancia" : "Distancia no disponible",
                        onTap: () => widget.onCriadorSelected(criadorData),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
