import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class ComercioScreen extends StatelessWidget {
  final String nombre;
  final String descripcion;
  final List<String> imagenes;
  final String telefono;
  final String correo;
  final LatLng ubicacion;

  ComercioScreen({
    required this.nombre,
    required this.descripcion,
    required this.imagenes,
    required this.telefono,
    required this.correo,
    required this.ubicacion,
  });

  @override
  Widget build(BuildContext context) {
    final String comercioUrl = 'https://tuapp.com/comercio/${nombre.replaceAll(' ', '_')}';

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
                  );
                },
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 2. Nombre del negocio
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                nombre,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),

            // 3. Descripción del negocio
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                descripcion,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 20),

            // 4. Iconos de acción (Compartir, Chat, Favoritos)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    // Cierra el teclado antes de abrir el BottomSheet
                    FocusScope.of(context).unfocus();
                    _shareComercio(context, comercioUrl);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.chat),
                  onPressed: () {
                    // Lógica para iniciar un chat
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {
                    // Lógica para añadir a favoritos
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 20),

            // 5. Información de contacto
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

            // 6. Mapa de ubicación
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

  void _shareComercio(BuildContext context, String comercioUrl) {
    // Diálogo de opciones para compartir
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.share),
              title: Text('Compartir'),
              onTap: () {
                // Verifica que el texto no esté vacío antes de compartir
                if (comercioUrl.isNotEmpty) {
                  Share.share('Visita el comercio $nombre en $comercioUrl');
                }
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.link),
              title: Text('Copiar enlace'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: comercioUrl));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Enlace copiado al portapapeles')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
