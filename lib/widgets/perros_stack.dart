import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
            perroId: selectedPerroData!['perroId'] ?? '',
            raza: selectedPerroData!['perro']['raza'] ?? 'Raza no disponible',
            descripcion: selectedPerroData!['perro']['descripcion'] ?? 'Sin descripción',
            imagenes: List<String>.from(selectedPerroData!['perro']['images'] ?? []),
            genero: selectedPerroData!['perro']['genero'] ?? 'Género no disponible',
            precio: selectedPerroData!['perro']['precio']?.toString() ?? 'Precio no disponible',

            // Datos del criador
            criadorNombre: selectedPerroData!['criador']['username'] ?? 'Nombre no disponible',
            criadorDescripcion: selectedPerroData!['criador']['description'] ?? 'Sin descripción',
            criadorTelefono: selectedPerroData!['criador']['phoneNumber'] ?? 'Teléfono no disponible',
            criadorCorreo: selectedPerroData!['criador']['email'] ?? 'Correo no disponible',
            ubicacionCriador: LatLng(
              selectedPerroData!['criador']['location']?.latitude ?? 0,
              selectedPerroData!['criador']['location']?.longitude ?? 0,
            ),
            perfilImagenCriadorUrl: selectedPerroData!['criador']['profileImage'] ?? '',
          ),
      ],
    );
  }
}
