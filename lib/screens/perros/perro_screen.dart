import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dogland/widgets/share_options.dart';

class PerroScreen extends StatelessWidget {
  final String raza;
  final String descripcion;
  final List<String> imagenes;
  final String genero;
  final String precio;
  final String criadorNombre;
  final String criadorDescripcion;
  final String criadorTelefono;
  final String criadorCorreo;
  final LatLng ubicacionCriador;
  final String perfilImagenCriadorUrl;

  PerroScreen({
    required this.raza,
    required this.descripcion,
    required this.imagenes,
    required this.genero,
    required this.precio,
    required this.criadorNombre,
    required this.criadorDescripcion,
    required this.criadorTelefono,
    required this.criadorCorreo,
    required this.ubicacionCriador,
    required this.perfilImagenCriadorUrl,
  });

  @override
  Widget build(BuildContext context) {
    final String perroUrl = 'https://dogland.com/perro/${raza.replaceAll(' ', '_')}';

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Scroll de imágenes del perro
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
                  const SizedBox(height: 10),
                  Text(
                    descripcion,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text('Género: $genero', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Text('Precio: $precio€', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3. Información del criador
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
                            backgroundImage: perfilImagenCriadorUrl.isNotEmpty
                                ? NetworkImage(perfilImagenCriadorUrl)
                                : null,
                            child: perfilImagenCriadorUrl.isEmpty
                                ? Icon(Icons.person, size: 30)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              criadorNombre,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        criadorDescripcion,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 4. Iconos de acción (Compartir, Chat, Favoritos)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionIcon(Icons.share, () => _showShareOptions(context, perroUrl)),
                _buildActionIcon(Icons.chat, () {}),
                _buildActionIcon(Icons.favorite_border, () {}),
              ],
            ),

            const SizedBox(height: 20),

            // 5. Información de contacto del criador
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.phone),
                      const SizedBox(width: 10),
                      Text(criadorTelefono),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.email),
                      const SizedBox(width: 10),
                      Text(criadorCorreo),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 6. Mapa de ubicación del criador
            Container(
              height: 200,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: ubicacionCriador,
                  zoom: 14,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId('ubicacionCriador'),
                    position: ubicacionCriador,
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showShareOptions(BuildContext context, String perroUrl) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ShareOptions(
          shareText: 'Visita el perro de raza $raza en',
          url: perroUrl,
        );
      },
    );
  }

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
