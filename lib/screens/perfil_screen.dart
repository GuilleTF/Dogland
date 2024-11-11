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
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../../data/tags.dart';
import 'dart:io';

class PerfilScreen extends StatefulWidget {
  final VoidCallback onMisPerrosTapped;

  PerfilScreen({required this.onMisPerrosTapped});

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
  final TextEditingController _locationController = TextEditingController();
  final FocusNode _locationFocusNode = FocusNode();

  String _location = 'Ubicación desconocida';
  String _email = '';
  String? _profileImageUrl;
  File? _profileImageFile;
  List<File> _businessImages = [];
  List<Uint8List> _businessImageBytes = [];
  LatLng? _locationCoordinates;
  bool _isLoading = false;
  String userRole = '';
  List<String> _selectedTags = []; // Lista de etiquetas seleccionadas para comercio

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
        
        // Cargar etiquetas seleccionadas si es Comercio
        if (userRole == 'Comercio' && userDataMap['tags'] != null) {
          _selectedTags = List<String>.from(userDataMap['tags']);
        }

        if (userDataMap['location'] != null) {
          GeoPoint geoPoint = userDataMap['location'];
          _locationCoordinates = LatLng(geoPoint.latitude, geoPoint.longitude);
          _locationController.text = await _locationService.getAddressFromLatLng(_locationCoordinates!);
        } else {
          _locationController.text = _location;
        }

        if (userDataMap['businessImages'] != null) {
          _businessImages = await _imageService.loadImages(List<String>.from(userDataMap['businessImages']));
        }

        initialName = _nameController.text;
        initialDescription = _descriptionController.text;
        initialPhone = _phoneController.text;
        initialLocationCoordinates = _locationCoordinates;
        initialProfileImageUrl = _profileImageUrl;
        initialBusinessImageUrls = List<String>.from(userDataMap['businessImages'] ?? []);
      }
    } catch (e) {
      print("Error al cargar los datos del perfil: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _locationFocusNode.dispose();
    super.dispose();
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
        'tags': userRole == 'Comercio' ? _selectedTags : null, // Actualiza etiquetas
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  GestureDetector(
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
                  const SizedBox(height: 20),

                  if (userRole == 'Comercio')
                    MultiSelectDialogField(
                      items: etiquetasDeComercio.map((tag) => MultiSelectItem(tag, tag)).toList(),
                      title: Text(
                        "Editar etiquetas",
                        style: TextStyle(color: Colors.black),
                      ),
                      selectedColor: Colors.blue,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                        ),
                      ),
                      buttonText: Text(
                        "Etiquetas",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      onConfirm: (results) {
                        setState(() {
                          _selectedTags = results.cast<String>();
                        });
                      },
                      initialValue: _selectedTags,
                    ),
                  const SizedBox(height: 20),

                  if (userRole == 'Criador')
                    ElevatedButton(
                      onPressed: widget.onMisPerrosTapped,
                      child: Text('MIS PERROS'),
                    ),

                  const SizedBox(height: 20),

                  UserProfileWidget(
                    nameController: _nameController,
                    descriptionController: _descriptionController,
                    phoneController: _phoneController,
                    locationController: _locationController,
                    locationFocusNode: _locationFocusNode,
                    onLocationSelected: (coordinates) {
                      setState(() {
                        _locationCoordinates = coordinates;
                      });
                    },
                    onSave: _saveProfile,
                    role: userRole,
                    email: _email,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
