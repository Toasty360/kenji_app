import 'package:hive_flutter/hive_flutter.dart';

import '../Model/anime.dart';

final _watchList = Hive.box("Later");

bool saveItem(AnimeModel anime) {
  try {
    _watchList.put(anime.aniId, anime);
  } catch (e) {
    print(_watchList.length);
    return false;
  }
  return true;
}

bool removeItem(String aniId) {
  try {
    _watchList.delete(aniId);
    print(_watchList.length);
  } catch (e) {
    print("Idk bruh");
    return false;
  }
  return true;
}

AnimeModel getData(String aniId) => _watchList.get(aniId);

bool isSaved(String aniId) => _watchList.containsKey(aniId);
