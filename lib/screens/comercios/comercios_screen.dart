import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/comercio_card.dart'; // Importa el widget

class ComerciosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Stream para obtener comercios desde Firestore
    Stream<QuerySnapshot> comerciosStream = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Comercio')
        .snapshots();

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: comerciosStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay comercios disponibles'));
          }

          // Lista de comercios
          var comercios = snapshot.data!.docs;

          return ListView.builder(
            itemCount: comercios.length,
            itemBuilder: (context, index) {
              var comercioData = comercios[index].data() as Map<String, dynamic>;

              return ComercioCard(
                titulo: comercioData['name'] ?? 'Nombre no disponible',
                descripcion: comercioData['description'] ?? 'Sin descripción',
                imagen: comercioData['profileImage'], // Puede ser null
              );
            },
          );
        },
      ),
    );
  }
}
