// perfil_screen.dart

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dogland/services/profile_service.dart';
import 'package:dogland/services/image_service.dart';
import 'package:dogland/services/location_service.dart';
import 'package:dogland/widgets/business_images_section.dart';
import 'package:dogland/widgets/user_profile_widget.dart';
import 'package:dogland/utils/profile_comparator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';

class PerfilScreen extends StatefulWidget {
  final String role;

  PerfilScreen({required this.role});

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final ProfileService _profileService = ProfileService();
  final ImageService _imageService = ImageService();
  final LocationService _locationService = LocationService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _location = 'Ubicación desconocida';
  String _email = '';
  String? _profileImageUrl;
  File? _profileImageFile;
  List<File> _businessImages = [];
  List<Uint8List> _businessImageBytes = [];
  LatLng? _locationCoordinates;
  bool _isLoading = false;
  String userRole = '';

  // Valores iniciales para comparaciones
  late String initialName;
  late String initialDescription;
  late String initialPhone;
  late LatLng? initialLocationCoordinates;
  late String? initialProfileImageUrl;
  late List<String> initialBusinessImageUrls;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
  setState(() => _isLoading = true);
  try {
    DocumentSnapshot userData = await _profileService.getUserData();
    final userDataMap = userData.data() as Map<String, dynamic>?;

    if (userDataMap != null) {
      _nameController.text = userDataMap['username'] ?? '';
      _descriptionController.text = userDataMap['description'] ?? '';
      _phoneController.text = userDataMap['phoneNumber'] ?? '';
      _email = userDataMap['email'] ?? '';
      userRole = userDataMap['role'] ?? '';
      _profileImageUrl = userDataMap['profileImage'];

      if (userDataMap['location'] != null) {
        GeoPoint geoPoint = userDataMap['location'];
        _locationCoordinates = LatLng(geoPoint.latitude, geoPoint.longitude);
      }

      if (_locationCoordinates != null) {
        _location = await _locationService.getAddressFromLatLng(_locationCoordinates!);
      }

      // Esperar a que se carguen todas las imágenes
      if (userDataMap['businessImages'] != null) {
        _businessImages = await _imageService.loadImages(List<String>.from(userDataMap['businessImages']));
      }
    }
  } catch (e) {
    print("Error al cargar los datos del perfil: $e");
  } finally {
    setState(() => _isLoading = false);
  }
}

  Future<void> _saveProfile() async {
    final comparator = ProfileComparator(
      initialName: initialName,
      initialDescription: initialDescription,
      initialPhone: initialPhone,
      initialLocationCoordinates: initialLocationCoordinates,
      initialProfileImageUrl: initialProfileImageUrl,
      initialBusinessImageUrls: initialBusinessImageUrls,
    );

    if (!comparator.hasChanges(
      currentName: _nameController.text,
      currentDescription: _descriptionController.text,
      currentPhone: _phoneController.text,
      currentLocationCoordinates: _locationCoordinates,
      currentProfileImageUrl: _profileImageUrl,
      currentBusinessImageUrls: _businessImages.map((file) => file.path).toList(),
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se han realizado cambios.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? profileImageUrl = _profileImageUrl;
      if (_profileImageFile != null) {
        profileImageUrl = await _profileService.uploadImage(_profileImageFile!, 'profile_images');
      }

      List<String> businessImageUrls = [];
      for (var file in _businessImages) {
        String uploadedUrl = await _profileService.uploadImage(file, 'business_images');
        businessImageUrls.add(uploadedUrl);
      }

      final data = {
        'username': _nameController.text,
        'description': _descriptionController.text,
        'phoneNumber': _phoneController.text,
        'location': _locationCoordinates != null
            ? GeoPoint(_locationCoordinates!.latitude, _locationCoordinates!.longitude)
            : null,
        'role': userRole,
        'email': _email,
        'profileImage': profileImageUrl,
        'businessImages': businessImageUrls,
      };

      await _profileService.updateProfileData(data);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Perfil actualizado con éxito.')),
      );
    } catch (e) {
      print("Error al guardar el perfil: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickProfileImage() async {
    final File? pickedFile = await _imageService.pickImage();
    if (pickedFile != null) {
      setState(() {
        _profileImageFile = pickedFile;
        _profileImageUrl = null;
      });
    }
  }

  Future<void> _pickBusinessImage() async {
    final File? pickedFile = await _imageService.pickImage();
    if (pickedFile != null) {
      setState(() {
        _businessImages.add(pickedFile);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: GestureDetector(
                onTap: _pickProfileImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _profileImageFile != null
                      ? FileImage(_profileImageFile!)
                      : (_profileImageUrl != null ? NetworkImage(_profileImageUrl!) : null),
                  child: _profileImageFile == null && _profileImageUrl == null
                      ? const Icon(Icons.add_a_photo, size: 50)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (userRole == 'Comercio' || userRole == 'Criador')
              BusinessImagesSection(
                mobileImages: _businessImages,
                webImages: _businessImageBytes,
                onAddImage: _pickBusinessImage,
                onDeleteImage: (index) {
                  setState(() {
                    _businessImages.removeAt(index);
                  });
                },
                role: userRole,
              ),
            UserProfileWidget(
              nameController: _nameController,
              descriptionController: _descriptionController,
              phoneController: _phoneController,
              location: _location,
              onLocationChanged: (newLocation) {
                setState(() {
                  _location = newLocation;
                });
              },
              onSave: _saveProfile,
              role: userRole,
              email: _email,
            ),
            if (_isLoading) CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
