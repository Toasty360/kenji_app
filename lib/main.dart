import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kenji/Settings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Pages/wrapper.dart';
import 'model/anime.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initMeeduPlayer();
  await Hive.initFlutter(
    (await Directory(
                '${(await getApplicationDocumentsDirectory()).path}/.kenji')
            .create())
        .path,
  );
  Hive.registerAdapter(EpisodeModelAdapter());
  Hive.registerAdapter(AnimeModelAdapter());
  await SharedPreferences.getInstance().then((value) => settings.baseURL =
      value.getString("baseURL") ?? "https://spicy-api.vercel.app/");
  print(settings.baseURL);
  await Hive.openBox('Later');
  await Hive.openBox<AnimeModel>('WatchedIndexs');
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "Kenji",
    darkTheme: ThemeData.dark(useMaterial3: true),
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: const Wrapper(),
  ));
}
