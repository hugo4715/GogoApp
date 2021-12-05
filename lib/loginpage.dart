import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gogo_app/settings.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart';

import 'data/user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final storage = const FlutterSecureStorage();


  bool canType = true;
  final loginField = TextEditingController();
  final passwordField = TextEditingController();

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return Scaffold(
        appBar: AppBar(
          title: const Text('GogoApp'),
        ),
        body: Container(
          height: double.infinity,
          padding: const EdgeInsets.all(30),
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(50),
                  child: Column(
                    children: [
                      Image.asset('assets/logo.png'),
                      const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text('Unofficial Mobile App', style: TextStyle(color: Color.fromARGB(100, 0, 0, 0)),),
                      )
                    ],
                  ),
                ),
                TextFormField(
                  controller: loginField,
                  decoration: const InputDecoration(
                      labelText: 'GogoAnime username'
                  ),
                ),
                TextFormField(
                  controller: passwordField,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: 'Password'
                  ),
                ),
                ElevatedButton(onPressed: canType ? loginButton : null, child: canType ? const Text('Login') : const CircularProgressIndicator())
              ],
            ),
          ),
        )
    );
  }

  void loginButton() async{
    var username = loginField.text;
    var password = passwordField.text;
    if(password.isNotEmpty && username.isNotEmpty){
      setState(() {
        canType = false;
      });
      Future<User> futureUser = login(username, password);
      futureUser.then(postLogin, onError: errorLogin);
    }
  }

  void postLogin(User user){
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Logged in'),
        content: const Text("Success!"),
        actions: [
          ElevatedButton(
              onPressed: (){Navigator.of(context).pop();}
              , child: const Text('Close')
          )
        ],
      ),
    ).then((value) => {
      setState(() {
        canType = true;
      })
    });
  }

  void errorLogin(var error){
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Error'),
        content: Text(error.toString()),
        actions: [
          ElevatedButton(
              onPressed: (){Navigator.of(context).pop();}
              , child: const Text('Close')
          )
        ],
      ),
    ).then((value) => {
      setState(() {
        canType = true;
      })
    });
  }

  Future<User> login(String email, String password) async{
    print(email);
    print(password);
    var url = Uri.parse(gogoDomain + '/login.html');
    var resp = await http.get(url);
    if(resp.statusCode >= 200 && resp.statusCode < 300){
      var doc = html_parser.parseFragment(resp.body);
      var tokenEl = doc.querySelector('meta[name="csrf-token"]');
      if(tokenEl == null)return Future.error('Could not parse login page html! (csrf not found)');

      var csrf = tokenEl.attributes['content'];
      print(csrf);
      var data = <String,String>{};
      data['_csrf'] = csrf!;
      data['email'] = email;
      data['password'] = password;
      resp = await http.post(url, headers: {
        'accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
        'accept-encoding': 'gzip, deflate, br',
        'accept-language': 'fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7',
        'content-type': 'application/x-www-form-urlencoded',
        'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.45 Safari/537.36',
        'origin': 'https://www1.gogoanime.cm',
        'referer': 'https://www1.gogoanime.cm/'
      }, body: data);
      print("code=${resp.statusCode}");
      print("code=${resp.body}");

      if(resp.statusCode >= 200 && resp.statusCode < 300){
        return User(email);
      }else if(resp.statusCode == 403){
        return Future.error('Invalid username or password.');
      }
      return Future.error('ERROR: Server returned code ' + resp.statusCode.toString());
    }
    return Future.error('Could not login');
  }
}



