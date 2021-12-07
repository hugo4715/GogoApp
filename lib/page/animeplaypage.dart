import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gogo_app/data/anime.dart';
import 'package:gogo_app/helper.dart';
import 'package:gogo_app/widget/customcontrols.dart';
import 'package:video_player/video_player.dart';

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
    print(widget.url);
    _controller = VideoPlayerController.network(widget.url, httpHeaders: {
      'Referer': 'https://www1.gogoanime.cm/',
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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