import 'package:flutter/material.dart';

class PerroCard extends StatelessWidget {
  final Map<String, dynamic> perro;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  PerroCard({required this.perro, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    // Si el perro tiene imágenes, mostramos la primera, si no, mostramos el ícono de perro.
    final String? imagen = (perro['images'] != null && perro['images'].isNotEmpty)
        ? perro['images'][0] // Primera imagen de la lista
        : null;

    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.grey[200],
          ),
          child: imagen != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    imagen,
                    fit: BoxFit.cover,
                    width: 60,
                    height: 60,
                  ),
                )
              : Icon(
                  Icons.pets,
                  size: 40,
                  color: Colors.grey[600],
                ),
        ),
        title: Text(perro['raza']),
        subtitle: Text('${perro['genero']} - ${perro['precio']}€'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
