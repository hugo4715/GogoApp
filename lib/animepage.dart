
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gogo_app/data/anime.dart';

import 'animeplaypage.dart';

class AnimePageArguments{
  final String animeId;

  AnimePageArguments(this.animeId);
}

class AnimePage extends StatefulWidget {
  static CacheManager cacheManager = DefaultCacheManager();
  static const route = '/anime';

  final String animeId;

  const AnimePage({Key? key, required this.animeId}) : super(key: key);

  @override
  State<AnimePage> createState() => _AnimePageState();
}

class _AnimePageState extends State<AnimePage> {
  late Future<Anime> futureAnime;
  late Future<File> cover;
  @override
  void initState() {
    super.initState();
    futureAnime = Anime.fetchById(widget.animeId);
    futureAnime.then(print);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GogoApp'),
      ),
      body: FutureBuilder<Anime>(
        future: futureAnime,
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            Anime anime = snapshot.data!;
            return OrientationBuilder(builder: (_, orientation){
              return CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    backgroundColor: Color.fromARGB(0, 0, 0, 0),
                    pinned: false,
                    expandedHeight: orientation == Orientation.landscape ? 100 : 350,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(anime.name),
                      stretchModes: [StretchMode.fadeTitle],
                      background: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          CachedNetworkImage(
                            imageUrl: anime.coverUrl,
                            progressIndicatorBuilder: (context, url, downloadProgress) => Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                            fit: BoxFit.cover,
                          ),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment(0.0, 0.5),
                                end: Alignment.center,
                                colors: <Color>[
                                  Color(0xa0000000),
                                  Color(0x00000000),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Container(
                        margin: const EdgeInsets.all(10),
                        child: Text(
                          anime.shortPlot,
                          maxLines: 4,
                          overflow: TextOverflow.fade,
                          style: const TextStyle(color: Color(0x80000000)),
                        ),
                      )
                    ]),
                  ),
                  SliverFixedExtentList(
                    itemExtent: 50.0,
                    delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                        return ListTile(
                          title: Text(anime.episodeName(index+1)),
                          trailing: ElevatedButton(
                            child: const Text('Play'),
                            onPressed: (){
                              play(context, anime, index+1);
                            },
                          ),
                        );
                      },
                      childCount: anime.episodeCount,
                    ),
                  ),
                ],
              );
            });
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void play(var ctx, Anime anime, int id) {
    print("Starting playback of ${anime.name} episode $id");
    Navigator.push(ctx, MaterialPageRoute(builder: (context) => AnimePlayPage(anime: anime, episode: id,)),);
  }
}


