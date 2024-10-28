// screens/perros/perro_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dogland/widgets/image_carousel.dart';
import 'package:dogland/widgets/contact_info.dart';
import 'package:dogland/widgets/action_icons.dart';
import 'package:dogland/widgets/map_view.dart';
import 'package:dogland/widgets/share_options.dart';
import 'package:dogland/services/favorites_service.dart';

class PerroScreen extends StatefulWidget {
  final String perroId;
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
    required this.perroId,
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
  _PerroScreenState createState() => _PerroScreenState();
}

class _PerroScreenState extends State<PerroScreen> {
  final favoritesService = FavoritesService();
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final favoriteStatus = await favoritesService.isFavorite(widget.perroId);
    setState(() {
      isFavorite = favoriteStatus;
    });
  }

  void _toggleFavorite() async {
    if (widget.perroId.isEmpty) {
    print("Error: perroId está vacío.");
    return;
  }
    await favoritesService.toggleFavorite(widget.perroId, 'perro');
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String perroUrl = 'https://dogland.com/perro/${widget.raza.replaceAll(' ', '_')}';

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ImageCarousel(images: widget.imagenes),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.raza, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(widget.descripcion, style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Text('Género: ${widget.genero}', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Text('Precio: ${widget.precio}€', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
                            backgroundImage: widget.perfilImagenCriadorUrl.isNotEmpty
                                ? NetworkImage(widget.perfilImagenCriadorUrl)
                                : null,
                            child: widget.perfilImagenCriadorUrl.isEmpty
                                ? Icon(Icons.person, size: 30)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.criadorNombre,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        widget.criadorDescripcion,
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
              isFavorite: isFavorite,
              onFavoriteToggle: _toggleFavorite,
            ),
            const SizedBox(height: 20),
            ContactInfo(telefono: widget.criadorTelefono, correo: widget.criadorCorreo),
            const SizedBox(height: 20),
            MapView(location: widget.ubicacionCriador, markerId: 'ubicacionCriador'),
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
          shareText: 'Visita el perro de raza ${widget.raza} en',
          url: perroUrl,
        );
      },
    );
  }
}
