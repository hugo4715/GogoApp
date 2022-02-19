import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gogo_app/settings.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart';

class User{
  static const secureStorage = FlutterSecureStorage();

  final String email;
  final String username;
  Cookie authCookie;

  User(this.email, this.username, this.authCookie);

  /// Refresh a user auth cookie for making requests if needed
  static Future<User> refresh(User user) async{
    var inOneHour = DateTime.now().add(const Duration(hours: 1));
    if(user.authCookie.expires!.isBefore(inOneHour)){
      var password = await secureStorage.read(key: 'password');
      return await login(user.email, password!);
    }
    return user;
  }

  /// Tries to get a user object from a previous session. It also refreshes the cookie automatically if necessary
  static Future<User> getCachedUser() async{
    if(await secureStorage.containsKey(key: 'email') && await secureStorage.containsKey(key: 'password') && await secureStorage.containsKey(key: 'cookie') && await secureStorage.containsKey(key: 'username')){
      var email = await secureStorage.read(key: 'email');
      var username = await secureStorage.read(key: 'username');
      var cookieString = await secureStorage.read(key: 'cookie');
      var cookie = Cookie.fromSetCookieValue(cookieString!);
      var user = User(
        email!,
        username!,
        cookie,
      );
      user = await refresh(user);
      return user;
    }
    return Future.error('No user found in secure store');
  }

  /// Login the user on the website. On success it also saves the credentials to the secure storage
  static Future<User> login(String email, String password) async{
    var client = Client();
    var url = Uri.parse(gogoDomain + '/login.html');

    // first request, to get the csrf token and cookie
    // set empty cookie to force the server to send me a new cookie
    var resp = await client.get(url, headers: {'cookie': ''});
    if(resp.statusCode >= 200 && resp.statusCode < 300){
      // extract csrf cookie (named gogoanime)
      var setCookieHeader = resp.headers['set-cookie'];
      if(setCookieHeader == null)return Future.error('Could not parse login page html! (set-cookie header not received)');
      var gogoCookie = Cookie.fromSetCookieValue(setCookieHeader);

      // extract csrf token from html
      var doc = html_parser.parseFragment(resp.body);
      var tokenEl = doc.querySelector('meta[name="csrf-token"]');
      if(tokenEl == null)return Future.error('Could not parse login page html! (csrf element not found)');
      var csrf = tokenEl.attributes['content'];
      if(csrf == null)return Future.error('Could not parse login page html! (csrf content not found)');

      // form data
      var data = <String,String>{};
      data['_csrf'] = csrf;
      data['email'] = email;
      data['password'] = password;

      // post the login informations
      resp = await client.post(url, headers: {
        'accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
        'accept-encoding': 'gzip, deflate, br',
        'accept-language': 'fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7',
        'content-type': 'application/x-www-form-urlencoded',
        'cookie': "${gogoCookie.name}=${gogoCookie.value}",
        'upgrade-insecure-requests': '1'
      }, body: data);

      // extract auth cookie for next requests
      setCookieHeader = resp.headers['set-cookie'];
      print(url);
      print(resp.body);
      print(resp.headers);
      if(setCookieHeader == null)return Future.error('Invalid user or password');
      Cookie authCookie = Cookie.fromSetCookieValue(setCookieHeader);

      if(resp.statusCode == 302){
        resp = await client.get(url, headers: {'cookie': "${authCookie.name}=${authCookie.value}"});
        if(resp.statusCode >= 200 && resp.statusCode < 300){
          // server always sends 302, we need to check if the user is logged in using the html
          doc = html_parser.parseFragment(resp.body);
          var accountEl = doc.querySelector('.account');
          if(accountEl != null){
            var username = accountEl.text.trim();
            _saveCredentials(email, username, password, authCookie);
            return User(email, username, authCookie);
          }
          return Future.error('ERROR: Received auth cookie but user is not logged in on the main page!');
        }
        return Future.error('ERROR: Server redirected correctly but then sent code ' + resp.statusCode.toString());
      }
      return Future.error('ERROR: Server returned code ' + resp.statusCode.toString());
    }
    return Future.error('ERROR: Server returned code ' + resp.statusCode.toString() + ' while getting login page!');
  }

  static void _saveCredentials(String email, String username, String password, Cookie authCookie) {
    secureStorage.write(key: 'email', value: email);
    secureStorage.write(key: 'username', value: username);
    secureStorage.write(key: 'password', value: password);
    secureStorage.write(key: 'cookie', value: authCookie.toString());
    print('Stored credentials in secure store');
  }
}