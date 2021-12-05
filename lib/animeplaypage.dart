import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gogo_app/data/anime.dart';

class AnimePlayPage extends StatefulWidget {
  final Anime anime;
  final int episode;
  const AnimePlayPage({Key? key, required this.anime, required this.episode}) : super(key: key);

  @override
  State<AnimePlayPage> createState() => _AnimePlayPageState();
}

class _AnimePlayPageState extends State<AnimePlayPage> {
  late Future<List<StreamingUrl>> futureUrls;

  @override
  void initState() {
    super.initState();
    futureUrls = widget.anime.fetchStreamUrl(widget.episode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GogoApp'),
      ),
      body: FutureBuilder<List<StreamingUrl>>(
        builder: (ctx, snapshot){
          if(snapshot.hasData){
            List<StreamingUrl> urls = snapshot.data!;
            return ListView(
              children: urls.map((e) => ListTile(
                  title: Text(e.quality),
              )).toList(),
            );
          }else if(snapshot.hasError){
            return Text(snapshot.error.toString());
          }
          return const Center(child: CircularProgressIndicator());
        },
      )
    );
  }

}


