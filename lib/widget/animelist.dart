import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gogo_app/data/anime.dart';
import 'package:gogo_app/data/user.dart';
import 'package:gogo_app/page/animepage.dart';

class AnimeList extends StatelessWidget {
  final List<Anime> animeList;
  const AnimeList({Key? key, required this.animeList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      semanticChildCount: animeList.length,
      padding: const EdgeInsets.all(10),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: animeList.map( (anime){
         return GestureDetector(
           onTap: (){
             Navigator.pushNamed(context, '/anime', arguments: AnimePageArguments(anime.id));
           },
           child: Stack(
             fit: StackFit.expand,
             children: [
               anime.coverUrl != null ? CachedNetworkImage(
                 imageUrl: anime.coverUrl!,
                 fit: BoxFit.cover,
               ) : const CircularProgressIndicator(),
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
               Positioned(
                 width: 150,
                 bottom: 10,
                 left: 10,
                 child: Text(
                   anime.name,
                   style: const TextStyle(
                     color: Colors.white
                   ),
                 )
               )
             ],
           )
         );
       }).toList()
    );
  }
}