import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:first_project/chatModels/user_model.dart';
import 'package:first_project/functions/firebase_helper.dart';
import 'package:first_project/screens/profile/providers/provider_add_profile.dart';
import 'package:first_project/screens/profile/providers/provider_profile_screen.dart';

import 'package:first_project/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

// ignore: prefer_const_constructors
var uuid = Uuid();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('wishlist1');

  await Firebase.initializeApp();
  User? firebaseUser = FirebaseAuth.instance.currentUser;
  if (firebaseUser != null) {
    UserMOdel? thisUserModel =
        await FirebaseHelper.getUserNameById(firebaseUser.uid);
    if (thisUserModel != null) {
      runApp(MyAppLoggedIn(usermodel: thisUserModel, user: firebaseUser));
    } else {
      runApp(MyApp());
    }
  } else {
    runApp(MyApp());
  }
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  MyApp({super.key});

  Widget? firstWidget;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProviderAddProfile()),
        ChangeNotifierProvider(create: (context) => ProviderProfileScreen())
      ],
      child: MaterialApp(
        home: SplashScreen(chechNumber: 1),
        //  LoginScreen(),
        // firstWidget,
        theme: ThemeData(primaryColor: Colors.lightBlue),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// ignore: must_be_immutable
class MyAppLoggedIn extends StatelessWidget {
  final UserMOdel usermodel;
  final User user;
  MyAppLoggedIn({
    super.key,
    required this.usermodel,
    required this.user,
  });

  Widget? firstWidget;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProviderAddProfile()),
        ChangeNotifierProvider(create: (context) => ProviderProfileScreen())
      ],
      child: MaterialApp(
        home: SplashScreen(
          user: user,
          usermodel: usermodel,
          chechNumber: 2,
        ),
        // LoginScreen(),

        // firstWidget,
        theme: ThemeData(primaryColor: Colors.lightBlue),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
