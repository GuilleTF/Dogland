// comercio_card.dart
import 'package:flutter/material.dart';

class ComercioCard extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final String? imagen;
  final VoidCallback onTap;

  const ComercioCard({
    Key? key,
    required this.titulo,
    required this.descripcion,
    this.imagen,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.symmetric(vertical: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contenedor de imagen o ícono
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: Colors.grey[200], // Color de fondo para el ícono
                ),
                child: imagen != null && imagen!.isNotEmpty && imagen!.startsWith('http')
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.network(
                          imagen!,
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                        ),
                      )
                    : Icon(
                        Icons.store,
                        size: 50, // Tamaño del ícono
                        color: Colors.grey[600], // Color del ícono
                      ),
              ),
              const SizedBox(width: 15),
              // Título y descripción
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo.isNotEmpty ? titulo : 'Nombre no disponible',
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      descripcion.isNotEmpty ? descripcion : 'Sin descripción',
                      style: const TextStyle(fontSize: 14.0, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
