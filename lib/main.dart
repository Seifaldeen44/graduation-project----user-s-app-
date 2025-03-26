import 'package:finalproj/auth/otp.dart';
import 'package:finalproj/auth/phoneauth.dart'; // Import the phone authentication page
import 'package:finalproj/getstarted.dart';
import 'package:finalproj/lines.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FirebaseAuth.instance.currentUser == null
          ? GetStartedScreen() // Show phone authentication page if not logged in
          : HomePage(),  // Show home page if logged in
      routes: {
        "Home": (context) => HomePage(),
        "Phoneauth": (context) => PhoneAuthPage(),
        "getstarted": (context) => GetStartedScreen(),// Make sure the PhoneAuth route is set
        "Otp": (context) => OtpVerificationPage(verificationId: '',),
        "Lines": (context) => Lines(),

      },
    );
  }
}
