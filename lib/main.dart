import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:herodydemo/screens/onboarding.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Hemody",
      home: OnboardingScreen(),
    );
  }
}