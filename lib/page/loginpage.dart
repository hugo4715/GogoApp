import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gogo_app/helper.dart';

import '../data/user.dart';
import 'animepage.dart';
import 'homepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool canType = false;
  final loginField = TextEditingController();
  final passwordField = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    onlyPortrait();
    User.getCachedUser().then(loginSuccess, onError: errorFetchingUser);
  }
  void errorFetchingUser(error){
    setState(() {
      canType=true;
    });
  }

  @override
  void dispose() {
    allOrientation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: const Text('GogoApp'),
        ),
        body: Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Image.asset('assets/logo.png'),
              const Padding(
                padding: EdgeInsets.all(10),
                child: Text('Unofficial Mobile App', style: TextStyle(color: Color.fromARGB(100, 0, 0, 0)),),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: loginField,
                      validator: (str){
                        if(str != null && !RegExp("[^@ \t\r\n]+@[^@ \t\r\n]+\.[^@ \t\r\n]+").hasMatch(str)){
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                          labelText: 'Email'
                      ),
                    ),

                    TextFormField(
                      controller: passwordField,
                      validator: (value){
                        if(value == null || value.isEmpty){
                          return 'Please enter a password';
                        }
                        return null;
                      },
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Password'
                      ),
                    ),
                    ElevatedButton(onPressed: canType ? loginButton : null, child: canType ? const Text('Login') : const CircularProgressIndicator())
                  ],
                ),
              )
            ],
          ),
        )
    );
  }

  void loginButton() async{
    if(_formKey.currentState!.validate()){
      var username = loginField.text.trim();
      var password = passwordField.text;
        setState(() {
          canType = false;
        });
        Future<User> futureUser = User.login(username, password);
        futureUser.then(loginSuccess, onError: loginError);
    }

  }

  void loginSuccess(User user){
    print('loginSuccess');
    Navigator.pushReplacementNamed(context, '/home');
  }

  void loginError(var error){
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
}



