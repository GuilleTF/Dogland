// widgets/action_icons.dart
import 'package:flutter/material.dart';

class ActionIcons extends StatelessWidget {
  final VoidCallback onShare;
  final VoidCallback onChat;
  final VoidCallback onFavorite;

  const ActionIcons({
    required this.onShare,
    required this.onChat,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionIcon(Icons.share, onShare),
        _buildActionIcon(Icons.chat, onChat),
        _buildActionIcon(Icons.favorite_border, onFavorite),
      ],
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
