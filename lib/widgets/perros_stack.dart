// widgets/perros_stack.dart

import 'package:flutter/material.dart';
import 'package:dogland/screens/perros/perros_screen.dart';
import 'package:dogland/screens/perros/perro_screen.dart';

class PerrosStack extends StatelessWidget {
  final int perrosIndex;
  final Map<String, dynamic>? selectedPerroData;
  final ValueChanged<Map<String, dynamic>> onPerroSelected;
  final VoidCallback onBackPressed;

  PerrosStack({
    required this.perrosIndex,
    required this.selectedPerroData,
    required this.onPerroSelected,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: perrosIndex,
      children: [
        PerrosScreen(onPerroSelected: onPerroSelected),
        if (selectedPerroData != null)
          PerroScreen(
            raza: selectedPerroData!['raza'] ?? 'Raza no disponible',
            descripcion: selectedPerroData!['descripcion'] ?? 'Sin descripción',
            imagenes: List<String>.from(selectedPerroData!['images'] ?? []),
            genero: selectedPerroData!['genero'] ?? 'Género no disponible',
            precio: selectedPerroData!['precio']?.toString() ?? 'Precio no disponible',
          ),
      ],
    );
  }
}
