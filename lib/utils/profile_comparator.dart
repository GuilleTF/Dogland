// lib/utils/profile_comparator.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ProfileComparator {
  final String initialName;
  final String initialDescription;
  final String initialPhone;
  final LatLng? initialLocationCoordinates;
  final String? initialProfileImageUrl;
  final List<String> initialBusinessImageUrls;

  ProfileComparator({
    required this.initialName,
    required this.initialDescription,
    required this.initialPhone,
    required this.initialLocationCoordinates,
    required this.initialProfileImageUrl,
    required this.initialBusinessImageUrls,
  });

  bool hasChanges({
    required String currentName,
    required String currentDescription,
    required String currentPhone,
    required LatLng? currentLocationCoordinates,
    required String? currentProfileImageUrl,
    required List<String> currentBusinessImageUrls,
  }) {
    return initialName != currentName ||
        initialDescription != currentDescription ||
        initialPhone != currentPhone ||
        initialLocationCoordinates != currentLocationCoordinates ||
        initialProfileImageUrl != currentProfileImageUrl ||
        _listEquals(initialBusinessImageUrls, currentBusinessImageUrls) == false;
  }

  bool _listEquals(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }
}
