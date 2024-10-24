import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dogland/widgets/comercio_card.dart';
import 'package:dogland/widgets/custom_search_bar.dart';

class ComerciosScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onComercioSelected;

  const ComerciosScreen({Key? key, required this.onComercioSelected}) : super(key: key);

  @override
  _ComerciosScreenState createState() => _ComerciosScreenState();
}

class _ComerciosScreenState extends State<ComerciosScreen> {
  TextEditingController _searchController = TextEditingController();
  List<QueryDocumentSnapshot> _allComercios = [];
  List<QueryDocumentSnapshot> _filteredComercios = [];

  @override
  void initState() {
    super.initState();
    _loadComercios();
    _searchController.addListener(_filterComercios);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterComercios);
    _searchController.dispose();
    super.dispose();
  }

  void _loadComercios() {
    FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Comercio')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _allComercios = snapshot.docs;
        _filteredComercios = _allComercios; // Inicialmente muestra todos
      });
    });
  }

  void _filterComercios() {
    String query = _searchController.text.toLowerCase();

    setState(() {
      _filteredComercios = _allComercios.where((doc) {
        var data = doc.data() as Map<String, dynamic>;
        final titleMatch = (data['username'] ?? '').toLowerCase().contains(query);
        final descriptionMatch = (data['description'] ?? '').toLowerCase().contains(query);
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
            onLocationFilterPressed: () {
              // Implementación de filtro de ubicación
            },
            razas: [],  // Vacío ya que no se usa en comercios
            onRazaFilterChanged: (_) {},  // No hace nada
            onSexoFilterChanged: (_) {},  // No hace nada
            onPriceFilterChanged: (_) {}, // No hace nada
            showFilters: false,
            showLocationFilter: true,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredComercios.length,
              itemBuilder: (context, index) {
                var comercioData = _filteredComercios[index].data() as Map<String, dynamic>;

                // Determinar la imagen que se mostrará en la tarjeta (solo de businessImages)
                String? imagen = comercioData['businessImages'] != null &&
                        comercioData['businessImages'].isNotEmpty
                    ? comercioData['businessImages'][0] // Primera imagen de businessImages
                    : null; // Ninguna imagen de perfil, solo el ícono si no hay imágenes de negocio

                return ComercioCard(
                  titulo: comercioData['username'] ?? 'Nombre no disponible',
                  descripcion: comercioData['description'] ?? 'Sin descripción',
                  imagen: imagen, // Asigna la imagen determinada
                  onTap: () => widget.onComercioSelected(comercioData),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
