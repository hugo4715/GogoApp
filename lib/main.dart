import 'package:flutter/material.dart';
import 'package:gogo_app/data/analytics.dart';
import 'package:gogo_app/data/updater.dart';
import 'package:gogo_app/page/animepage.dart';
import 'package:gogo_app/page/homepage.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:gogo_app/page/updatepage.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'data/user.dart';
import 'page/loginpage.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  UpdateInfo? update;
  try{
    update = await checkUpdates();
    if(update != null){
      print("Found update " + update.version.toString() + " with link " + update.url);
    }else{
      print("App seems up to date");
    }
  }catch(e){
    print("Could not check for updates: " + e.toString());
  }

  FlutterDownloader.initialize(debug: true)
      .then((value) => FlutterDownloader.loadTasks());
  try{
    await User.getCachedUser();
  }catch(e){}

  runApp(GogoApp(update));
}

class GogoApp extends StatelessWidget {
  UpdateInfo? update;

  GogoApp(this.update, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    initMixpanel();

    var initialRoute;
    if(update != null)initialRoute = '/update';
    else if(userLoaded)initialRoute = '/home';
    else initialRoute = '/login';

    return MaterialApp(
      title: 'GogoApp',
      initialRoute: initialRoute,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/home': (ctx) => const HomePage(),
        '/login': (ctx) => const LoginPage(),
        '/update': (ctx) => UpdatePage(update),
      },
      onGenerateRoute: (settings){
        if(settings.name == AnimePage.route){
          final args = settings.arguments as AnimePageArguments;
          return MaterialPageRoute(
            builder: (context) {
              return AnimePage(
                animeId: args.animeId,
              );
            },
          );
        }
      },
    );
  }
}

