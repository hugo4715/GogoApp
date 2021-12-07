import 'package:gogo_app/data/anime.dart';
import 'package:gogo_app/data/user.dart';
import 'package:gogo_app/settings.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;


Future<List<Anime>> search(User user, String query) async {
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