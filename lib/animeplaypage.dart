import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gogo_app/data/anime.dart';
import 'package:gogo_app/helper.dart';
import 'package:video_player/video_player.dart';

import 'data/user.dart';

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

  @override
  void initState() {
    super.initState();
    allOrientation();
    print(widget.url);
    _controller = VideoPlayerController.network(widget.url, httpHeaders: {
      'Referer': 'https://www1.gogoanime.cm/',
    });

    _controller.addListener(() {
      setState(() {});
    });
    _controller.initialize().then((_) => setState(() {}));
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(1, 0, 0, 0),
      body: Center(
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              VideoPlayer(_controller),
              _ControlsOverlay(controller: _controller),
              VideoProgressIndicator(_controller, allowScrubbing: true),
            ],
          ),
        ),
      )
    );
  }


}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({Key? key, required this.controller})
      : super(key: key);

  static const _examplePlaybackRates = [
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
            color: Colors.black26,
            width: double.maxFinite,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.skip_previous,
                    color: Colors.white,
                    size: 100.0,
                    semanticLabel: 'Skip back',
                  ),
                  Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 100.0,
                    semanticLabel: 'Play',
                  ),
                  Icon(
                    Icons.skip_next,
                    color: Colors.white,
                    size: 100.0,
                    semanticLabel: 'Skip forward',
                  )
                ],
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: controller.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (speed) {
              controller.setPlaybackSpeed(speed);
            },
            itemBuilder: (context) {
              return [
                for (final speed in _examplePlaybackRates)
                  PopupMenuItem(
                    value: speed,
                    child: Text('${speed}x'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.playbackSpeed}x'),
            ),
          ),
        ),
      ],
    );
  }
}


