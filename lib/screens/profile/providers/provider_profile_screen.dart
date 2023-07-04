import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProviderProfileScreen extends ChangeNotifier {
  File? photos;
  bool photoSelected = false;
  String age = '';
  String userimage = '';
  String imageUri = '';

  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  Future getImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image != null) {
      final phototemp = File(image.path);
      photos = phototemp;
      photoSelected = true;
      notifyListeners();
    } else {
      return;
    }
  }

  Future<void> userDetailes(Map<String, dynamic> user) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      firestore.collection('user').doc(auth.currentUser!.uid).set(user);
    }
    notifyListeners();
  }

  Future<void> userDetail() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final data =
          await firestore.collection('user').doc(auth.currentUser!.uid).get();
      age = data['age'];
      userimage = data['photo'];

      // location = data['location'];
    }
    notifyListeners();
  }

  Future<void> cloudAdd(File file) async {
    final Reference storageref = FirebaseStorage.instance
        .ref()
        .child('images/${DateTime.now().millisecondsSinceEpoch}');

    final UploadTask uploadTask = storageref.putFile(file);
    TaskSnapshot snap = await uploadTask;

    final String downloadUrl = await snap.ref.getDownloadURL();
    imageUri = downloadUrl;
    notifyListeners();
  }

  Future<dynamic> selectPhoto(BuildContext context) async {
    await showModalBottomSheet(
        context: context,
        builder: ((context) => BottomSheet(
            onClosing: () {},
            builder: ((context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.camera),
                    title: const Text('Camara'),
                    onTap: () async {
                      Navigator.of(context).pop();
                      getImage(ImageSource.camera);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.filter),
                    title: const Text('Gallary'),
                    onTap: () async {
                      Navigator.of(context).pop();
                      getImage(ImageSource.gallery);
                    },
                  )
                ],
              );
            }))));
    notifyListeners();
  }
}
