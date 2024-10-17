// comercios_screen.dart

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

  void _applyLocationFilter() {
    // Lógica para filtrar por ubicación, por ejemplo, mostrando un cuadro de diálogo
    // o usando la ubicación actual del usuario.
    // Esta función debería actualizar _filteredComercios en función de la ubicación.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomSearchBar(
            searchController: _searchController,
            onSearchChanged: (query) => _filterComercios(),
            onLocationFilterPressed: _applyLocationFilter,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredComercios.length,
              itemBuilder: (context, index) {
                var comercioData = _filteredComercios[index].data() as Map<String, dynamic>;

                return ComercioCard(
                  titulo: comercioData['username'] ?? 'Nombre no disponible',
                  descripcion: comercioData['description'] ?? 'Sin descripción',
                  imagen: comercioData['profileImage'] ?? null,
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
