import 'package:cloud_firestore/cloud_firestore.dart';
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
  List<String> _businessImageUrls = [];
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
        _businessImageUrls = List<String>.from(userDataMap?['businessImages'] ?? []);
      
        // Guardar valores iniciales
        initialName = _nameController.text;
        initialDescription = _descriptionController.text;
        initialPhone = _phoneController.text;
        initialLocationCoordinates = _locationCoordinates;
        initialProfileImageUrl = _profileImageUrl;
        initialBusinessImageUrls = List<String>.from(_businessImageUrls);
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

    // Verifica si no hubo cambios
    if (!comparator.hasChanges(
      currentName: _nameController.text,
      currentDescription: _descriptionController.text,
      currentPhone: _phoneController.text,
      currentLocationCoordinates: _locationCoordinates,
      currentProfileImageUrl: _profileImageUrl,
      currentBusinessImageUrls: _businessImageUrls,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se han realizado cambios.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      String? profileImageUrl;
      List<String> businessImageUrls = [];

      if (_profileImageUrl != null) {
        profileImageUrl = await _uploadImage(File(_profileImageUrl!), 'profile_images');
      }

      for (var imageUrl in _businessImageUrls) {
        String uploadedImageUrl = await _uploadImage(File(imageUrl), 'business_images');
        businessImageUrls.add(uploadedImageUrl);
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
      print("Perfil actualizado");
    } catch (e) {
      print("Error al guardar el perfil: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String> _uploadImage(File imageFile, String folder) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child(folder)
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  Future<void> _pickProfileImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final compressedImage = await _compressImage(File(pickedFile.path));
      setState(() => _profileImageUrl = compressedImage.path);
    }
  }

  Future<void> _pickBusinessImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final compressedImage = await _compressImage(File(pickedFile.path));
      setState(() => _businessImageUrls.add(compressedImage.path));
    }
  }

  Future<File> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = path.join(dir.absolute.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 85,
    );

    return result != null ? File(result.path) : file;
  }

    Future<void> _deleteBusinessImage(String imageUrl) async {
    setState(() => _isLoading = true);
    try {
      // Eliminar la imagen de Firebase Storage
      await _profileService.deleteImage(imageUrl);

      // Remover la URL de la lista local y actualizar Firestore
      setState(() {
        _businessImageUrls.remove(imageUrl);
      });
      await _profileService.updateProfileData({
        'businessImages': _businessImageUrls,
      });

      print("Imagen eliminada");
    } catch (e) {
      print("Error al eliminar la imagen: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20), // Ajusta el valor del margen superior
              child: GestureDetector(
                onTap: _pickProfileImage,
                child: CircleAvatar(
                  radius: 60, // Tamaño ajustado para una foto de perfil más grande
                  backgroundImage: _profileImageUrl != null ? NetworkImage(_profileImageUrl!) : null,
                  child: _profileImageUrl == null ? const Icon(Icons.add_a_photo, size: 50) : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (userRole == 'Comercio' || userRole == 'Criador')
              Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: BusinessImagesSection(
                      imageUrls: _businessImageUrls,
                      onAddImage: _pickBusinessImage,
                      onDeleteImage: _deleteBusinessImage,
                      role: userRole,
                    ),
                  ),
              UserProfileWidget(
                nameController: _nameController,
                descriptionController: TextEditingController(text: userRole != 'Usuario' ? _descriptionController.text : ''),
                phoneController: _phoneController,
                location: userRole != 'Usuario' ? _location : '',
                onLocationChanged: (value) => setState(() => _location = value),
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
