import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getOrCreateChat(String userId, String recipientId) async {
    try {
      final chatQuery = await _firestore
          .collection('chats')
          .where('users', arrayContains: userId)
          .get();

      // Encuentra un chat con ambos usuarios o crea uno nuevo
      for (var doc in chatQuery.docs) {
        if ((doc['users'] as List).contains(recipientId)) {
          return doc.id;
        }
      }

      // Si no se encuentra un chat, crear uno nuevo
      final chatDoc = await _firestore.collection('chats').add({
        'users': [userId, recipientId],
        'lastMessage': '',
        'timestamp': FieldValue.serverTimestamp(),
      });
      return chatDoc.id;
    } catch (e) {
      print("Error al crear o encontrar el chat: $e");
      rethrow;
    }
  }
}
