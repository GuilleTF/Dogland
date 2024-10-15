import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<DocumentSnapshot> getUserData() async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("Usuario no autenticado");
    return await _firestore.collection('users').doc(user.uid).get();
  }

  Future<void> updateProfileData(Map<String, dynamic> data) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("Usuario no autenticado");

    await _firestore.collection('users').doc(user.uid).set(data, SetOptions(merge: true));
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print("Error al eliminar la imagen: $e");
    }
  }
}

