// screens/perros/perro_screen.dart

import 'package:flutter/material.dart';

class PerroScreen extends StatelessWidget {
  final String raza;
  final String descripcion;
  final List<String> imagenes;
  final String genero;
  final String precio;

  PerroScreen({
    required this.raza,
    required this.descripcion,
    required this.imagenes,
    required this.genero,
    required this.precio,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Scroll de imágenes
            Container(
              height: 250,
              child: PageView.builder(
                itemCount: imagenes.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    imagenes[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // 2. Información del perro
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    raza,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    descripcion,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Género: $genero',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Precio: $precio€',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
