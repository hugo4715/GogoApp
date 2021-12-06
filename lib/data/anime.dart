import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:gogo_app/settings.dart';
import 'package:http/http.dart';
import 'dart:math';

import 'user.dart';

class Anime {
  static final CacheManager cacheManager = DefaultCacheManager();
  final String id;
  final String name;
  final String type;
  final String plot;
  final String coverUrl;
  final int episodeCount;
  late String shortPlot;

  Anime({
    required this.id,
    required this.name,
    required this.episodeCount,
    required this.plot,
    required this.coverUrl,
    required this.type,
  }){
    shortPlot = plot.substring(0, 101+plot.substring(100).indexOf('.'));
  }

  @override
  String toString() {
    return 'Anime: {id: ${id}, name: ${name}, cover: ${coverUrl}, plot: ${plot}, episodeCount: ${episodeCount}, type: ${type}}';
  }

  String episodeName(int id){
    if(type == 'Movie')return 'Movie ${id}';
    return 'Episode ${id}';
  }

  Future<List<StreamingUrl>> fetchStreamUrl(User user, int episode) async{
    print('fetchStreamUrl ');
    try{
      var resp = await http.get(Uri.parse(gogoDomain + '/' + id + '-episode-' + episode.toString()), headers: {
        'cookie': "${user.authCookie.name}=${user.authCookie.value}"
      });
      print("code=${resp.statusCode}");
      if(resp.statusCode >= 200 && resp.statusCode < 300){
        var doc = html_parser.parseFragment(resp.body);
        List<StreamingUrl> urls = [];
        var links = doc.querySelectorAll('.cf-download a');
          for(var el in links){
            var url = el.attributes['href'];
            urls.add(StreamingUrl(el.text.trim(), url!));
          }
          return urls;
      }  else{
        return Future.error('Error while fetching episode url ' + id + ' (http ' + resp.statusCode.toString() + ')');
      }
    } on SocketException{
      return Future.error('Error while fetching episode url ' + id + ' (no internet connection)');
    }
  }

  factory Anime.fromCategoryPage(String id, String html) {
    final doc = html_parser.parseFragment(html);
    var title = doc.querySelector(".anime_info_body_bg h1");

    if(title == null){
      throw Exception();
    }
    var descriptors = doc.querySelectorAll(".anime_info_body_bg .type");

    String? cover = doc.querySelector(".anime_info_body_bg img")?.attributes["src"];
    String? plot = descriptors.firstWhereOrNull((element) => element.text.startsWith("Plot Summary: "))?.text.substring("Plot Summary: ".length);
    String? type = descriptors.firstWhereOrNull((element) => element.text.startsWith("Type: "))?.text.substring("Type: ".length);

    int maxEp = 0;
    for(var el in doc.querySelectorAll("#episode_page li a")){
      maxEp = max(int.parse(el.attributes["ep_end"]!), maxEp);
    }

    String name = title.text;
    return Anime(
      id: id,
      name: name,
      episodeCount: maxEp,
      plot: plot!.trim(),
      coverUrl: cover!.trim(),
      type: type!.trim()
    );
  }

  static Future<Anime> fetchById(String id) async {
    var cachedFile = await cacheManager.getFileFromCache(id);
    String? content;
    if(cachedFile != null && await cachedFile.file.exists()){
      print("Found ${id} in cache");
      content = await cachedFile.file.readAsString();
    }else{
      print("${id} not in cache, requesting from the web");
      try{
        var resp = await http.get(Uri.parse(gogoDomain + '/category/' + id));
        if(resp.statusCode >= 200 && resp.statusCode < 300){
          content = resp.body;
          cacheManager.putFile("", Uint8List.fromList(utf8.encode(content)), key: id);
          print("$id put in cache");
        }  else{
          return Future.error('Error while fetching anime ' + id + ' (http ' + resp.statusCode.toString() + ')');
        }
      } on SocketException{
        return Future.error('Error while fetching anime ' + id + ' (no internet connection)');
      }
    }
    return Anime.fromCategoryPage(id, content);
  }


}

class StreamingUrl{
  final String quality;
  final String url;

  StreamingUrl(this.quality, this.url);

  @override
  String toString() {
    return "StreamingUrl {quality: $quality, url: $url}";
  }

  Future<String> fetchMediaUrl() async{
    http.Request req = http.Request("GET", Uri.parse(url))..followRedirects = false;
    http.Client baseClient = http.Client();
    http.StreamedResponse response = await baseClient.send(req);
    if(response.statusCode == 302){
      return response.headers['location']!;
    }
    return Future.error('Error while fetching streaming url! (server did not redirect: ${response.statusCode})');
  }
}

void LogPrint(Object object) async {
int defaultPrintLength = 1020;
if (object == null || object.toString().length <= defaultPrintLength) {
print(object);
} else {
String log = object.toString();
int start = 0;
int endIndex = defaultPrintLength;
int logLength = log.length;
int tmpLogLength = log.length;
while (endIndex < logLength) {
print(log.substring(start, endIndex));
endIndex += defaultPrintLength;
start += defaultPrintLength;
tmpLogLength -= defaultPrintLength;
}
if (tmpLogLength > 0) {
print(log.substring(start, logLength));
}
}
}