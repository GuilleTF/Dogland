// screens/comercios/comercio_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dogland/widgets/image_carousel.dart';
import 'package:dogland/widgets/contact_info.dart';
import 'package:dogland/widgets/action_icons.dart';
import 'package:dogland/widgets/map_view.dart';
import 'package:dogland/widgets/share_options.dart';
import 'package:dogland/services/favorites_service.dart';

class ComercioScreen extends StatefulWidget {
  final String comercioId;
  final String nombre;
  final String descripcion;
  final List<String> imagenes;
  final String telefono;
  final String correo;
  final LatLng ubicacion;
  final String perfilImagenUrl;

  ComercioScreen({
    required this.comercioId,
    required this.nombre,
    required this.descripcion,
    required this.imagenes,
    required this.telefono,
    required this.correo,
    required this.ubicacion,
    required this.perfilImagenUrl,
  });

  @override
  _ComercioScreenState createState() => _ComercioScreenState();
}

class _ComercioScreenState extends State<ComercioScreen> {
  final favoritesService = FavoritesService();
  late bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final favoriteStatus = await favoritesService.isFavorite(widget.comercioId);
    setState(() {
      isFavorite = favoriteStatus;
    });
  }

  void _toggleFavorite() async {
    await favoritesService.toggleFavorite(widget.comercioId, 'comercio');
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String comercioUrl = 'https://dogland.com/comercio/${widget.nombre.replaceAll(' ', '_')}';

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ImageCarousel(images: widget.imagenes),
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
                            backgroundImage: widget.perfilImagenUrl.isNotEmpty
                                ? NetworkImage(widget.perfilImagenUrl)
                                : null,
                            child: widget.perfilImagenUrl.isEmpty
                                ? Icon(Icons.store, size: 30)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.nombre,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        widget.descripcion,
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
              onShare: () => _showShareOptions(context, comercioUrl),
              onChat: () {},
              isFavorite: isFavorite,
              onFavoriteToggle: _toggleFavorite,
            ),
            const SizedBox(height: 20),
            ContactInfo(telefono: widget.telefono, correo: widget.correo),
            const SizedBox(height: 20),
            MapView(location: widget.ubicacion, markerId: 'ubicacionComercio'),
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
          shareText: 'Visita el comercio ${widget.nombre} en',
          url: comercioUrl,
        );
      },
    );
  }
}
