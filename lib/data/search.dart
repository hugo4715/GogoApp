import 'dart:convert';

import 'package:gogo_app/data/anime.dart';
import 'package:gogo_app/data/user.dart';
import 'package:gogo_app/helper.dart';
import 'package:gogo_app/settings.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// Search gogoanime
Future<List<Anime>> search(String query) async {
  var url = Uri.parse(gogoDomain + '/search.html?keyword=' + query);// yes the real client doesn't encode the query string, it's not my fault
  var resp = await http.get(url);

  if(resp.statusCode == 200){
    var doc = html_parser.parseFragment(resp.body);
    List<Anime> list = List.empty(growable: true);
    for(var item in doc.querySelectorAll('.last_episodes .items li')){
      var coverUrl = item.querySelector('img')?.attributes['src'];
      var name = item.querySelector('.name')!.text.trim();
      var id = item.querySelector('.name a')!.attributes['href']!;
      id = id.substring(id.lastIndexOf('/')+1);
      print('search found $name');
      list.add(Anime(
        id: id,
        name: name,
        coverUrl: coverUrl
      ));
    }
    return list;
  }
  return Future.error('Error while searching (server sent code ${resp.statusCode})');

}

/// Fetch the recent release page
Future<List<Anime>> newAnimes() async {
  var url = Uri.parse(gogoDomain + '/new-season.html');
  var resp = await http.get(url);

  if(resp.statusCode == 200){
    var doc = html_parser.parseFragment(resp.body);
    List<Anime> list = List.empty(growable: true);
    for(var item in doc.querySelectorAll('.last_episodes .items li')){
      var coverUrl = item.querySelector('img')?.attributes['src'];
      var name = item.querySelector('.name')!.text.trim();
      var id = item.querySelector('.name a')!.attributes['href']!;
      id = id.substring(id.lastIndexOf('/')+1);
      print('new animes found $name');
      list.add(Anime(
          id: id,
          name: name,
          coverUrl: coverUrl
      ));
    }
    return list;
  }
  return Future.error('Error while getting new animes (server sent code ${resp.statusCode})');
}

/// Get the highest quality cover from the list of available animes
Future<Anime> getHighestCoverQuality(List<Anime> animes) async{
  Client client = Client();
  Anime? maxAnime;
  int maxSize = 0;
  for (var anime in animes) {
    var url = anime.coverUrl;
    if(url != null){
      var resp = await client.head(Uri.parse(url));
      var size = resp.headers['content-length'] as int;
      if(size > maxSize){
        maxAnime = anime;
        maxSize = size;
      }
    }
  }
  client.close();

  if(maxAnime == null) return Future.error('Could not fetch any covers!');

  return maxAnime;
}

/// Get the featured animes on the homepage from storage
Future<List<Anime>> getCachedFeaturedAnime() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var content = prefs.getStringList('featuredAnimes');
  if(content != null){
    var featured = content.map((e) => Anime.fromJson(jsonDecode(e)));
    print('Loaded ${featured.length} featured animes:');
    featured.forEach(print);
    return featured.toList();
  }
  return Future.error('No featured anime cached');
}

Future<List<Anime>> fetchFeaturedAnime() async{
  var url = Uri.parse(gogoDomain + '/popular.html');
  var resp = await http.get(url);

  if(resp.statusCode == 200){
    var doc = html_parser.parseFragment(resp.body);
    List<Anime> list = List.empty(growable: true);
    for(var item in doc.querySelectorAll('.last_episodes .items li')){
      var coverUrl = item.querySelector('img')?.attributes['src'];
      var name = item.querySelector('.name')!.text.trim();
      var id = item.querySelector('.name a')!.attributes['href']!;
      id = id.substring(id.lastIndexOf('/')+1);
      print('featured found $name');
      list.add(Anime(
          id: id,
          name: name,
          coverUrl: coverUrl
      ));
    }

    // cache
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('featuredAnimes', list.map((e) => jsonEncode(e.toJson())).toList());
    return list;
  }
  return Future.error('Error while getting featured animes (server sent code ${resp.statusCode})');
}

/// Get the animes featured on the homepage, prefer from cache
/// TODO Fetch new featured animes async if data is outdated
Future<Anime> getFeaturedAnime() async{
  var animeList = await getCachedFeaturedAnime()
      .onError((error, stackTrace) => fetchFeaturedAnime());
  return animeList.randomItem();
}
