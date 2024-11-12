import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PerrosService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtén los perros del criador autenticado
  Future<List<Map<String, dynamic>>> getPerrosDelCriador() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception("Usuario no autenticado");
    }

    final querySnapshot = await _firestore
        .collection('perros')
        .where('userId', isEqualTo: user.uid)
        .get();

    return querySnapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  // Añadir un nuevo perro a la colección
  Future<void> addPerro(Map<String, dynamic> perroData) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception("Usuario no autenticado");
    }

    perroData['userId'] = user.uid; // Asigna el perro al usuario actual
    await _firestore.collection('perros').add(perroData);
  }

  // Actualizar un perro existente
  Future<void> updatePerro(String perroId, Map<String, dynamic> perroData) async {
    await _firestore.collection('perros').doc(perroId).update(perroData);
  }

  // Eliminar un perro
  Future<void> deletePerro(String perroId) async {
    await _firestore.collection('perros').doc(perroId).delete();
  }
}
