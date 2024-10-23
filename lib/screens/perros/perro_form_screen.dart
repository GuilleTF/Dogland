import 'dart:io';
import 'dart:typed_data';  
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dogland/widgets/business_images_section.dart';
import 'package:dogland/services/image_service.dart';  

class PerroFormScreen extends StatefulWidget {
  final Map<String, dynamic>? perro;
  final VoidCallback onPerroGuardado;

  PerroFormScreen({this.perro, required this.onPerroGuardado});

  @override
  _PerroFormScreenState createState() => _PerroFormScreenState();
}

class _PerroFormScreenState extends State<PerroFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String _raza = '';
  String _genero = 'Macho';
  double _precio = 0.0;
  String _descripcion = '';
  List<File> _perroImages = [];  // Para imágenes locales
  List<Uint8List> _perroImageBytes = [];  // Para imágenes descargadas
  List<String> _perroImageUrls = [];  // Para URLs de imágenes guardadas
  final ImageService _imageService = ImageService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.perro != null) {
      // Inicializar los datos del perro si estamos editando
      _raza = widget.perro!['raza'];
      _genero = widget.perro!['genero'];
      _precio = widget.perro!['precio'];
      _descripcion = widget.perro!['descripcion'];

      // Cargar URLs de imágenes guardadas en Firebase
      if (widget.perro!['images'] != null) {
        _perroImageUrls = List<String>.from(widget.perro!['images']);
        _loadPerroImages();  // Cargar las imágenes desde Firebase
      }
    }
  }

  // Método para cargar las imágenes desde Firebase
  Future<void> _loadPerroImages() async {
    setState(() {
      _isLoading = true; // Indicar que se está cargando
    });

    try {
      print('Cargando imágenes: $_perroImageUrls');
      _perroImageBytes = await _imageService.loadImagesFromUrls(_perroImageUrls);
      setState(() {});
    } catch (e) {
      print("Error al cargar las imágenes: $e");
    } finally {
      setState(() {
        _isLoading = false; // Carga completada
      });
    }
  }

  void _savePerro() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      List<String> uploadedImageUrls = [];
      try {
        // Subir imágenes locales seleccionadas
        for (var image in _perroImages) {
          String imageUrl = await _imageService.uploadImage(image, 'perros_images');
          uploadedImageUrls.add(imageUrl);
        }

        // Mantener las imágenes ya almacenadas
        uploadedImageUrls.addAll(_perroImageUrls);

        // Obtiene el userId del usuario autenticado
        String userId = FirebaseAuth.instance.currentUser!.uid;

        // Datos del perro
        Map<String, dynamic> perroData = {
          'raza': _raza,
          'genero': _genero,
          'precio': _precio,
          'descripcion': _descripcion,
          'images': uploadedImageUrls,  // Guardar las URLs de las imágenes
          'userId': userId,
        };

        // Guardar o actualizar el perro en Firestore
        if (widget.perro == null) {
          await FirebaseFirestore.instance.collection('perros').add(perroData);
        } else {
          await FirebaseFirestore.instance.collection('perros').doc(widget.perro!['id']).update(perroData);
        }

        // Indicar que el perro fue guardado correctamente
        widget.onPerroGuardado();
      } catch (e) {
        print("Error subiendo la imagen: $e");
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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Campos de texto para raza, género, precio y descripción
              TextFormField(
                initialValue: _raza,
                decoration: InputDecoration(labelText: 'Raza'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la raza';
                  }
                  return null;
                },
                onSaved: (value) => _raza = value!,
              ),
              DropdownButtonFormField<String>(
                value: _genero,
                decoration: InputDecoration(labelText: 'Género'),
                items: ['Macho', 'Hembra'].map((String genero) {
                  return DropdownMenuItem(
                    value: genero,
                    child: Text(genero),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _genero = value!;
                  });
                },
              ),
              TextFormField(
                initialValue: _precio.toString(),
                decoration: InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Por favor ingresa un precio válido';
                  }
                  return null;
                },
                onSaved: (value) => _precio = double.parse(value!),
              ),
              TextFormField(
                initialValue: _descripcion,
                decoration: InputDecoration(labelText: 'Descripción'),
                onSaved: (value) => _descripcion = value!,
              ),
              SizedBox(height: 20),

              // Sección de imágenes
              BusinessImagesSection(
                mobileImages: _perroImages,  // Lista de imágenes locales
                webImages: _perroImageBytes,  // Lista de imágenes descargadas en formato Uint8List
                onAddImage: _pickImage,  // Método para seleccionar nuevas imágenes
                onDeleteImage: (index) {
                  setState(() {
                    if (index < _perroImages.length) {
                      _perroImages.removeAt(index);  // Eliminar imagen local
                    } else {
                      _perroImageBytes.removeAt(index - _perroImages.length);  // Eliminar imagen descargada
                      _perroImageUrls.removeAt(index - _perroImages.length); // También eliminar la URL
                    }
                  });
                },
                role: 'Perro',
              ),

              // Botón de guardar
              ElevatedButton(
                onPressed: _savePerro,
                child: Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método para seleccionar nuevas imágenes locales
  Future<void> _pickImage() async {
    final File? pickedImage = await _imageService.pickImage();
    if (pickedImage != null) {
      setState(() {
        _perroImages.add(pickedImage);
      });
    }
  }
}
