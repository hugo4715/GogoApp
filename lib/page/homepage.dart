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

  _HomePageState() {
    searchBar = SearchBar(
      inBar: false,
      setState: setState,
      onSubmitted: onSearch,
      buildDefaultAppBar: buildAppBar,
      hintText: "Search anime",
    );
  }

  @override
  void initState() {
    super.initState();
    futureNewAnime = newAnimes();
    futureRecentlyWatchedAnime = getRecentlyWatched();
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

    return Scaffold(
      appBar: searchBar.build(context),
      body: Provider<User>(
        create: (ctx) => args.user,
        child: SingleChildScrollView(
          child: futureSearch != null ? buildSearch(context)
              : Column(
                  children: [
                    buildRecentlyWatched(context),
                    buildNewSeason(context)
                  ],
          ),
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
            children: [
              const Text('RECENTLY WATCHED', style: TextStyle(color: Colors.blue, fontSize: 23, fontWeight: FontWeight.bold),),
              Consumer<User>(
                builder: (context, user, _) => AnimeCarousel(animeList: snapshot.data!, user: user, infinite: false,),
              )
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
            children: [
              const Text('NEW SEASON', style: TextStyle(color: Colors.blue, fontSize: 23, fontWeight: FontWeight.bold),),
              Consumer<User>(
                builder: (context, user, _) => AnimeCarousel(animeList: snapshot.data!, user: user),
              )
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
          return Consumer<User>(
            builder: (context, user, _) => AnimeList(animeList: snapshot.data!, user: user),
          );
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
    final args = ModalRoute.of(context)!.settings.arguments as HomePageArguments;
    futureSearch = search(args.user, query);
  }
}
