// widgets/action_icons.dart
import 'package:flutter/material.dart';

class ActionIcons extends StatelessWidget {
  final VoidCallback onShare;
  final VoidCallback onChat;
  final VoidCallback onFavoriteToggle;
  final bool isFavorite; // Agregado: indica si es favorito

  const ActionIcons({
    required this.onShare,
    required this.onChat,
    required this.onFavoriteToggle,
    this.isFavorite = false, // Valor por defecto a false
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionIcon(Icons.share, onShare),
        _buildActionIcon(Icons.chat, onChat),
        _buildFavoriteIcon(), // Modificado para manejar el estado de favorito
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
      onTap: onFavoriteToggle, // Llama a la función para alternar el favorito
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border, // Cambia el ícono
          color: isFavorite ? Colors.red : Colors.black, // Color del ícono según estado
        ),
      ),
    );
  }
}
