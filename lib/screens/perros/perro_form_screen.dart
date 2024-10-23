import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dogland/widgets/business_images_section.dart';
import 'package:dogland/services/image_service.dart';  // Servicio para cargar imágenes

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
  List<File> _perroImages = [];
  final ImageService _imageService = ImageService();  // Servicio para cargar imágenes

  @override
  void initState() {
    super.initState();
    if (widget.perro != null) {
      _raza = widget.perro!['raza'];
      _genero = widget.perro!['genero'];
      _precio = widget.perro!['precio'];
      _descripcion = widget.perro!['descripcion'];
      // Aquí deberíamos inicializar las imágenes si el perro ya tiene fotos
    }
  }

  void _savePerro() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Aquí puedes subir las imágenes seleccionadas a Firestore antes de guardar el perro
      List<String> uploadedImageUrls = [];
      try {
        // Aquí puedes subir las imágenes seleccionadas a Firebase antes de guardar el perro
        for (var image in _perroImages) {
          String imageUrl = await _imageService.uploadImage(image, 'perros_images');
          uploadedImageUrls.add(imageUrl);
        }
        
        // Obtiene el userId del usuario autenticado
        String userId = FirebaseAuth.instance.currentUser!.uid;

        // Después de subir las imágenes, guardamos el resto de los datos del perro
        Map<String, dynamic> perroData = {
          'raza': _raza,
          'genero': _genero,
          'precio': _precio,
          'descripcion': _descripcion,
          'images': uploadedImageUrls,  // Guardamos las URLs de las imágenes en Firestore
          'userId': userId, 
        };

        if (widget.perro == null) {
          await FirebaseFirestore.instance.collection('perros').add(perroData);
        } else {
          await FirebaseFirestore.instance.collection('perros').doc(widget.perro!['id']).update(perroData);
        }

        // Cambiar el índice de navegación en lugar de hacer pop()
        widget.onPerroGuardado();

      } catch (e) {
        // Manejo de errores si algo sale mal durante la subida de las imágenes
        print("Error subiendo la imagen: $e");

        // Aquí puedes mostrar un mensaje de error al usuario
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error subiendo imágenes, por favor inténtalo de nuevo.'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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

              // Widget de selección de imágenes reutilizado
              BusinessImagesSection(
                mobileImages: _perroImages,  // Lista de imágenes seleccionadas
                webImages: [],  // Si se usaran imágenes en web
                onAddImage: _pickImage,  // Método para seleccionar imágenes
                onDeleteImage: (index) {
                  setState(() {
                    _perroImages.removeAt(index);  // Elimina la imagen seleccionada
                  });
                },
                role: 'Perro',  // Este valor es indiferente aquí, pero debe estar presente
              ),

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

  Future<void> _pickImage() async {
    final File? pickedImage = await _imageService.pickImage();
    if (pickedImage != null) {
      setState(() {
        _perroImages.add(pickedImage);
      });
    }
  }
}
