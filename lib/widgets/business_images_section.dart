import 'package:flutter/material.dart';

class BusinessImagesSection extends StatelessWidget {
  final List<String> imageUrls;
  final Function() onAddImage;
  final Function(String) onDeleteImage;
  final String role;

  BusinessImagesSection({
    required this.imageUrls,
    required this.onAddImage,
    required this.onDeleteImage,
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
    // Obtén el tamaño de la pantalla para un ajuste adaptativo
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth * 0.3; // 30% del ancho de la pantalla

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _sectionTitle,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: imageSize, // Usamos el tamaño adaptativo
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...imageUrls.map((url) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      children: [
                        Container(
                          width: imageSize,
                          height: imageSize,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            color: Colors.grey[200],
                          ),
                          child: url.startsWith('http')
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: Image.network(
                                    url,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.error,
                                        color: Colors.red,
                                        size: imageSize * 0.4, // 40% del tamaño de la imagen
                                      );
                                    },
                                  ),
                                )
                              : Icon(
                                  Icons.store,
                                  size: imageSize * 0.5, // 50% del tamaño de la imagen
                                  color: Colors.grey[600],
                                ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: imageSize * 0.25, // 25% del tamaño de la imagen
                            ),
                            onPressed: () => onDeleteImage(url),
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
                    width: imageSize,
                    height: imageSize,
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(
                        Icons.add,
                        size: imageSize * 0.5, // 50% del tamaño de la imagen
                      ),
                    ),
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
