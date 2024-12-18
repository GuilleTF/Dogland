// widgets/home_content.dart

import 'package:flutter/material.dart';

class HomeContent extends StatelessWidget {
  final VoidCallback onComerciosTapped;
  final VoidCallback onPerrosTapped;

  HomeContent({required this.onComerciosTapped, required this.onPerrosTapped});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12.0),
        padding: EdgeInsets.symmetric(vertical: 60.0, horizontal: 10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10),
            Text(
              "¿Qué busco?", 
              style: TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 30),

            GestureDetector(
              onTap: onComerciosTapped,
              child: _buildSectionTile(Icons.store, 'Comercios', height: 200),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onPerrosTapped,
              child: _buildSectionTile(Icons.pets, 'Perros', height: 200),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTile(IconData icon, String title, {double height = 180}) {
    return Container(
      height: height, 
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20.0),
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
            Text(title, style: TextStyle(fontSize: 28, color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
