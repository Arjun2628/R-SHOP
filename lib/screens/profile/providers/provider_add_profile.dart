import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:first_project/chatModels/user_model.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ProviderAddProfile extends ChangeNotifier {
  String imageUri = '';
  String? getUserId;
  double? latitude;
  double? longitude;
  Set<Marker> markers = {};

  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  File? photo;

  Future getImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image != null) {
      final phototemp = File(image.path);

      photo = phototemp;
      notifyListeners();
    } else {
      return;
    }
  }

  Future addUser(String name, int age, int phone) async {
    await FirebaseFirestore.instance
        .collection('users')
        .add({'name': name, 'age': age, 'phone': phone});
  }

  Future<void> userDetailes(UserMOdel user) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      firestore.collection('user').doc(auth.currentUser!.uid).set(user.toMap());
    }
  }

  Future<void> userDetail() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final data =
          await firestore.collection('user').doc(auth.currentUser!.uid).get();
      // ignore: unused_local_variable
      String age = data['age'];
      // print(age);
    }
  }

  Future<void> cloudAdd(File file) async {
    final Reference storageref = FirebaseStorage.instance
        .ref()
        .child('images/${DateTime.now().millisecondsSinceEpoch}');

    final UploadTask uploadTask = storageref.putFile(file);
    TaskSnapshot snap = await uploadTask;

    final String downloadUrl = await snap.ref.getDownloadURL();
    imageUri = downloadUrl;
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
                    title: const Text('Gallery'),
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

  Future<void> getUid() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    getUserId = auth.currentUser!.uid;
    notifyListeners();
  }

  Future<void> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location service is disabled');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      return Future.error('Location permission denied');
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permission is permanantly denied');
    }

    Position position = await Geolocator.getCurrentPosition();

    latitude = position.latitude;
    longitude = position.longitude;

    markers.add(Marker(
        markerId: const MarkerId('currentPosition'),
        position: LatLng(latitude!, longitude!)));
    notifyListeners();
  }
}
