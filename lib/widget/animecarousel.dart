import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/carousel/gf_carousel.dart';
import 'package:gogo_app/data/anime.dart';
import 'package:gogo_app/data/user.dart';
import 'package:gogo_app/page/animepage.dart';

class AnimeCarousel extends StatelessWidget {
  final List<Anime> animeList;
  final User user;
  final bool infinite;
  const AnimeCarousel({Key? key, required this.animeList, required this.user, this.infinite = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GFCarousel(
      enableInfiniteScroll: infinite,
      items: animeList.map((anime) {
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/anime', arguments: AnimePageArguments(anime.id, user));
          },
          child: Container(
            margin: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
              child: Stack(
                children: [
                  DecoratedBox(
                    position: DecorationPosition.foreground,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(0.0, 0.5),
                        end: Alignment.center,
                        colors: <Color>[
                          Color(0xa0000000),
                          Color(0x00000000),
                        ],
                      ),
                    ),
                    child: CachedNetworkImage(
                        imageUrl: anime.coverUrl!,
                        fit: BoxFit.cover,
                        width: double.maxFinite
                    ),
                  ),
                  Positioned(
                    width: 250,
                    bottom: 10,
                    left: 10,
                    child: Text(
                      anime.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
        );
      },
      ).toList(),
    );
  }
}
