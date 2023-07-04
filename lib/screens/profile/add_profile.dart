import 'dart:io';

import 'package:firebase_database/firebase_database.dart';

import 'package:first_project/chatModels/user_model.dart';
import 'package:first_project/screens/home/home_screen.dart';
import 'package:first_project/screens/profile/providers/provider_add_profile.dart';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:provider/provider.dart';

class AddProfile extends StatefulWidget {
  const AddProfile({
    super.key,
  });

  @override
  State<AddProfile> createState() => _AddProfileState();
}

class _AddProfileState extends State<AddProfile> {
  late DatabaseReference dbref;

  late GoogleMapController googleMapController;

  final _formKey = GlobalKey<FormState>();

  LatLng latLngUser = const LatLng(11.4429, 75.6976);

  List<String> location = [];

  static const CameraPosition initialPosition =
      CameraPosition(target: LatLng(11.4429, 75.6976), zoom: 14.0);

  ProviderAddProfile addProfile = ProviderAddProfile();
  String? getUserId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Profile'),
        centerTitle: true,
      ),
      body: SafeArea(
          child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Consumer<ProviderAddProfile>(
                builder: (context, value, child) => GestureDetector(
                  onTap: () {
                    value.selectPhoto(context);
                  },
                  child: value.photo == null
                      ? CircleAvatar(
                          backgroundColor: Colors.grey.shade300,
                          radius: 60,
                          child: const CircleAvatar(
                              radius: 55,
                              backgroundImage: AssetImage(
                                  'lib/assets/images/addProfile.png')),
                        )
                      : CircleAvatar(
                          backgroundColor: Colors.grey.shade300,
                          radius: 60,
                          child: CircleAvatar(
                            radius: 55,
                            backgroundImage: FileImage(File(value.photo!.path)),
                          ),
                        ),
                ),
              ),
            ),
            Consumer<ProviderAddProfile>(
              builder: (context, providerAdd, child) => Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    validator: (value) {
                      if (value == '') {
                        return 'Enter name';
                      } else if (value!.length < 2) {
                        return 'minimum 2 characters';
                      } else if (value.length > 10) {
                        return 'maximum 10 characters';
                      }
                      return null;
                    },
                    enableSuggestions: true,
                    controller: providerAdd.nameController,
                    decoration: const InputDecoration(
                      label: Text('Name :'),
                      labelStyle: TextStyle(),
                    ),
                  ),
                ),
              ),
            ),
            Consumer<ProviderAddProfile>(
              builder: (context, profileAdd, child) => Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    validator: (value) {
                      if (value == '') {
                        return 'Enter age';
                      } else if (int.parse(value!) > 110 ||
                          int.parse(value) < 15) {
                        return 'Age between 15-110';
                      } else if (value.length > 10) {
                        return 'maximum 10 characters';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    enableSuggestions: true,
                    controller: profileAdd.ageController,
                    decoration: const InputDecoration(
                      label: Text('Age :'),
                      labelStyle: TextStyle(),
                    ),
                  ),
                ),
              ),
            ),
            Consumer<ProviderAddProfile>(
              builder: (context, profileAdd, child) => Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    validator: (value) {
                      if (value == '') {
                        return 'Enter phone number';
                      } else if (value!.length != 10) {
                        return 'Enter valid phone number';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    enableSuggestions: true,
                    controller: profileAdd.phoneController,
                    decoration: const InputDecoration(
                      label: Text('Phone :'),
                      labelStyle: TextStyle(),
                    ),
                  ),
                ),
              ),
            ),
            Consumer<ProviderAddProfile>(
              builder: (context, profileAdd, child) => Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    validator: (value) {
                      if (value == '') {
                        return 'Enter address';
                      }
                      return null;
                    },
                    maxLines: 6,
                    enableSuggestions: true,
                    controller: profileAdd.addressController,
                    decoration: InputDecoration(
                        label: const Text('Address :'),
                        labelStyle: const TextStyle(),
                        focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(width: 0.5)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 0.5, color: Colors.grey.shade400))),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                const Flexible(
                  flex: 1,
                  child: SizedBox(
                    height: 55,
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.only(left: 30),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Add Location')),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Consumer<ProviderAddProfile>(
                    builder: (context, value, child) => SizedBox(
                      height: 55,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                        child: SizedBox(
                            height: double.infinity,
                            width: double.infinity,
                            child: ElevatedButton(
                                onPressed: () async {
                                  await Provider.of<ProviderAddProfile>(context,
                                          listen: false)
                                      .determinePosition();
                                  googleMapController.animateCamera(
                                      CameraUpdate.newCameraPosition(
                                          CameraPosition(
                                              target: LatLng(value.latitude!,
                                                  value.longitude!),
                                              zoom: 14)));

                                  value.markers.clear();
                                },
                                child: const Text('Add'))),
                      ),
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 20, 30, 10),
              child: Consumer<ProviderAddProfile>(
                builder: (context, value, child) => Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      border:
                          Border.all(width: 0.5, color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(5)),
                  child: GoogleMap(
                    initialCameraPosition: initialPosition,
                    markers: value.markers,
                    zoomControlsEnabled: false,
                    mapType: MapType.normal,
                    onMapCreated: (controller) {
                      googleMapController = controller;
                    },
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Flexible(
                  flex: 1,
                  child: Consumer<ProviderAddProfile>(
                    builder: (context, value, child) => SizedBox(
                      height: 55,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                        child: SizedBox(
                            height: double.infinity,
                            width: double.infinity,
                            child: ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    await value.cloudAdd(value.photo!);

                                    await addProfile.getUid();
                                    UserMOdel users = UserMOdel(
                                        age: value.ageController.text,
                                        name: value.nameController.text,
                                        phone: value.phoneController.text,
                                        photo: value.imageUri,
                                        uid: getUserId,
                                        address: value.addressController.text,
                                        latitude: value.latitude,
                                        longitude: value.longitude);

                                    value.userDetailes(users);
                                    value.userDetail();

                                    // ignore: use_build_context_synchronously
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: ((context) =>
                                                HomeScreen())),
                                        (route) => false);
                                  }
                                },
                                child: const Text('Submit'))),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      )),
    );
  }
}
