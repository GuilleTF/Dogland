// widgets/action_icons.dart
import 'package:flutter/material.dart';

class ActionIcons extends StatelessWidget {
  final VoidCallback onShare;
  final VoidCallback onChat;
  final VoidCallback onFavoriteToggle;
  final bool isFavorite;

  const ActionIcons({
    required this.onShare,
    required this.onChat,
    required this.onFavoriteToggle,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionIcon(Icons.share, onShare),
        _buildActionIcon(Icons.chat, onChat),
        _buildFavoriteIcon(),
      ],
    );
  }

  // Icono de acción general
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

  // Icono de favorito específico
  Widget _buildFavoriteIcon() {
    return GestureDetector(
      onTap: onFavoriteToggle,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.red : Colors.black,
        ),
      ),
    );
  }
}
