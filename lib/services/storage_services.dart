import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';


class StorageServices {
  StorageServices._();

  static StorageServices storageServices = StorageServices._();

  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future<String> uploadImageToStorage() async {
    try {
      XFile? xFile = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (xFile != null) {
        final reference = _firebaseStorage.ref();
        final imageReference = reference.child("images/${xFile.name}");
        await imageReference.putFile(File(xFile.path));
        return await imageReference.getDownloadURL();
      } else {
        throw Exception('No image selected');
      }
    } catch (e) {
      // Handle any errors
      print("Error uploading image: $e");
      return '';
    }
  }
}