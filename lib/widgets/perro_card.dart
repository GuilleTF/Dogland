import 'package:flutter/material.dart';

class PerroCard extends StatelessWidget {
  final Map<String, dynamic> perro;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  PerroCard({required this.perro, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final String? imagen = (perro['images'] != null && perro['images'].isNotEmpty)
        ? perro['images'][0] // Primera imagen de la lista
        : null;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),  // Reduce los márgenes laterales
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),  // Añadir más padding para darle espacio a la imagen
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,  // Centrar verticalmente la fila
          children: [
            // Imagen del perro
            Container(
              width: 90,  // Ancho de la imagen
              height: 90,  // Altura de la imagen
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
                      size: 80,  // Tamaño del ícono cuando no hay imagen
                      color: Colors.grey[600],
                    ),
            ),
            SizedBox(width: 16.0),  // Separador entre la imagen y el texto
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
            // Iconos de editar y eliminar en una fila
            Row(
              mainAxisSize: MainAxisSize.min,  // Mantener los botones compactos
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
