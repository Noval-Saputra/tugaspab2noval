import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tugaspab2noval/firebase_options.dart';
import 'package:tugaspab2noval/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Catatan Kuliah',
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
