
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_video_cast/flutter_video_cast.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gogo_app/data/anime.dart';
import 'package:gogo_app/page/castpage.dart';
import 'package:gogo_app/widget/hiddentext.dart';

import '../helper.dart';
import 'animeplaypage.dart';
import '../data/user.dart';

class AnimePageArguments{
  final String animeId;
  final User user;

  AnimePageArguments(this.animeId, this.user);
}

class AnimePage extends StatefulWidget {
  static CacheManager cacheManager = DefaultCacheManager();
  static const route = '/anime';

  final String animeId;
  final User user;
  const AnimePage({Key? key, required this.animeId, required this.user}) : super(key: key);

  @override
  State<AnimePage> createState() => _AnimePageState();
}

class _AnimePageState extends State<AnimePage> {
  late Future<Anime> futureAnime;
  late Future<File> cover;

  late ChromeCastController _controller;
  AppState _state = AppState.idle;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    futureAnime = Anime.fetchById(widget.animeId);
    futureAnime.then(print);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Anime>(
        future: futureAnime,
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            Anime anime = snapshot.data!;
            return OrientationBuilder(builder: (_, orientation){
              return CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    actions: [
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: ChromeCastButton(
                          size: 50,
                          color: Colors.white,
                          onButtonCreated: _onButtonCreated,
                          onSessionStarted: _onSessionStarted,
                          onSessionEnded: () => Navigator.pop(context),
                          onRequestCompleted: _onRequestCompleted,
                          onRequestFailed: _onRequestFailed,
                        ),
                      )
                    ],
                    pinned: false,
                    expandedHeight: orientation == Orientation.landscape ? 100 : 350,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(anime.name),
                      stretchModes: const [StretchMode.fadeTitle],
                      background: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          CachedNetworkImage(
                            imageUrl: anime.coverUrl!,
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
                        child: HiddenText(
                          text: anime.plot!,
                          len: 180,
                          style: const TextStyle(color: Color(0x80000000))
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
                            child: Text(_state == AppState.idle ? 'Play' : 'Cast'),
                            onPressed: (){
                              playButton(context, anime, index+1);
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

  void playButton(var ctx, Anime anime, int episode) {
    print("Starting playback of ${anime.name} episode $episode");

    Future<List<StreamingUrl>> urls = anime.fetchStreamUrlXStreamCDN(widget.user, episode)
      .onError((error, stackTrace) => anime.fetchStreamUrl(widget.user, episode));


    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text("Episode $episode - Quality"),
            content: FutureBuilder<List<StreamingUrl>>(
              future: urls,
              builder: (ctx, snapshot){
                if(snapshot.hasData){
                  print('hasData=true');
                  return Column(
                    children: snapshot.data!.map((e) => ListTile(
                      title: Text(e.quality),
                      trailing: ElevatedButton(onPressed: (){play(anime, episode, e);}, child: Text('Play')),
                    )).toList(),
                  );
                }else if(snapshot.hasError){
                  return Text(snapshot.error.toString());
                }
                return const Center(child: CircularProgressIndicator(),);
              },
            ),
          );
        }
    );
  }

  void play(Anime anime, int episode, StreamingUrl url) async{
    var realUrl = await url.fetchMediaUrl();
    if(_state == AppState.idle){
      Navigator.push(context, MaterialPageRoute(builder: (ctx) => AnimePlayPage(anime: anime, episode: episode, user: widget.user, url: realUrl)));
    }else{
      // cast
      Fluttertoast.showToast(
          msg: realUrl,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
      );

      _controller.loadMedia(realUrl);
      Navigator.push(context, MaterialPageRoute(builder: (content) => CastPage(controller: _controller, anime: anime, playPause: _playPause, playing: _playing)));
    }

  }

  // CAST

  Future<void> _onButtonCreated(ChromeCastController controller) async {
    _controller = controller;
    await _controller.addSessionListener();
  }

  Future<void> _onSessionStarted() async {
    setState(() => _state = AppState.connected);
  }

  Future<void> _onRequestCompleted() async {
    setState(() {
      _state = AppState.mediaLoaded;
    });
  }

  Future<void> _onRequestFailed(String error) async {
    Navigator.pop(context);
  }

  Future<void> _playPause() async {
    final playing = await _controller.isPlaying();
    if(playing) {
      await _controller.pause();
    } else {
      await _controller.play();
    }
    setState(() => _playing = !playing);
  }
}


