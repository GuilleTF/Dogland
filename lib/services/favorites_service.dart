// services/favorites_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Método para alternar entre añadir o eliminar un favorito
  Future<void> toggleFavorite(String itemId, String itemType) async {
    if (itemId.isEmpty) {
      print("Error: El itemId está vacío.");
      return;
    }

    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final favoriteRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('favoritos')
        .doc(itemId);

    final favoriteSnapshot = await favoriteRef.get();

    if (favoriteSnapshot.exists) {
      // Si el documento ya existe, se elimina el favorito
      await favoriteRef.delete();
    } else {
      // Si no existe, se añade el favorito
      await favoriteRef.set({
        'itemId': itemId,
        'itemType': itemType,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  // Método para verificar si un item está marcado como favorito
  Future<bool> isFavorite(String itemId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    final favoriteSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('favoritos')
        .doc(itemId)
        .get();

    return favoriteSnapshot.exists;
  }

  // Obtiene todos los favoritos del usuario
  Stream<List<Map<String, dynamic>>> getFavorites() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]); // Retorna una lista vacía si no hay usuario
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favoritos')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return {
                'itemId': doc['itemId'],
                'itemType': doc['itemType'],
                'timestamp': FieldValue.serverTimestamp(),
              };
            }).toList());
  }

  // Método para eliminar un favorito específico por su itemId
  Future<void> removeFavorite(String itemId) async {
    final userId = _auth.currentUser?.uid;
    final snapshot = await _firestore
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .where('itemId', isEqualTo: itemId)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
