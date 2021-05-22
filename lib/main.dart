import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:profile_upgrade/login_page.dart';
import 'package:profile_upgrade/profile.dart';
import 'package:profile_upgrade/signup_page.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      routes: {
        '/signupPage':(BuildContext context)=>SignupPage(),
        '/loginPage':(BuildContext)=>LoginPage(),
        '/profilePage':(BuildContext context)=>ProfilePage(),
      },
    );
  }
}
