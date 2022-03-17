import 'package:flutter/material.dart';
import 'package:gogo_app/data/analytics.dart';
import 'package:gogo_app/page/animepage.dart';
import 'package:gogo_app/page/homepage.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'page/loginpage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterDownloader.initialize(debug: true)
      .then((value) => FlutterDownloader.loadTasks());

  runApp(const GogoApp());
}

class GogoApp extends StatelessWidget {
  const GogoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    initMixpanel();
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

