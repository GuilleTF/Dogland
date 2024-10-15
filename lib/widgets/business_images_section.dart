import 'package:flutter/material.dart';

class BusinessImagesSection extends StatelessWidget {
  final List<String> imageUrls;
  final Function() onAddImage;
  final Function(String) onDeleteImage; // Añadir función para eliminar
  final String role;

  BusinessImagesSection({
    required this.imageUrls,
    required this.onAddImage,
    required this.onDeleteImage, // Añadir función para eliminar
    required this.role,
  });

  String get _sectionTitle {
    switch (role) {
      case 'criador':
        return 'Fotos de los Perros';
      case 'comerciante':
        return 'Fotos del Negocio';
      default:
        return 'Fotos';
    }
  }

  @override
  Widget build(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(_sectionTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      SizedBox(
        height: 100,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            ...imageUrls.map((url) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  Image.network(
                    url,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        child: Icon(Icons.broken_image, color: Colors.red),
                      );
                    },
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => onDeleteImage(url), // Llamada a la función de eliminación
                    ),
                  ),
                ],
              ),
            )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: onAddImage,
                child: Container(
                  width: 100,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.add)),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
}