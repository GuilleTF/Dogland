// screens/perros/perro_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dogland/widgets/image_carousel.dart';
import 'package:dogland/widgets/contact_info.dart';
import 'package:dogland/widgets/action_icons.dart';
import 'package:dogland/widgets/map_view.dart';
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
            ImageCarousel(images: imagenes),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(raza, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(descripcion, style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Text('Género: $genero', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Text('Precio: $precio€', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Información del Criador
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

            ActionIcons(
              onShare: () => _showShareOptions(context, perroUrl),
              onChat: () {},
              onFavorite: () {},
            ),
            const SizedBox(height: 20),
            ContactInfo(telefono: criadorTelefono, correo: criadorCorreo),
            const SizedBox(height: 20),
            MapView(location: ubicacionCriador, markerId: 'ubicacionCriador'),
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
}
