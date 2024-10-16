import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:dogland/services/profile_service.dart';
import 'package:dogland/widgets/business_images_section.dart';
import 'package:dogland/widgets/user_profile_widget.dart';
import 'package:dogland/utils/profile_comparator.dart';

class PerfilScreen extends StatefulWidget {
  final String role;

  PerfilScreen({required this.role});

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _location = 'Ubicación desconocida';
  String _email = '';
  String? _profileImageUrl;
  File? _profileImageFile;  // Nueva variable para manejar el archivo de perfil
  List<File> _businessImages = [];
  List<Uint8List> _businessImageBytes = [];
  LatLng? _locationCoordinates;
  bool _isLoading = false;
  final ProfileService _profileService = ProfileService();
  final picker = ImagePicker();
  String userRole = '';

  // Valores iniciales para saber si hubo cambios
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
    try {
      DocumentSnapshot userData = await _profileService.getUserData();
      final userDataMap = userData.data() as Map<String, dynamic>?;

      setState(() {
        _nameController.text = userDataMap?['username'] ?? '';
        _descriptionController.text = userDataMap?['description'] ?? '';
        _phoneController.text = userDataMap?['phoneNumber'] ?? '';
        _email = userDataMap?['email'] ?? '';
        userRole = userDataMap?['role'] ?? '';
        _profileImageUrl = userDataMap?['profileImage'];
        _businessImages = [];
        _businessImageBytes = [];

        // Cargar imágenes del negocio
        if (userDataMap?['businessImages'] != null) {
          _loadBusinessImages(List<String>.from(userDataMap!['businessImages']));
        }

        initialName = _nameController.text;
        initialDescription = _descriptionController.text;
        initialPhone = _phoneController.text;
        initialLocationCoordinates = _locationCoordinates;
        initialProfileImageUrl = _profileImageUrl;
        initialBusinessImageUrls = List<String>.from(userDataMap?['businessImages'] ?? []);
      });

      if (userDataMap?['location'] != null) {
        GeoPoint geoPoint = userDataMap!['location'];
        _locationCoordinates = LatLng(geoPoint.latitude, geoPoint.longitude);
        String address = await _getAddressFromLatLng(_locationCoordinates!);
        setState(() {
          _location = address;
        });
      }
    } catch (e) {
      print("Error al cargar los datos: $e");
    }
  }

  Future<void> _loadBusinessImages(List<String> imageUrls) async {
    try {
      for (String imageUrl in imageUrls) {
        if (kIsWeb) {
          final ref = FirebaseStorage.instance.refFromURL(imageUrl);
          final data = await ref.getData();
          if (data != null) {
            setState(() {
              _businessImageBytes.add(data);
            });
          }
        } else {
          final ref = FirebaseStorage.instance.refFromURL(imageUrl);
          final dir = await getTemporaryDirectory();
          final filePath = path.join(dir.absolute.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');
          final file = File(filePath);
          await ref.writeToFile(file);
          setState(() {
            _businessImages.add(file);
          });
        }
      }
    } catch (e) {
      print('Error al cargar las imágenes de negocio: $e');
    }
  }

  Future<String> _getAddressFromLatLng(LatLng coordinates) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        coordinates.latitude,
        coordinates.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return "${place.street}, ${place.locality}, ${place.country}";
      }
    } catch (e) {
      print('Error al obtener la dirección: $e');
    }
    return 'Ubicación desconocida';
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

    // Check for changes
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
      // Actualiza la imagen de perfil si hay cambios
      String? profileImageUrl = _profileImageUrl;
      if (_profileImageFile != null) {
        profileImageUrl = await _uploadImage(_profileImageFile!, 'profile_images');
      }

      // Subir las imágenes del negocio
      List<String> businessImageUrls = [];
      for (var file in _businessImages) {
        String uploadedUrl = await _uploadImage(file, 'business_images');
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

  Future<String> _uploadImage(File imageFile, String folder) async {
    if (!imageFile.existsSync()) {
      return Future.error("El archivo no existe.");
    }

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child(folder)
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error al subir la imagen: $e");
      throw e;
    }
  }

  // Método para elegir la imagen de perfil
  Future<void> _pickProfileImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImageFile = File(pickedFile.path);
        _profileImageUrl = null; // Se anula la URL para refrescar la imagen localmente
      });
    }
  }

  // Método para elegir las imágenes de negocio
  Future<void> _pickBusinessImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _businessImageBytes.add(bytes);
        });
      } else {
        final file = File(pickedFile.path);
        setState(() {
          _businessImages.add(file);
        });
      }
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
                    if (kIsWeb) {
                      _businessImageBytes.removeAt(index);
                    } else {
                      _businessImages.removeAt(index);
                    }
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
