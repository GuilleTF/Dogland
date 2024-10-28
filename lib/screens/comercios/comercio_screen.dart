// screens/comercios/comercio_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dogland/widgets/image_carousel.dart';
import 'package:dogland/widgets/contact_info.dart';
import 'package:dogland/widgets/action_icons.dart';
import 'package:dogland/widgets/map_view.dart';
import 'package:dogland/widgets/share_options.dart';

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
            ImageCarousel(images: imagenes),
            const SizedBox(height: 20),
            Padding(
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
                  Text(descripcion, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ActionIcons(
              onShare: () => _showShareOptions(context, comercioUrl),
              onChat: () {},
              onFavorite: () {},
            ),
            const SizedBox(height: 20),
            ContactInfo(telefono: telefono, correo: correo),
            const SizedBox(height: 20),
            MapView(location: ubicacion, markerId: 'ubicacionComercio'),
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
}
