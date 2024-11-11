// widgets/comercios_stack.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../screens/comercios/comercios_screen.dart';
import '../screens/comercios/comercio_screen.dart';

class ComerciosStack extends StatelessWidget {
  final int comerciosIndex;
  final Map<String, dynamic>? selectedComercioData;
  final ValueChanged<Map<String, dynamic>> onComercioSelected;
  final VoidCallback onBackPressed;

  ComerciosStack({
    required this.comerciosIndex,
    required this.selectedComercioData,
    required this.onComercioSelected,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    print("Contenido de selectedComercioData: $selectedComercioData");

    return IndexedStack(
      index: comerciosIndex,
      children: [
        ComerciosScreen(onComercioSelected: onComercioSelected),
        if (selectedComercioData != null && selectedComercioData!['comercioId'] != null)
          ComercioScreen(
            comercioId: selectedComercioData!['comercioId'], // Se asegura de pasar comercioId
            nombre: selectedComercioData!['username'] ?? 'Nombre no disponible',
            descripcion: selectedComercioData!['description'] ?? 'Sin descripción',
            imagenes: List<String>.from(selectedComercioData!['businessImages'] ?? []),
            telefono: selectedComercioData!['phoneNumber'] ?? 'No disponible',
            correo: selectedComercioData!['email'] ?? 'No disponible',
            ubicacion: selectedComercioData!['location'] != null
                ? LatLng(
                    selectedComercioData!['location'].latitude,
                    selectedComercioData!['location'].longitude,
                  )
                : LatLng(0, 0),
            perfilImagenUrl: selectedComercioData!['profileImage'] ?? '',
          )
        else
          Center(child: Text("Error: comercioId está vacío o selectedComercioData es null")),
      ],
    );
  }
}
