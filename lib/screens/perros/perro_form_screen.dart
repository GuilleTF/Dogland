import 'dart:io';
import 'dart:typed_data';  
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:dogland/services/image_service.dart';
import 'package:dogland/widgets/business_images_section.dart';

class PerroFormScreen extends StatefulWidget {
  final Map<String, dynamic>? perro;
  final VoidCallback onPerroGuardado;

  PerroFormScreen({this.perro, required this.onPerroGuardado});

  @override
  _PerroFormScreenState createState() => _PerroFormScreenState();
}

class _PerroFormScreenState extends State<PerroFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final ImageService _imageService = ImageService();

  String _raza = '';
  String _genero = 'Macho';
  double _precio = 0.0;
  String _descripcion = '';
  List<File> _perroImages = [];  // Para imágenes locales
  List<Uint8List> _perroImageBytes = [];  // Para imágenes descargadas
  List<String> _perroImageUrls = [];  // Para URLs de imágenes guardadas
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.perro != null) {
      _raza = widget.perro!['raza'];
      _genero = widget.perro!['genero'];
      _precio = widget.perro!['precio'];
      _descripcion = widget.perro!['descripcion'];
      _perroImageUrls = List<String>.from(widget.perro!['images'] ?? []);
      _loadPerroImages();  // Cargar las imágenes guardadas
    }
  }

  Future<void> _loadPerroImages() async {
    setState(() => _isLoading = true);
    try {
      print('Cargando imágenes: $_perroImageUrls');
      _perroImageBytes = await _imageService.loadImagesFromUrls(_perroImageUrls);
      setState(() {});
    } catch (e) {
      print("Error al cargar las imágenes: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _savePerro() async {
    if (_formKey.currentState!.saveAndValidate()) {
      final formData = _formKey.currentState?.value;

      List<String> uploadedImageUrls = [];
      try {
        for (var image in _perroImages) {
          String imageUrl = await _imageService.uploadImage(image, 'perros_images');
          uploadedImageUrls.add(imageUrl);
        }

        uploadedImageUrls.addAll(_perroImageUrls);

        String userId = FirebaseAuth.instance.currentUser!.uid;
        Map<String, dynamic> perroData = {
          'raza': formData!['raza'],
          'genero': formData['genero'],
          'precio': formData['precio'],
          'descripcion': formData['descripcion'],
          'images': uploadedImageUrls,
          'userId': userId,
        };

        if (widget.perro == null) {
          await FirebaseFirestore.instance.collection('perros').add(perroData);
        } else {
          await FirebaseFirestore.instance.collection('perros').doc(widget.perro!['id']).update(perroData);
        }

        widget.onPerroGuardado();
      } catch (e) {
        print("Error subiendo las imágenes: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error subiendo imágenes, por favor inténtalo de nuevo.'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: FormBuilder(
                      key: _formKey,
                      child: ListView(
                        children: [
                          FormBuilderTextField(
                            name: 'raza',
                            initialValue: _raza,
                            decoration: InputDecoration(labelText: 'Raza'),
                            validator: FormBuilderValidators.required(),
                          ),
                          FormBuilderDropdown<String>(
                            name: 'genero',
                            initialValue: _genero,
                            decoration: InputDecoration(labelText: 'Género'),
                            items: ['Macho', 'Hembra']
                                .map((genero) => DropdownMenuItem(
                                      value: genero,
                                      child: Text(genero),
                                    ))
                                .toList(),
                            validator: FormBuilderValidators.required(),
                          ),
                          FormBuilderTextField(
                            name: 'precio',
                            initialValue: _precio.toString(),
                            decoration: InputDecoration(labelText: 'Precio'),
                            keyboardType: TextInputType.number,
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              FormBuilderValidators.numeric(),
                            ]),
                          ),
                          FormBuilderTextField(
                            name: 'descripcion',
                            initialValue: _descripcion,
                            decoration: InputDecoration(labelText: 'Descripción'),
                            validator: FormBuilderValidators.required(),
                          ),
                          const SizedBox(height: 20),

                          // Sección de imágenes
                          BusinessImagesSection(
                            mobileImages: _perroImages,
                            webImages: _perroImageBytes,
                            onAddImage: _pickImage,
                            onDeleteImage: (index) {
                              setState(() {
                                if (index < _perroImages.length) {
                                  _perroImages.removeAt(index);
                                } else {
                                  int webIndex = index - _perroImages.length;
                                  _perroImageBytes.removeAt(webIndex);
                                  _perroImageUrls.removeAt(webIndex);
                                }
                              });
                            },
                            role: 'Perro',
                          ),
                        ],
                      ),
                    ),
                  ),

                  ElevatedButton(
                    onPressed: _savePerro,
                    child: Text('Guardar'),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _pickImage() async {
    final File? pickedImage = await _imageService.pickImage();
    if (pickedImage != null) {
      setState(() {
        _perroImages.add(pickedImage);
      });
    }
  }
}
