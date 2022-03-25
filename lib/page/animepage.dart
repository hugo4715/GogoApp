
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_video_cast/flutter_video_cast.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gogo_app/data/analytics.dart';
import 'package:gogo_app/data/anime.dart';
import 'package:gogo_app/page/castpage.dart';
import 'package:gogo_app/settings.dart';
import 'package:gogo_app/widget/hiddentext.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:android_path_provider/android_path_provider.dart';

import '../helper.dart';
import 'animeplaypage.dart';
import '../data/user.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:device_info/device_info.dart';

class AnimePageArguments{
  final Anime anime;

  AnimePageArguments(this.anime);
}

class AnimePage extends StatefulWidget {
  static CacheManager cacheManager = DefaultCacheManager();
  static const route = '/anime';

  final Anime anime;// partial anime with id, name and cover url
  const AnimePage({Key? key, required this.anime}) : super(key: key);

  @override
  State<AnimePage> createState() => _AnimePageState();
}

class _AnimePageState extends State<AnimePage> {
  late Future<Anime> futureAnime;// complete anime with all informations
  late Future<File> cover;

  late ChromeCastController _controller;
  AppState _state = AppState.idle;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    futureAnime = Anime.fetchById(widget.anime.id);
    futureAnime.then(print);
    FlutterDownloader.registerCallback(downloadCallback);
  }

  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    print('Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(builder: (_, orientation){
        return CustomScrollView(
          slivers: <Widget>[
            buildSliverAppBar(context, orientation),
            buildSliverPlot(),
            buildSliverLinks(),

          ],
        );
      }),
    );
  }

  FutureBuilder<Anime> buildSliverLinks() {
    return FutureBuilder<Anime>(
              future: futureAnime,
              builder: (ctx, snapshot) {
                if(snapshot.hasData){
                  Anime anime = snapshot.data!;
                  return SliverFixedExtentList(
                    itemExtent: 50.0,
                    delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                        return ListTile(
                            title: Text(anime.episodeName(index+1)),
                            trailing: Wrap(
                              children: [
                                IconButton(onPressed: (){
                                  downloadButton(context, anime, index+1);
                                }, icon: Icon(Icons.download)),
                                ElevatedButton(
                                  child: Text(_state == AppState.idle ? 'Play' : 'Cast'),
                                  onPressed: (){
                                    playButton(context, anime, index+1);
                                  },
                                )
                              ],
                            )
                        );
                      },
                      childCount: anime.episodeCount,
                    ),
                  );
                } else if(snapshot.hasError){
                  return SliverList(
                    delegate: SliverChildListDelegate([
                      Text(snapshot.error.toString())
                    ]),
                  );
                }
                return SliverList(
                  delegate: SliverChildListDelegate([
                    CircularProgressIndicator()
                  ]),
                );
              }
          );
  }

  FutureBuilder<Anime> buildSliverPlot() {
    return FutureBuilder<Anime>(
              future: futureAnime,
              builder: (ctx, snapshot) {
                if(snapshot.hasData){
                  Anime anime = snapshot.data!;
                  return SliverList(
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
                  );
                } else if(snapshot.hasError){
                  return SliverList(
                    delegate: SliverChildListDelegate([
                      Text(snapshot.error.toString())
                    ]),
                  );
                }
                return SliverList(
                    delegate: SliverChildListDelegate([
                      CircularProgressIndicator()
                    ]),
                );
              }
          );
  }

  SliverAppBar buildSliverAppBar(BuildContext context, Orientation orientation) {
    return SliverAppBar(
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
              title: Text(widget.anime.name),
              stretchModes: const [StretchMode.fadeTitle],
              background: Hero(
                tag: 'anime-' + widget.anime.id,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    CachedNetworkImage(
                      imageUrl: widget.anime.coverUrl!,
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
          );
  }

  void downloadButton(var ctx, Anime anime, int episode) async {
    var perm = await _checkPermission();
    if(!perm){
      showDialog(context: ctx, builder: (ctx){
        return const AlertDialog(
          title: Text("Cannot download episode!"),
          content: Text("App needs the storage permission to download files."),
        );
      });
      return;
    }

    Future<List<StreamingUrl>> urls = anime.fetchStreamUrlXStreamCDN(episode)
        .onError((error, stackTrace) => anime.fetchStreamUrl(episode));

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
                      trailing: ElevatedButton(onPressed: (){download(anime, episode, e);}, child: Text('Download')),
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

  void playButton(var ctx, Anime anime, int episode) {
    print("Starting playback of ${anime.name} episode $episode");

    Future<List<StreamingUrl>> urls = anime.fetchStreamUrlXStreamCDN(episode)
      .onError((error, stackTrace) => anime.fetchStreamUrl(episode));


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
  void download(Anime anime, int episode, StreamingUrl url) async{
    mixpanel.track('download-anime');

    final taskId = await FlutterDownloader.enqueue(
      url: await url.fetchMediaUrl(),
      savedDir: await _getSaveDir(),
      showNotification: true,
      openFileFromNotification: true,
      fileName: anime.name + ' - ' + episode.toString() + '.mp4',
      headers: {
        'Referer': gogoDomain
      }
    );
  }

  void play(Anime anime, int episode, StreamingUrl url) async{
    mixpanel.track('play-anime');

    var realUrl = await url.fetchMediaUrl();
    if(_state == AppState.idle){
      Navigator.push(context, MaterialPageRoute(builder: (ctx) => AnimePlayPage(anime: anime, episode: episode, url: realUrl)));
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

  // FlutterDownloader plugin

  Future<bool> _checkPermission() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    if (androidInfo.version.sdkInt <= 28) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  Future<String> _getSaveDir() async {
    var path = (await _findLocalPath())!;
    final savedDir = Directory(path);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    return path;
  }

  Future<String?> _findLocalPath() async {
    try {
      return await AndroidPathProvider.downloadsPath;
    } catch (e) {
      return (await getExternalStorageDirectory())?.path;
    }
  }

}


