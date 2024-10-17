import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dogland/widgets/share_options.dart'; // Importa el nuevo widget

class ComercioScreen extends StatelessWidget {
  final String nombre;
  final String descripcion;
  final List<String> imagenes;
  final String telefono;
  final String correo;
  final LatLng ubicacion;
  final String perfilImagenUrl;

  ComercioScreen({
    required this.nombre,
    required this.descripcion,
    required this.imagenes,
    required this.telefono,
    required this.correo,
    required this.ubicacion,
    required this.perfilImagenUrl,
  });

  @override
  Widget build(BuildContext context) {
    final String comercioUrl = 'https://dogland.com/comercio/${nombre.replaceAll(' ', '_')}';

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
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          backgroundColor: Colors.transparent,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Image.network(
                              imagenes[index],
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    },
                    child: Image.network(
                      imagenes[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // 2. Recuadro sombreado para foto de perfil, nombre y descripción
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: perfilImagenUrl.isNotEmpty
                                ? NetworkImage(perfilImagenUrl)
                                : null,
                            child: perfilImagenUrl.isEmpty
                                ? Icon(Icons.store, size: 30)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              nombre,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        descripcion,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 3. Iconos de acción (Compartir, Chat, Favoritos) dentro de círculos con bordes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionIcon(Icons.share, () => _showShareOptions(context, comercioUrl)),
                _buildActionIcon(Icons.chat, () {
                  // Lógica para iniciar un chat
                }),
                _buildActionIcon(Icons.favorite_border, () {
                  // Lógica para añadir a favoritos
                }),
              ],
            ),

            const SizedBox(height: 20),

            // 4. Información de contacto
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.phone),
                      const SizedBox(width: 10),
                      Text(telefono),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.email),
                      const SizedBox(width: 10),
                      Text(correo),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 5. Mapa de ubicación
            Container(
              height: 200,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: ubicacion,
                  zoom: 14,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId('ubicacionComercio'),
                    position: ubicacion,
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showShareOptions(BuildContext context, String comercioUrl) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ShareOptions(
          shareText: 'Visita el comercio $nombre en',
          url: comercioUrl,
        );
      },
    );
  }

  // Función para crear iconos de acción dentro de círculos con bordes negros
  Widget _buildActionIcon(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Icon(icon, color: Colors.black),
      ),
    );
  }

}
