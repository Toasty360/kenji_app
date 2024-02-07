// import 'package:hive_flutter/hive_flutter.dart';

// import '../Model/anime.dart';

// final _watchList = Hive.box<AnimeModel>("Later");

// Future<bool> saveItem(AnimeModel anime) async {
//   try {
//     (await _watchList).put(anime.aniId, anime);
//   } catch (e) {
//     print(e);
//     return false;
//   }
//   return true;
// }

// Future<bool> removeItem(String aniId) async {
//   try {
//     (await _watchList).delete(aniId);
//     print((await _watchList).length);
//   } catch (e) {
//     print("Idk bruh");
//     return false;
//   }
//   return true;
// }

// Future<List<AnimeModel>> getAll() async =>
//     (await _watchList).values.toList().cast<AnimeModel>();

// Future<AnimeModel> getData(String aniId) async =>
//     (await _watchList).get(aniId)!;

// Future<bool> isSaved(String aniId) async =>
//     (await _watchList).containsKey(aniId);

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:hive/hive.dart';

// import '../model/anime.dart';

// class HiveBoxProvider extends ChangeNotifier {
//   late Box _animeBox;

//   Box get animeBox => _animeBox;

//   Future<void> initializeBox() async {
//     _animeBox = await Hive.openBox<AnimeModel>('animeBox');
//     notifyListeners();
//   }
// }
