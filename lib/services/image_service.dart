// image_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageService {
  final picker = ImagePicker();

  // Método para seleccionar una imagen desde la galería
  Future<File?> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  // Método para cargar imágenes como File (usado en dispositivos móviles)
  Future<List<File>> loadImages(List<String> imageUrls) async {
    final List<File> files = [];
    for (String imageUrl in imageUrls) {
      final ref = FirebaseStorage.instance.refFromURL(imageUrl);
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File(filePath);
      await ref.writeToFile(file);
      files.add(file);
    }
    return files;
  }

  // Método para cargar imágenes como Uint8List (usado en la web y para imágenes en memoria)
  Future<List<Uint8List>> loadImagesFromUrls(List<String> imageUrls) async {
    final List<Uint8List> imageBytesList = [];
    for (String imageUrl in imageUrls) {
      try {
        final ref = FirebaseStorage.instance.refFromURL(imageUrl);
        final Uint8List? imageData = await ref.getData();
        if (imageData != null) {
          print('Imagen cargada desde: $imageUrl');
          imageBytesList.add(imageData);
        } else {
          print('No se pudo cargar la imagen: $imageUrl');
        }
      } catch (e) {
        print('Error al cargar imagen desde: $imageUrl');
      }
    }
    return imageBytesList;
  }

  // Método para subir una imagen a Firebase Storage
  Future<String> uploadImage(File imageFile, String folder) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child(folder)
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  // Método para comprimir una imagen
  Future<Uint8List?> compressImage(File file) async {
    return await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: 70,
    );
  }
}
