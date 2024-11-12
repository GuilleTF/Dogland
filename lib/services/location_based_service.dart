// services/location_based_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'location_service.dart';

class LocationBasedService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocationService _locationService = LocationService();

  Future<List<Map<String, dynamic>>> getNearbyItems(String tipo) async {
    Position? userPosition = await _locationService.getCurrentPosition();
    if (userPosition == null) {
      print("No se pudo obtener la ubicación del usuario.");
      return [];
    }

    final itemsSnapshot = await _firestore.collection('users')
        .where('role', isEqualTo: tipo)
        .get();

    List<Map<String, dynamic>> items = [];

    for (var doc in itemsSnapshot.docs) {
      final data = doc.data();
      data['id'] = doc.id;

      print("Datos del comercio ${data['username']}: $data");

      if (data['location'] is GeoPoint) {
        GeoPoint geoPoint = data['location'] as GeoPoint;
        
        print("Ubicación encontrada para ${data['username']}: ${geoPoint.latitude}, ${geoPoint.longitude}");

        data['distance'] = _locationService.calculateDistance(
          userPosition.latitude,
          userPosition.longitude,
          geoPoint.latitude,
          geoPoint.longitude,
        );
        items.add(data);
      } else {
        print("El comercio ${data['username']} no tiene datos de ubicación.");
        data['distance'] = null;
      }
    }

    items.sort((a, b) => (a['distance'] ?? double.infinity).compareTo(b['distance'] ?? double.infinity));

    return items;
  }
}
