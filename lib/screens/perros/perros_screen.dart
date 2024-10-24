import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dogland/widgets/perro_card.dart';
import 'package:dogland/widgets/custom_search_bar.dart';

class PerrosScreen extends StatefulWidget {
  @override
  _PerrosScreenState createState() => _PerrosScreenState();
}

class _PerrosScreenState extends State<PerrosScreen> {
  TextEditingController _searchController = TextEditingController();
  List<QueryDocumentSnapshot> _allPerros = [];
  List<QueryDocumentSnapshot> _filteredPerros = [];

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

  // Cargar todos los perros de la colección 'perros' en Firestore
  void _loadPerros() {
    FirebaseFirestore.instance.collection('perros').snapshots().listen((snapshot) {
      setState(() {
        _allPerros = snapshot.docs;
        _filteredPerros = _allPerros; // Inicialmente, mostramos todos los perros
      });
    });
  }

  // Filtrar los perros según lo que se escribe en el campo de búsqueda
  void _filterPerros() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPerros = _allPerros.where((doc) {
        var data = doc.data() as Map<String, dynamic>;
        final razaMatch = (data['raza'] ?? '').toLowerCase().contains(query);
        final descripcionMatch = (data['descripcion'] ?? '').toLowerCase().contains(query);
        return razaMatch || descripcionMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Barra de búsqueda personalizada
          CustomSearchBar(
            searchController: _searchController,
            onSearchChanged: (query) => _filterPerros(),
            onLocationFilterPressed: () {
              // Implementación futura para filtro de ubicación
              // Podrías agregar un diálogo o un selector de ubicaciones
            },
          ),
          // Listado de perros filtrados
          Expanded(
            child: ListView.builder(
              itemCount: _filteredPerros.length,
              itemBuilder: (context, index) {
                var perroData = _filteredPerros[index].data() as Map<String, dynamic>;

                // Determinar la imagen del perro
                String? imagen = perroData['images'] != null && perroData['images'].isNotEmpty
                    ? perroData['images'][0] // Primera imagen de la lista
                    : null;

                return PerroCard(
                  perro: _filteredPerros[index].data() as Map<String, dynamic>,
                  showActions: false,
                  onEdit: () {
                    // Aquí puedes implementar la edición del perro
                  },
                  onDelete: () async {
                    try {
                      // Eliminar el perro de Firestore
                      await FirebaseFirestore.instance
                          .collection('perros')
                          .doc(_filteredPerros[index].id)
                          .delete();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Perro eliminado')));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error eliminando el perro: $e')));
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
