import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gogo_app/data/anime.dart';
import 'package:gogo_app/data/watchlist.dart';
import 'package:gogo_app/helper.dart';
import 'package:gogo_app/settings.dart';
import 'package:gogo_app/widget/customcontrols.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

import '../data/user.dart';

class AnimePlayPage extends StatefulWidget {
  final User user;
  final Anime anime;
  final int episode;
  final String url;
  const AnimePlayPage({Key? key, required this.anime, required this.episode, required this.user, required this.url}) : super(key: key);

  @override
  State<AnimePlayPage> createState() => _AnimePlayPageState();
}

class _AnimePlayPageState extends State<AnimePlayPage> {
  late VideoPlayerController _controller;

  late ChewieController chewieController;

  @override
  void initState() {
    super.initState();
    storeWatchedAnime(widget.anime);
    _controller = VideoPlayerController.network(widget.url, httpHeaders: {
      'Referer': gogoDomain,
    });

    chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: true,
      looping: true,
      fullScreenByDefault: true,
      customControls: GogoControls()
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    chewieController.dispose();
    Wakelock.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Wakelock.enable();
    return Scaffold(
      backgroundColor: const Color.fromARGB(1, 0, 0, 0),
      body: Center(
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: Chewie(
            controller: chewieController,
          )
        ),
      )
    );
  }
}