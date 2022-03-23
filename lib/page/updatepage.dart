import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:getwidget/components/carousel/gf_carousel.dart';
import 'package:gogo_app/data/anime.dart';
import 'package:gogo_app/data/search.dart';
import 'package:gogo_app/data/updater.dart';
import 'package:gogo_app/data/watchlist.dart';
import 'package:gogo_app/widget/animecarousel.dart';
import 'package:gogo_app/widget/animelist.dart';
import 'package:provider/provider.dart';

import '../data/user.dart';
import 'animepage.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdatePage extends StatefulWidget {
  UpdateInfo? update;

  UpdatePage(this.update, {Key? key}) : super(key: key);

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {

  _UpdatePageState() {}

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GogoAnime'),),
      body: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('An update is available! \n' +
                'Version ' + widget.update!.version.toString() + '\n\n' +
                '(Uninstall the app before installing the new APK)',
                textAlign: TextAlign.center
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(onPressed: (){laterButton(context);}, child: Text('Later')),
                ElevatedButton(onPressed: updateButton, child: Text('Update')),
              ],
            )
          ],
        ),
      )
    );
  }

  void laterButton(context){
    Navigator.pushReplacementNamed(context, "/home");
  }

  void updateButton() async{
    await launch("https://hugo4715.github.io/GogoAnime/");
  }
}
