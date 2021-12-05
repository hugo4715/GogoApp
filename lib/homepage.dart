import 'package:flutter/material.dart';
import 'package:gogo_app/data/anime.dart';
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  
  @override
  void initState() {
    super.initState();
    
    Future<Anime?> a = Anime.fetchById('mieruko-chan');

    a.then((value) => print(value.toString()));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GogoApp'),
      ),
    );
  }
}
