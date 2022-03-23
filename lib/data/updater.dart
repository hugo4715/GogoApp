import 'dart:convert';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:version/version.dart';
import 'package:http/http.dart';


const prefsUpdaterTimestampKey = "updater_check_timestamp";

class UpdateInfo{
  Version version;
  String url;

  UpdateInfo({
    required this.version,
    required this.url,
  });
}

Future<UpdateInfo?> checkUpdates() async{
  var now = DateTime.now();
  var prefs = await SharedPreferences.getInstance();
  var shouldCheckUpdates = true;

  if(prefs.containsKey(prefsUpdaterTimestampKey)){
    var last = DateTime.parse(prefs.getString(prefsUpdaterTimestampKey)!);

    // check updates once a day
    if(last.add(const Duration(days: 1)).isAfter(now)){
      shouldCheckUpdates = true;
      print('Skipped upates since we already checked today');
    }
  }


  if(shouldCheckUpdates){
    var update =  await _fetchUpdates();
    if(update == null){
      // no updates found, store the timestamp so we don't check that too soon. If we found an update, do not store the timestamp so it rechecks updates every time
      prefs.setString(prefsUpdaterTimestampKey, now.toString());
      print('No updates were found, we will try to update again tomorrow');
    }
    return update;
  }

  return null;
}

Future<UpdateInfo?> _fetchUpdates() async{
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  Version currentVersion = Version.parse(packageInfo.version);
  UpdateInfo? highestVersion;

  var url = Uri.parse("https://api.github.com/repos/hugo4715/GogoApp/releases?per_page=99");
  var resp = await get(url);

  if(resp.statusCode >= 200 && resp.statusCode < 300){
    var releaseArray = jsonDecode(resp.body);
    for(var release in releaseArray){
      String? tag = release['tag_name'];
      List<dynamic> assets = release['assets'];

      // skip releases if they can't be auto updated
      if(tag == null || tag.isEmpty || assets.isEmpty || assets[0]['browser_download_url'] == null || !(assets[0]['browser_download_url'] as String).endsWith(".apk")){
        continue;
      }

      // remove v from v1.3.0 to have a true semver
      if(tag[0] == 'v') {
        tag = tag.substring(1);
      }


      Version version = Version.parse(tag);
      if(highestVersion == null || version > highestVersion){
        highestVersion = UpdateInfo(version: version, url: assets[0]['browser_download_url']);
      }
    }

    if(highestVersion != null && highestVersion.version > currentVersion){
      return highestVersion;
    }
    return null;
  }

  return Future.error("Could not check for updates: Github API returned code " + resp.statusCode.toString());
}