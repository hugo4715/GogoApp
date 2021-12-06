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
      initialRoute: '/login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/home': (ctx) => const HomePage(),
        '/login': (ctx) => const LoginPage(),
      },
      onGenerateRoute: (settings){
        if(settings.name == AnimePage.route){
          final args = settings.arguments as AnimePageArguments;
          return MaterialPageRoute(
            builder: (context) {
              return AnimePage(
                animeId: args.animeId,
                user: args.user,
              );
            },
          );
        }
      },
    );
  }
}

