import 'package:flutter/material.dart';
// import 'package:isar/isar.dart';
// import 'package:kenji/model/anime.dart';
import 'package:media_kit/media_kit.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:kenji/services/anilistFetcher.dart';

import 'Pages/wrapper.dart';

Future<void> main() async {
  var r = AniList.fetchRecentEps(page: 1);
  var t = AniList.Trending(page: 1);
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  // await Hive.initFlutter(
  //   (await Directory(
  //               '${(await getApplicationDocumentsDirectory()).path}/.kenji')
  //           .create())
  //       .path,
  // );

  // final dir = await getApplicationDocumentsDirectory();
  // final isar = await Isar.open(
  //   [EpisodeModel, AnimeModel],
  //   directory: dir.path,
  // );

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "Kenji",
    darkTheme: ThemeData.dark(useMaterial3: true),
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: Wrapper(r: r, t: t),
  ));
}
