// raza_screen.dart
import 'package:flutter/material.dart';

class RazaScreen extends StatelessWidget {
  final String nombre;
  final String descripcion;
  final List<String> imagenes;

  const RazaScreen({
    Key? key,
    required this.nombre,
    required this.descripcion,
    required this.imagenes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen principal de la raza
            Container(
              height: 250,
              child: imagenes.isNotEmpty
                  ? PageView.builder(
                      itemCount: imagenes.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          imagenes[index],
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Icon(
                      Icons.pets,
                      size: 100,
                      color: Colors.grey,
                    ),
            ),
            const SizedBox(height: 20),

            // Nombre de la raza
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                nombre,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),

            // Descripción de la raza
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                descripcion,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
