import 'package:shared_preferences/shared_preferences.dart';

import 'anime.dart';
import 'dart:convert';

/// Get a list of recently watched anime. The most recent one is one top
Future<List<Anime>> getRecentlyWatched() async{

  SharedPreferences prefs = await SharedPreferences.getInstance();
  if(prefs.containsKey('recentlyWatched')){
    var list = prefs.getStringList('recentlyWatched');
    return list!.map((e) => Anime.fromJson(jsonDecode(e))).toList();
  }
  return [];
}

/// Add an anime to the watched list. It will be added at the last position since it's the most recent one
void storeWatchedAnime(Anime anime) async{
  print('Storing watched anime ${anime.name}');
  List<Anime> watched = await getRecentlyWatched();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  watched.removeWhere((element) => element.id == anime.id);
  watched.add(anime);
  if(watched.length > 5)watched = watched.sublist(watched.length-5);
  await prefs.setStringList('recentlyWatched', watched.map((e) => jsonEncode(e.toJson())).toList());
}
