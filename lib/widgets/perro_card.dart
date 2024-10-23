import 'package:flutter/material.dart';

class PerroCard extends StatelessWidget {
  final Map<String, dynamic> perro;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  PerroCard({required this.perro, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
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
