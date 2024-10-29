import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dogland/widgets/perro_card.dart';
import 'package:dogland/widgets/custom_search_bar.dart';
import 'package:dogland/data/razas.dart';  // Tu lista de razas

class PerrosScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onPerroSelected;

  const PerrosScreen({Key? key, required this.onPerroSelected}) : super(key: key);

  @override
  _PerrosScreenState createState() => _PerrosScreenState();
}

class _PerrosScreenState extends State<PerrosScreen> {
  TextEditingController _searchController = TextEditingController();
  List<QueryDocumentSnapshot> _allPerros = [];
  List<QueryDocumentSnapshot> _filteredPerros = [];

  String? _selectedRaza;
  String? _selectedSexo;
  RangeValues _priceRange = RangeValues(0, 1000);

  @override
  void initState() {
    super.initState();
    _loadPerros();
    _searchController.addListener(_filterPerros);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterPerros);
    _searchController.dispose();
    super.dispose();
  }

  void _loadPerros() {
    FirebaseFirestore.instance
      .collection('perros')
      .snapshots()
      .listen((snapshot) {
        setState(() {
          _allPerros = snapshot.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id; // Asigna el ID al mapa de datos del perro
            return doc;
          }).toList();
          _filteredPerros = _allPerros;
        });
      });
  }

  void _filterPerros() {
    String query = _searchController.text.toLowerCase();

    setState(() {
      _filteredPerros = _allPerros.where((doc) {
        var data = doc.data() as Map<String, dynamic>;

        bool matchesSearch = data['raza'].toLowerCase().contains(query) ||
            data['descripcion'].toLowerCase().contains(query);

        bool matchesRaza = _selectedRaza == null || data['raza'] == _selectedRaza;
        bool matchesSexo = _selectedSexo == null || data['genero'] == _selectedSexo;
        bool matchesPrice = (data['precio'] >= _priceRange.start && data['precio'] <= _priceRange.end);

        return matchesSearch && matchesRaza && matchesSexo && matchesPrice;
      }).toList();
    });
  }

  Future<void> _selectPerroWithCriadorData(Map<String, dynamic> perroData, String perroId) async {
    String userId = perroData['userId'];

    try {
      // Consultar los datos del criador desde la colección 'users'
      DocumentSnapshot criadorSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (criadorSnapshot.exists) {
        Map<String, dynamic> criadorData = criadorSnapshot.data() as Map<String, dynamic>;

        // Combinar los datos del perro y del criador en un solo mapa
        Map<String, dynamic> combinedData = {
          'perroId': perroId,
          'perro': perroData,
          'criador': criadorData,
        };
        print("ID del perro seleccionado: ${perroId} y ID del criador: ${combinedData['perro']['userId']}");
        // Pasar los datos combinados a la siguiente pantalla
        widget.onPerroSelected(combinedData);
      } else {
        print("No se encontró el criador con el ID: $userId");
      }
    } catch (e) {
      print("Error al obtener los datos del criador: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomSearchBar(
            searchController: _searchController,
            onSearchChanged: (query) => _filterPerros(),
            onLocationFilterPressed: () {
              // Implementación de filtro de ubicación
            },
            razas: razasDePerros,  // Lista de razas de perros
            onRazaFilterChanged: (value) {
              setState(() {
                _selectedRaza = value;
              });
              _filterPerros();
            },
            onSexoFilterChanged: (value) {
              setState(() {
                _selectedSexo = value;
              });
              _filterPerros();
            },
            onPriceFilterChanged: (RangeValues range) {
              setState(() {
                _priceRange = range;
              });
              _filterPerros();
            },
            showFilters: true,  // Mostrar los filtros
            showLocationFilter: false,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredPerros.length,
              itemBuilder: (context, index) {
                var perroData = _filteredPerros[index].data() as Map<String, dynamic>;
                var perroId = _filteredPerros[index].id;

                return PerroCard(
                  perro: perroData,
                  onTap: () => _selectPerroWithCriadorData(perroData,perroId),
                  showActions: false,  // No mostrar los botones de acción
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
