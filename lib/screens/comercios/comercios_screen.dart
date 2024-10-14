// comercios_screen.dart
import 'package:flutter/material.dart';

class ComerciosScreen extends StatelessWidget {
  final VoidCallback onBackToHome;

  const ComerciosScreen({super.key, required this.onBackToHome});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store,
            size: 100,
            color: Colors.grey,
          ),
          SizedBox(height: 20),
          Text(
            'Pantalla de Comercios',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Aquí encontrarás comercios para mascotas.',
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
