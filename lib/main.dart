import 'package:flutter/material.dart';
import 'package:gogo_app/animepage.dart';

import 'homepage.dart';
import 'loginpage.dart';

void main() {
  runApp(const GogoApp());
}

class GogoApp extends StatelessWidget {
  const GogoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GogoApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}

