// screens/perros/perro_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dogland/widgets/image_carousel.dart';
import 'package:dogland/widgets/contact_info.dart';
import 'package:dogland/widgets/action_icons.dart';
import 'package:dogland/widgets/map_view.dart';
import 'package:dogland/widgets/share_options.dart';
import 'package:dogland/services/favorites_service.dart';
import 'package:dogland/screens/mensajes/chat_screen.dart';
import 'package:dogland/services/chat_service.dart';

class PerroScreen extends StatefulWidget {
  final String perroId;
  final String raza;
  final String descripcion;
  final List<String> imagenes;
  final String genero;
  final String precio;
  final String userId;


  final ChatService _chatService = ChatService();

  PerroScreen({
    required this.perroId,
    required this.raza,
    required this.descripcion,
    required this.imagenes,
    required this.genero,
    required this.precio,
    required this.userId,
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
            ActionIcons(
              onShare: () => _showShareOptions(context, perroUrl),
              onChat: () async {
                final userId = FirebaseAuth.instance.currentUser!.uid;
                print("Valor de widget.userId antes de abrir el chat: ${widget.userId}");

                try {
                  final chatId = await widget._chatService.getOrCreateChat(userId, widget.userId);

                  // Verifica si chatId no es nulo antes de navegar
                  if (chatId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          chatId: chatId,
                          userId: userId,
                          recipientId: widget.userId,
                        ),
                      ),
                    );
                  } else {
                    print("Error: chatId es nulo.");
                    // Muestra un mensaje de error o toma alguna acción
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("No se pudo iniciar el chat. Intenta de nuevo.")),
                    );
                  }
                } catch (e) {
                  print("Error al obtener el chat: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Hubo un problema al obtener el chat. Intenta de nuevo.")),
                  );
                }
              },
              isFavorite: isFavorite,
              onFavoriteToggle: _toggleFavorite,
            ),
            const SizedBox(height: 20),
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
