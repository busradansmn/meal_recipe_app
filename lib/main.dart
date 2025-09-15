import 'package:flutter/material.dart';
import 'package:tadinda/screens/homeScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meal App',
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: const MainScreen(),
    );
  }
}
