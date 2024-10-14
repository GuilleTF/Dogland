// razas_screen.dart
import 'package:flutter/material.dart';

class RazasScreen extends StatelessWidget {
  final VoidCallback onBackToHome;

  const RazasScreen({super.key, required this.onBackToHome});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets,
            size: 100,
            color: Colors.grey,
          ),
          SizedBox(height: 20),
          Text(
            'Pantalla de Razas de Perros',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Aquí encontrarás diferentes razas de perros.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: onBackToHome,
            child: Text('Volver'),
          ),
        ],
      ),
    );
  }
}
