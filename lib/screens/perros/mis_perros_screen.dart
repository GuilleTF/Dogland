import 'package:flutter/material.dart';
import '../../widgets/perro_card.dart';
import 'package:dogland/services/perros_service.dart';

class MisPerrosScreen extends StatefulWidget {
  final VoidCallback onAgregarPerroTapped;
  final Function(Map<String, dynamic>) onEditarPerroTapped;

  MisPerrosScreen({
    required this.onAgregarPerroTapped,
    required this.onEditarPerroTapped,  
  });

  @override
  _MisPerrosScreenState createState() => _MisPerrosScreenState();
}

class _MisPerrosScreenState extends State<MisPerrosScreen> {
  final PerrosService _perrosService = PerrosService();
  List<Map<String, dynamic>> _perros = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPerros();
  }

  Future<void> _loadPerros() async {
    try {
      final perros = await _perrosService.getPerrosDelCriador();
      setState(() {
        _perros = perros;
        _isLoading = false;
      });
    } catch (e) {
      print("Error al cargar los perros: $e");
      setState(() {
      _isLoading = false;
      });
    }
  }

  Future<void> _deletePerro(int index) async {
    try {
      await _perrosService.deletePerro(_perros[index]['id']);
      setState(() {
        _perros.removeAt(index);
      });
    } catch (e) {
      print("Error al eliminar el perro: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _perros.isEmpty
              ? Center(child: Text('No has añadido ningún perro todavía.'))
              : ListView.builder(
                  itemCount: _perros.length,
                  itemBuilder: (context, index) {
                    return PerroCard(
                      perro: _perros[index],
                      onEdit: () => widget.onEditarPerroTapped(_perros[index]), // Ahora usa el callback
                      onDelete: () => _deletePerro(index),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.onAgregarPerroTapped,  // Llama a la función que cambia el índice en HomeScreen
        child: Icon(Icons.add),
      ),
    );
  }
}
