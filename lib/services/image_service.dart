// image_service.dart

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageService {
  final picker = ImagePicker();

  Future<File?> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

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

  Future<String> uploadImage(File imageFile, String folder) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child(folder)
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  Future<Uint8List?> compressImage(File file) async {
    return await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: 70,
    );
  }
}
