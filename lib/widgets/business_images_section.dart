import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';

class BusinessImagesSection extends StatelessWidget {
  final List<File> mobileImages;
  final List<Uint8List> webImages;
  final Function() onAddImage;
  final Function(int) onDeleteImage;
  final String role;

  BusinessImagesSection({
    required this.mobileImages,
    required this.webImages,
    required this.onAddImage,
    required this.onDeleteImage,
    required this.role,
  });

  String get _sectionTitle {
    return role == 'comerciante' ? 'Fotos del Negocio' : 'Fotos';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth * 0.3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _sectionTitle,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: imageSize,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...List.generate(
                kIsWeb ? webImages.length : mobileImages.length,
                (index) => Padding(
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
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: kIsWeb
                              ? Image.memory(webImages[index], fit: BoxFit.cover)
                              : Image.file(mobileImages[index], fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: imageSize * 0.25,
                          ),
                          onPressed: () => onDeleteImage(index),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: onAddImage,
                  child: Container(
                    width: imageSize,
                    height: imageSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Colors.grey[300],
                    ),
                    child: Icon(
                      Icons.add,
                      size: imageSize * 0.5,
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
