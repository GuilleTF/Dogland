// comercios_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dogland/widgets/comercio_card.dart';

class ComerciosScreen extends StatelessWidget {
  final Function(Map<String, dynamic>) onComercioSelected;

  const ComerciosScreen({Key? key, required this.onComercioSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> comerciosStream = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Comercio')
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: comerciosStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No hay comercios disponibles'));
        }

        var comercios = snapshot.data!.docs;

        return ListView.builder(
          itemCount: comercios.length,
          itemBuilder: (context, index) {
            var comercioData = comercios[index].data() as Map<String, dynamic>;

            return ComercioCard(
              titulo: comercioData['username'] ?? 'Nombre no disponible',
              descripcion: comercioData['description'] ?? 'Sin descripción',
              imagen: comercioData['profileImage'] ?? null,
              onTap: () => onComercioSelected(comercioData),
            );
          },
        );
      },
    );
  }
}
