// widgets/home_content.dart

import 'package:flutter/material.dart';

class HomeContent extends StatelessWidget {
  final VoidCallback onComerciosTapped;
  final VoidCallback onPerrosTapped;

  HomeContent({required this.onComerciosTapped, required this.onPerrosTapped});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onComerciosTapped,
            child: _buildSectionTile(Icons.store, 'Comercios'),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: onPerrosTapped,
            child: _buildSectionTile(Icons.pets, 'Perros'),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTile(IconData icon, String title) {
    return Container(
      margin: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 100, color: Colors.black),
            Text(title, style: TextStyle(fontSize: 24, color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
