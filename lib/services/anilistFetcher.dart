import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Model/anime.dart';

class AniList {
  static String base_url = "https://toasty-api.vercel.app/";

  static updateurl(String url) {
    base_url = url;
    print("at update url $base_url");
  }

  static Future<AnimeModel> fetchInfo(id, {provider = "", dub = false}) async {
    print("$base_url/meta/anilist/info/$id?dub=$dub");
    final response =
        await Dio().get("$base_url/meta/anilist/info/$id?dub=$dub");
    if (response.statusCode != 200) {
      base_url = "https://toasty-kun.vercel.app/";
      SharedPreferences.getInstance()
          .then((value) => value.setString("baseURL", base_url));
    }
    return AnimeModel.toTopAir(response.data);
  }

  static bool searchHasNext = true;
  static Future<List<AnimeModel>> searchData(search, {page = 1}) async {
    print(base_url);
    final response =
        await Dio().get("$base_url/meta/anilist/$search?page=$page");
    List<AnimeModel> data = [];
    for (Map e in response.data["results"]) {
      data.add(AnimeModel.toTopAir(e));
    }
    print("total anilist---${data.length}");
    if (response.statusCode != 200) {
      base_url = "https://toasty-kun.vercel.app/";
      SharedPreferences.getInstance()
          .then((value) => value.setString("baseURL", base_url));
    }
    searchHasNext = response.data["hasNextPage"];
    return data;
  }

  static Future<List> fetchSteamingLinks(String id) async {
    print("meta/anilist/watch/$id");
    final v = await Dio().get("$base_url/meta/anilist/watch/$id");
    if (v.statusCode != 200) {
      base_url = "https://toasty-kun.vercel.app/";
      print("got error");
      SharedPreferences.getInstance()
          .then((value) => value.setString("baseURL", base_url));
    }
    return v.data["sources"];
  }

  static Future<List<RecentEps>> fetchRecentEps({page = 1}) async {
    final v = await Dio().get("$base_url/anime/gogoanime/recent-episodes");

    return v.data["results"]
        .map((e) => RecentEps.fromJson(e))
        .toList()
        .cast<RecentEps>();
  }

  static Future<List<AnimeModel>> Trending({page = 1}) async {
    print(base_url);
    final response = await Dio().get("$base_url/meta/anilist/trending");
    List<AnimeModel> data = [];
    for (Map e in response.data["results"]) {
      data.add(AnimeModel.toTopAir(e));
    }
    print("total anilist---${data.length}");
    if (response.statusCode != 200) {
      base_url = "https://toasty-kun.vercel.app/";
      SharedPreferences.getInstance()
          .then((value) => value.setString("baseURL", base_url));
    }
    searchHasNext = response.data["hasNextPage"];
    return data;
  }
}

class RecentEps {
  final String id;
  final String title;
  final String image;
  final String episodeId;
  final int episodeNumber;

  RecentEps(
      this.id, this.title, this.image, this.episodeId, this.episodeNumber);

  static RecentEps fromJson(dynamic json) {
    try {
      return RecentEps(json["id"], json["title"] ?? "", json["image"],
          json["episodeId"], json["episodeNumber"]);
    } catch (e) {
      print(json);
      return RecentEps("", '', "image", "episodeId", 1);
    }
  }
}
