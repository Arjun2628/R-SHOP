import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:first_project/functions/functions.dart';
import 'package:first_project/screens/profile/providers/provider_add_profile.dart';
import 'package:first_project/screens/profile/providers/provider_profile_screen.dart';

import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/model_home.dart';
import '../home/home_screen.dart';

class ProfileScreen extends StatefulWidget {
  final dynamic user;

  const ProfileScreen({
    super.key,
    required this.user,
  });

  @override
  // ignore: no_logic_in_create_state
  State<ProfileScreen> createState() => _AddProfileState(
        user: user,
      );
}

class _AddProfileState extends State<ProfileScreen> {
  dynamic user;

  _AddProfileState({
    required this.user,
  });
  late DatabaseReference dbref;

  // String imageUri = '';
  List<String>? location = [];
  Set<Marker> markers = {};

  // String age = '';
  // String userimage = '';
  // String photo = '';

  bool profile = true;
  bool editProfile = false;

  // TextEditingController _nameController = TextEditingController();
  // TextEditingController _ageController = TextEditingController();
  // TextEditingController _phoneController = TextEditingController();
  // TextEditingController _addressController = TextEditingController();

  File? photos;
  bool photoSelected = false;

  final _formKey = GlobalKey<FormState>();

  Future getImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image != null) {
      final phototemp = File(image.path);
      setState(() {
        photos = phototemp;
        photoSelected = true;
      });
    } else {
      return;
    }
  }

  Future addUser(String name, int age, int phone) async {
    await FirebaseFirestore.instance
        .collection('users')
        .add({'name': name, 'age': age, 'phone': phone});
  }

  Future<void> receiveUser() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final data = await firestore.collection('user').get();
    carditems.value.clear();
    for (var document in data.docs) {
      var poductData = CardModel.fromMap(document.data());
      carditems.value.add(poductData);
    }
  }

  double? lat;
  double? log;
  CameraPosition? initialPosition;

  void getLAt() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    var latiLong = await FirebaseFirestore.instance
        .collection('user')
        .doc(auth.currentUser!.uid)
        .get();
    lat = latiLong['latitude'];
    log = latiLong['longitude'];
    initialPosition = CameraPosition(target: LatLng(lat!, log!), zoom: 14.0);
  }

  @override
  void initState() {
    super.initState();

    // dbref = FirebaseDatabase.instance.ref().child('Buy&Sell');
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<ProviderProfileScreen>(context, listen: false)
        .nameController
        .text = user['name'];
    Provider.of<ProviderProfileScreen>(context, listen: false)
        .ageController
        .text = user['age'];
    Provider.of<ProviderProfileScreen>(context, listen: false)
        .phoneController
        .text = user['phone'];
    Provider.of<ProviderProfileScreen>(context, listen: false)
        .addressController
        .text = user['address'];
    Provider.of<ProviderProfileScreen>(context, listen: false).imageUri =
        user['photo'];
    // receiveUser();
    getLAt();

    return Consumer<ProviderProfileScreen>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Add Profile'),
          centerTitle: true,
        ),
        body: SafeArea(
            child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Visibility(
                visible: profile,
                child: Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: CircleAvatar(
                    backgroundColor: Colors.grey.shade300,
                    radius: 60,
                    child: CircleAvatar(
                        radius: 55,
                        backgroundImage: NetworkImage(user['photo'])),
                  ),
                ),
              ),
              Visibility(
                visible: editProfile,
                child: Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: GestureDetector(
                    onTap: () {
                      value.selectPhoto(context);
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.grey.shade300,
                      radius: 60,
                      child: CircleAvatar(
                        radius: 55,
                        backgroundImage: const NetworkImage(
                            'https://www.pngkit.com/png/detail/126-1262807_instagram-default-profile-picture-png.png'),
                        foregroundImage: NetworkImage(user['photo']),
                      ),
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
                    ),
                  ),
                  Visibility(
                    visible: profile,
                    child: Flexible(
                      flex: 1,
                      child: SizedBox(
                        height: 45,
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(50, 10, 50, 10),
                          child: SizedBox(
                              height: double.infinity,
                              width: double.infinity,
                              child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      profile = !profile;
                                      editProfile = !editProfile;
                                    });
                                  },
                                  child: const Text('Edit'))),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: editProfile,
                    child: Flexible(
                      flex: 1,
                      child: SizedBox(
                        height: 45,
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(50, 10, 50, 10),
                          child: SizedBox(
                              height: double.infinity,
                              width: double.infinity,
                              child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      profile = !profile;
                                      editProfile = !editProfile;
                                    });
                                  },
                                  child: const Text('Back'))),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Visibility(
                          visible: editProfile,
                          child: TextFormField(
                            validator: (value) {
                              if (value == '') {
                                return 'Enter name';
                              }
                              return null;
                            },
                            enableSuggestions: true,
                            controller: Provider.of<ProviderProfileScreen>(
                                    context,
                                    listen: false)
                                .nameController,
                            // decoration: InputDecoration(border: InputBorder.none),
                            decoration: const InputDecoration(
                              label: Text('Name'),
                              labelStyle: TextStyle(),

                              // prefixText: 'Name : ',
                            ),
                          ),
                        ),
                        Visibility(
                          visible: profile,
                          child: Column(
                            children: [
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('Name : ${user['name']}',
                                      style: const TextStyle(fontSize: 19))),
                              Divider(
                                thickness: 0.5,
                                color: Colors.grey.shade400,
                              )
                            ],
                          ),
                        ),
                      ],
                    )),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Visibility(
                          visible: editProfile,
                          child: TextFormField(
                            validator: (value) {
                              if (value == '') {
                                return 'Enter age';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                            enableSuggestions: true,
                            controller: Provider.of<ProviderProfileScreen>(
                                    context,
                                    listen: false)
                                .ageController,
                            // decoration: InputDecoration(border: InputBorder.none),
                            decoration: const InputDecoration(
                              label: Text('Age'),
                              labelStyle: TextStyle(),

                              // prefixText: 'Name : ',
                            ),
                          ),
                        ),
                        Visibility(
                          visible: profile,
                          child: Column(
                            children: [
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('Age : ${user['age']}',
                                      style: const TextStyle(fontSize: 19))),
                              Divider(
                                thickness: 0.5,
                                color: Colors.grey.shade400,
                              )
                            ],
                          ),
                        ),
                      ],
                    )),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Visibility(
                        visible: editProfile,
                        child: TextFormField(
                          validator: (value) {
                            if (value == '') {
                              return 'Enter phone';
                            } else if (value!.length != 10) {
                              return 'Enter proper number';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          enableSuggestions: true,
                          controller: Provider.of<ProviderProfileScreen>(
                                  context,
                                  listen: false)
                              .phoneController,
                          // decoration: InputDecoration(border: InputBorder.none),
                          decoration: const InputDecoration(
                            label: Text('Phone :'),
                            labelStyle: TextStyle(),

                            // prefixText: 'Name : ',
                          ),
                        ),
                      ),
                      Visibility(
                        visible: profile,
                        child: Column(
                          children: [
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text('Phone : ${user['phone']}',
                                    style: const TextStyle(fontSize: 19))),
                            Divider(
                              thickness: 0.5,
                              color: Colors.grey.shade400,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Visibility(
                        visible: editProfile,
                        child: TextFormField(
                          validator: (value) {
                            if (value == '') {
                              return 'Enter address';
                            }
                            return null;
                          },
                          maxLines: 6,

                          enableSuggestions: true,
                          controller: Provider.of<ProviderProfileScreen>(
                                  context,
                                  listen: false)
                              .addressController,
                          // decoration: InputDecoration(border: InputBorder.none),
                          decoration: InputDecoration(
                              label: const Text('Address :'),
                              labelStyle: const TextStyle(),
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                width: 0.5,
                              )),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 0.5, color: Colors.grey.shade400))

                              // prefixText: 'Name : ',
                              ),
                        ),
                      ),
                      Visibility(
                          visible: profile,
                          child: Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                    width: 0.5, color: Colors.grey.shade400)),
                            // color: Colors.amber,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Address : \n${user['address']}',
                                style: const TextStyle(fontSize: 19),
                                maxLines: 6,
                              ),
                            ),
                          ))
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: profile,
                child: Row(
                  children: const [
                    Flexible(
                      flex: 1,
                      child: SizedBox(
                        height: 55,
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.only(left: 30),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Location :',
                                  style: TextStyle(fontSize: 19))),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: SizedBox(
                        height: 55,
                        width: double.infinity,
                        // child: Padding(
                        //   padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                        //   child: SizedBox(
                        //       height: double.infinity,
                        //       width: double.infinity,
                        //       child: ElevatedButton(
                        //           onPressed: () async {
                        //             setState(() {
                        //               profile = !profile;
                        //               editProfile = !editProfile;
                        //             });
                        //           },
                        //           child: const Text('Add'))),
                        // ),
                      ),
                    )
                  ],
                ),
              ),
              Visibility(
                visible: profile,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 20, 30, 10),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        border:
                            Border.all(width: 0.5, color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(5)),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                          target: LatLng(user['latitude'], user['longitude']),
                          zoom: 14),
                      markers: markers,
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Visibility(
                    visible: editProfile,
                    child: Flexible(
                      flex: 1,
                      child: SizedBox(
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
                                      if (photoSelected == true) {
                                        await value.cloudAdd(photos!);
                                      }

                                      // if (imageUri == '') {
                                      //   imageUri = userimage;
                                      // }
                                      Map<String, dynamic> users = {
                                        'name': value.nameController.text,
                                        'age': value.ageController.text,
                                        'phone': value.phoneController.text,
                                        'address': value.addressController.text,
                                        'photo': value.imageUri,
                                        'uid': user['uid'],
                                        'latitude': user['latitude'],
                                        'longitude': user['longitude']
                                      };

                                      await value.userDetailes(users);
                                      await value.userDetail();
                                      setState(() {
                                        profile = !profile;
                                        editProfile = !editProfile;
                                      });
                                      carditems.value.clear();
                                      receiveProducts();

                                      // ignore: use_build_context_synchronously
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: ((context) =>
                                                  HomeScreen())));
                                      // Navigator.pop(context);
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
      ),
    );
  }

  // Future<void> userDetailes(Map<String, dynamic> user) async {
  //   final FirebaseAuth auth = FirebaseAuth.instance;
  //   if (auth.currentUser != null) {
  //     final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //     firestore.collection('user').doc(auth.currentUser!.uid).set(user);
  //   }
  // }

  // Future<void> userDetail() async {
  //   final FirebaseAuth auth = FirebaseAuth.instance;
  //   if (auth.currentUser != null) {
  //     final FirebaseFirestore firestore = FirebaseFirestore.instance;
  //     final data =
  //         await firestore.collection('user').doc(auth.currentUser!.uid).get();
  //     age = data['age'];
  //     userimage = data['photo'];

  //     // location = data['location'];

  //   }
  // }

  // Future<void> cloudAdd(File file) async {
  //   final Reference storageref = FirebaseStorage.instance
  //       .ref()
  //       .child('images/${DateTime.now().millisecondsSinceEpoch}');

  //   final UploadTask uploadTask = storageref.putFile(file);
  //   TaskSnapshot snap = await uploadTask;

  //   final String downloadUrl = await snap.ref.getDownloadURL();
  //   imageUri = downloadUrl;
  // }

  // Future<dynamic> selectPhoto() async {
  //   await showModalBottomSheet(
  //       context: context,
  //       builder: ((context) => BottomSheet(
  //           onClosing: () {},
  //           builder: ((context) {
  //             return Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 ListTile(
  //                   leading: const Icon(Icons.camera),
  //                   title: const Text('Camara'),
  //                   onTap: () async {
  //                     Navigator.of(context).pop();
  //                     getImage(ImageSource.camera);
  //                   },
  //                 ),
  //                 ListTile(
  //                   leading: const Icon(Icons.filter),
  //                   title: const Text('Gallary'),
  //                   onTap: () async {
  //                     Navigator.of(context).pop();
  //                     getImage(ImageSource.gallery);
  //                   },
  //                 )
  //               ],
  //             );
  //           }))));
  // }
}
