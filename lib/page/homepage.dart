import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:getwidget/components/carousel/gf_carousel.dart';
import 'package:gogo_app/data/anime.dart';
import 'package:gogo_app/data/search.dart';
import 'package:gogo_app/data/watchlist.dart';
import 'package:gogo_app/widget/animecarousel.dart';
import 'package:gogo_app/widget/animelist.dart';
import 'package:provider/provider.dart';

import '../data/user.dart';
import 'animepage.dart';

class HomePageArguments{
  final User user;

  HomePageArguments(this.user);
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late SearchBar searchBar;
  Future<List<Anime>>? futureSearch;
  late Future<List<Anime>> futureNewAnime;
  late Future<List<Anime>> futureRecentlyWatchedAnime;
  late Future<Anime> futureFeatured;

  late User user;

  _HomePageState() {
    searchBar = SearchBar(
      inBar: false,
      setState: setState,
      onSubmitted: onSearch,
      buildDefaultAppBar: buildAppBar,
      hintText: "Search anime",
      closeOnSubmit: false,

      onClosed: () => futureSearch = null,
    );
  }

  @override
  void initState() {
    super.initState();
    futureNewAnime = newAnimes();
    futureRecentlyWatchedAnime = getRecentlyWatched();
    futureFeatured = getFeaturedAnime();
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
        title: const Text('GogoAnime'),
        actions: [searchBar.getSearchAction(context)]
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as HomePageArguments;
    user = args.user;

    return Scaffold(
      appBar: searchBar.build(context),
      body: futureSearch != null ? buildSearch(context)
          : SingleChildScrollView(
            child: Column(
                children: [
                  buildFeatured(),
                  buildRecentlyWatched(context),
                  buildNewSeason(context)
                ],
            ),
          ),
    );
  }

  Widget buildRecentlyWatched(BuildContext context) {
    return FutureBuilder<List<Anime>>(
      future: futureRecentlyWatchedAnime,
      builder: (context, snapshot){
        if(snapshot.hasData){
          return  snapshot.data!.isEmpty ? Container() : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Padding(
                  padding: EdgeInsets.fromLTRB(20, 10, 0, 0),
                  child: Text('Recently watched', style: TextStyle(color: Colors.blue, fontSize: 23, fontWeight: FontWeight.bold))
              ),
              AnimeCarousel(animeList: snapshot.data!, user: user, infinite: false,)
            ],
          );
        }else if(snapshot.hasError){
          return Text(snapshot.error.toString());
        }else{
          return const Center(child: CircularProgressIndicator(),);
        }
      },
    );
  }

  Widget buildNewSeason(BuildContext context) {
    return FutureBuilder<List<Anime>>(
      future: futureNewAnime,
     builder: (context, snapshot){
        if(snapshot.hasData){
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: EdgeInsets.fromLTRB(20, 10, 0, 0),child: const Text('NEW SEASON', style: TextStyle(color: Colors.blue, fontSize: 23, fontWeight: FontWeight.bold))),
              AnimeCarousel(animeList: snapshot.data!, user: user)
            ],
          );
        }else if(snapshot.hasError){
          return Text(snapshot.error.toString());
        }else{
          return const Center(child: CircularProgressIndicator(),);
        }
     },
    );
  }

  Widget buildSearch(BuildContext context) {
    if(futureSearch == null) {
      return Container();
    }

    return FutureBuilder<List<Anime>>(
      future: futureSearch,
      builder: (context, snapshot){
        if(snapshot.hasData && snapshot.data != null){
          for(var a in snapshot.data!){
            print('yes there is $a');
          }
          return AnimeList(animeList: snapshot.data!, user: user);
        }else if(snapshot.hasError){
          return Card(
            child: Center(child: Text(snapshot.data.toString())),
          );
        }
        return const Card(
          child: Center(child: CircularProgressIndicator()),
        );
      }
    );
  }

  void onSearch(String query){
    futureSearch = search(query);
  }

  Widget buildFeatured() {
    return FutureBuilder<Anime>(
      future: futureFeatured,
        builder: (context, snapshot){
          if(snapshot.hasData){
            Anime anime = snapshot.data!;
            return Container(
              height: 350,
              child: GestureDetector(
                onTap: (){
                  Navigator.pushNamed(context, '/anime', arguments: AnimePageArguments(anime.id, user));
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(imageUrl: anime.coverUrl!, fit: BoxFit.cover),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(0.0, 0.5),
                          end: Alignment.center,
                          colors: <Color>[
                            Color(0xc0000000),
                            Color(0x00000000),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      bottom: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Featured', style: TextStyle(fontSize: 15, color: Color.fromARGB(150, 255, 255, 255))),
                            Text(anime.name, style: const TextStyle(fontSize: 20, color: Colors.white)),
                          ],
                        )
                    )
                  ],
                ),
              ),
            );
          }else if(snapshot.hasError){
            //TODO
          }
          return const Center(child: CircularProgressIndicator());
        }
    );
  }
}
