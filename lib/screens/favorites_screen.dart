// screens/favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dogland/services/favorites_service.dart';
import 'package:dogland/widgets/perro_card.dart';
import 'package:dogland/widgets/comercio_card.dart';

class FavoritesScreen extends StatelessWidget {
  final FavoritesService favoritesService = FavoritesService();
  final Function(Map<String, dynamic>) onPerroSelected;
  final Function(Map<String, dynamic>) onComercioSelected;
  
  FavoritesScreen({
    required this.onPerroSelected,
    required this.onComercioSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: favoritesService.getFavorites(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final favoritos = snapshot.data!;

            if (favoritos.isEmpty) {
              return Center(child: Text("No tienes favoritos todavía"));
            }

            return ListView.builder(
              itemCount: favoritos.length,
              itemBuilder: (context, index) {
                var favorito = favoritos[index];
                final itemId = favorito['itemId'];
                final itemType = favorito['itemType'];

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection(itemType == 'perro' ? 'perros' : 'users')
                      .doc(itemId)
                      .get(),
                  builder: (context, itemSnapshot) {
                    if (!itemSnapshot.hasData) {
                      return ListTile(title: Text('Cargando...'));
                    }

                    final itemData = itemSnapshot.data!.data() as Map<String, dynamic>?;

                    if (itemData == null) {
                      return ListTile(title: Text('Elemento no encontrado'));
                    }

                    // Obtener la distancia en double o asignar un texto adecuado si no está disponible
                    final double distance = favorito['distance'] != null
                        ? favorito['distance'] as double
                        : 0.0;
                    
                    final String distanceText = distance != 0.0 
                        ? "${(distance / 1000).toStringAsFixed(1)} km de distancia"
                        : "Distancia no disponible";

                    return itemType == 'perro'
                        ? PerroCard(
                            perro: itemData,
                            onTap: () => onPerroSelected({
                              'perroId': itemId,
                              'perro': itemData,
                              'criador': itemData['userId'],
                            }),
                            showActions: false,
                          )
                        : ComercioCard(
                            titulo: itemData['username'] ?? 'Sin Nombre',
                            descripcion: itemData['description'] ?? 'Sin Descripción',
                            imagen: itemData['businessImages'] != null &&
                                    itemData['businessImages'].isNotEmpty
                                ? itemData['businessImages'][0]
                                : itemData['profileImage'],
                            distance: distanceText, // Convertir en String para mostrar
                            onTap: () => onComercioSelected({
                              'comercioId': itemId,
                              ...itemData,
                            }),
                          );
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Error al cargar favoritos"));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
