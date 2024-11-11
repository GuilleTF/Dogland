// widgets/perros_stack.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dogland/screens/perros/perros_screen.dart';
import 'package:dogland/screens/perros/criador_screen.dart';
import 'package:dogland/screens/perros/perro_screen.dart';

class PerrosStack extends StatelessWidget {
  final int perrosIndex;
  final Map<String, dynamic>? selectedCriadorData;
  final Map<String, dynamic>? selectedPerroData;
  final ValueChanged<Map<String, dynamic>> onCriadorSelected;
  final ValueChanged<Map<String, dynamic>> onPerroSelected;
  final VoidCallback onBackPressed;

  PerrosStack({
    required this.perrosIndex,
    this.selectedCriadorData,
    this.selectedPerroData,
    required this.onCriadorSelected,
    required this.onPerroSelected,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    print("Datos de selectedPerroData en PerrosStack: $selectedPerroData");
    print("Datos de selectedCriadorData en PerrosStack: $selectedCriadorData");

    return IndexedStack(
      index: perrosIndex,
      children: [
        PerrosScreen(onCriadorSelected: onCriadorSelected),
        if (selectedCriadorData != null)
          CriadorScreen(
            criadorId: selectedCriadorData!['id'] ?? '',
            nombre: selectedCriadorData!['username'] ?? 'Nombre no disponible',
            descripcion: selectedCriadorData!['description'] ?? 'Sin descripción',
            imagenes: List<String>.from(selectedCriadorData!['businessImages'] ?? []),
            telefono: selectedCriadorData!['phoneNumber'] ?? 'Teléfono no disponible',
            correo: selectedCriadorData!['email'] ?? 'Correo no disponible',
            ubicacion: LatLng(
              selectedCriadorData!['location']?.latitude ?? 0,
              selectedCriadorData!['location']?.longitude ?? 0,
            ),
            perfilImagenUrl: selectedCriadorData!['profileImage'] ?? '',
            onPerroSelected: onPerroSelected,
          ),
        if (selectedPerroData != null)
          PerroScreen(
            perroId: selectedPerroData!['id'] ?? '',
            raza: selectedPerroData!['raza'] ?? 'Raza no disponible',
            descripcion: selectedPerroData!['descripcion'] ?? 'Sin descripción',
            imagenes: List<String>.from(selectedPerroData!['images'] ?? []),
            genero: selectedPerroData!['genero'] ?? 'Género no disponible',
            precio: selectedPerroData!['precio']?.toString() ?? 'Precio no disponible',
            userId: selectedPerroData!['userId'] ?? '',
          ),
      ],
    );
  }
}
