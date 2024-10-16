// profile_service.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

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

  Future<String> uploadImage(File imageFile, String folder) async {
    if (!imageFile.existsSync()) {
      throw Exception("El archivo no existe.");
    }

    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception("Usuario no autenticado");

      final ref = _storage.ref().child(folder).child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error al subir la imagen: $e");
      throw e;
    }
  }

  Future<String> uploadImageFromBytes(Uint8List imageData, String folder) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception("Usuario no autenticado");

      final ref = _storage.ref().child(folder).child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putData(imageData);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error al subir la imagen desde bytes: $e");
      throw e;
    }
  }
}
