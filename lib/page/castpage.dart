
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_video_cast/flutter_video_cast.dart';
import 'package:gogo_app/data/anime.dart';
import 'package:gogo_app/widget/hiddentext.dart';

import 'animeplaypage.dart';
import '../data/user.dart';

class CastPage extends StatelessWidget {
  final Anime anime;
  final ChromeCastController controller;
  final bool playing;
  final void Function() playPause;

  CastPage({Key? key, required this.anime, required this.controller, required this.playPause, required this.playing}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RoundIconButton(
              icon: Icons.replay_10,
              onPressed: () => controller.seek(relative: true, interval: -10.0),
            ),
            RoundIconButton(
                icon: playing
                    ? Icons.pause
                    : Icons.play_arrow,
                onPressed: playPause
            ),
            RoundIconButton(
              icon: Icons.forward_10,
              onPressed: () => controller.seek(relative: true, interval: 10.0),
            )
          ],
        ),
      ),
    );
  }
}



class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  RoundIconButton({
    required this.icon,
    required this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
        child: Icon(
            icon,
            color: Colors.white
        ),
        padding: EdgeInsets.all(16.0),
        color: Colors.blue,
        shape: CircleBorder(),
        onPressed: onPressed
    );
  }
}