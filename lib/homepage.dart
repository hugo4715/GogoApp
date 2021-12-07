import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gogo_app/data/anime.dart';
import 'package:provider/provider.dart';

import 'data/user.dart';

class HomePageArguments{
  final User user;

  HomePageArguments(this.user);
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as HomePageArguments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GogoApp'),
      ),
      body: Provider<User>(
        create: (ctx) => args.user,
        child: const HomePageContent(),
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  const HomePageContent({Key? key}) : super(key: key);

  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Consumer<User>(
        builder: (ctx, user, _){
          return Text(user.username);
        },
      ),
    );
  }
}

