import 'package:flutter/material.dart';

class PerroCard extends StatelessWidget {
  final Map<String, dynamic> perro;
  final VoidCallback? onEdit; // Cambiado a opcional
  final VoidCallback? onDelete; // Cambiado a opcional
  final bool showActions; // Añadido para controlar la visibilidad de los botones

  PerroCard({
    required this.perro,
    this.onEdit,
    this.onDelete,
    this.showActions = true, // Por defecto, muestra los botones
  });

  @override
  Widget build(BuildContext context) {
    final String? imagen = (perro['images'] != null && perro['images'].isNotEmpty)
        ? perro['images'][0] // Primera imagen de la lista
        : null;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Imagen del perro
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: Colors.grey[200],
              ),
              child: imagen != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        imagen,
                        fit: BoxFit.cover,
                        width: 90,
                        height: 90,
                      ),
                    )
                  : Icon(
                      Icons.pets,
                      size: 80,
                      color: Colors.grey[600],
                    ),
            ),
            SizedBox(width: 16.0),
            // Detalles del perro
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    perro['raza'],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '${perro['genero']} - ${perro['precio']}€',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            // Mostrar acciones solo si `showActions` es true
            if (showActions)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, size: 30),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, size: 30),
                    onPressed: onDelete,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
