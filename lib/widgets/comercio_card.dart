import 'package:flutter/material.dart';

class ComercioCard extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final String? imagen; // Acepta null para manejar la imagen
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
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen o ícono predeterminado
              Container(
                width: 95,
                height: 95,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: Colors.grey[200],
                ),
                child: imagen != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.network(
                          imagen!,
                          fit: BoxFit.cover,
                          width: 95,
                          height: 95,
                        ),
                      )
                    : Icon(
                        Icons.store,
                        size: 80,
                        color: Colors.grey[600],
                      ),
              ),
              const SizedBox(width: 16.0),
              // Título y descripción
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo.isNotEmpty ? titulo : 'Nombre no disponible',
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      descripcion.isNotEmpty ? descripcion : 'Sin descripción',
                      style: const TextStyle(fontSize: 16.0, color: Colors.black54),
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
