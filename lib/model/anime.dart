import 'package:hive/hive.dart';
part 'anime.g.dart';

@HiveType(typeId: 2)
class EpisodeModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final int number;
  @HiveField(4)
  final String image;
  @HiveField(5)
  final String airDate;

  EpisodeModel(this.id, this.title, this.description, this.number, this.image,
      this.airDate);

  static EpisodeModel fromJson(Map<String, dynamic> json) {
    return EpisodeModel(
        json["id"],
        json["title"] ?? json["id"].replaceAll("-", " "),
        json["description"] ?? "",
        json["number"],
        json["image"],
        json["airDate"] ?? "2023-03-29T11:00:00.000Z");
  }
}

@HiveType(typeId: 1)
class AnimeModel extends HiveObject {
  @HiveField(0)
  final String aniId;
  @HiveField(1)
  final int malId;
  @HiveField(2)
  final String title;
  @HiveField(3)
  final String image;
  @HiveField(4)
  final String desc;
  @HiveField(5)
  final String status;
  @HiveField(6)
  final String cover;
  @HiveField(7)
  final String releaseDate;
  @HiveField(8)
  final String? color;
  @HiveField(9)
  final String geners;
  @HiveField(10)
  final String totalEpisodes;
  @HiveField(11)
  final String type;
  @HiveField(12)
  final bool is_hentai;
  @HiveField(13)
  final List<EpisodeModel> episodes;
  @HiveField(14)
  final String episodeTitle;
  @HiveField(15)
  final String titles;
  @HiveField(16)
  final String slug;
  @HiveField(17)
  final bool is_censored;
  @HiveField(18)
  final String episodeNumber;
  @HiveField(19)
  final int nextAiringEpisode;
  @HiveField(20)
  final String subOrDub;

  AnimeModel(
      this.aniId,
      this.malId,
      this.title,
      this.image,
      this.desc,
      this.status,
      this.cover,
      this.releaseDate,
      this.color,
      this.geners,
      this.totalEpisodes,
      this.type,
      this.episodes,
      this.episodeNumber,
      this.episodeTitle,
      this.titles,
      this.slug,
      this.is_censored,
      this.is_hentai,
      this.nextAiringEpisode,
      this.subOrDub);

  static AnimeModel toTopAir(json) {
    List<EpisodeModel> temp = [];
    if (json["episodes"].runtimeType != int) {
      if (json["episodes"] != null) {
        for (Map<String, dynamic> e in json["episodes"]) {
          temp.add(EpisodeModel.fromJson(e));
        }
      }
    }

    return AnimeModel(
        "${json["id"]}",
        json["malId"] ?? 0,
        json["title"] != null ? json["title"]["romaji"].toString() : " ",
        json["cover_url"] ??
            json["image"] ??
            (json["coverImage"] != null
                ? (json["coverImage"]["extraLarge"] ?? json["bannerImage"])
                : " "),
        json["description"] != null
            ? json["description"].replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ')
            : "",
        json["status"] ?? "Ongoing",
        json["poster_url"] ??
            json["cover"] ??
            (json["bannerImage"] ??
                (json["coverImage"] != null
                    ? json["coverImage"]["extraLarge"]
                    : "")),
        json['releaseDate'] != null ? json["releaseDate"].toString() : "Recent",
        json["color"] ??
            (json["coverImage"] != null ? json["coverImage"]["color"] : ""),
        json["tags"] != null
            ? json["tags"].toString().replaceAll(RegExp(r'[\[\]]'), "")
            : json["genres"].toString().replaceAll(RegExp(r'[\[\]]'), ""),
        json["totalEpisodes"].toString(),
        json["type"] ?? "",
        temp.reversed.toList(),
        json["episodeNumber"] != null ? json["episodeNumber"].toString() : "",
        json["episodeTitle"] != null ? json["episodeTitle"].toString() : "",
        json["titles"] != null ? json["titles"][0] : "",
        json["slug"] ?? " ",
        json["is_censored"] ?? false,
        json["is_censored"] != null ? true : false,
        json["nextAiringEpisode"] != null
            ? json["nextAiringEpisode"]["airingTime"]
            : 0,
        json["subOrDub"] ?? "Sub");
  }

  static Map toJson(AnimeModel item) {
    return {
      "aniId": item.aniId,
      "malId": item.malId,
      "title": item.title,
      "image": item.image,
      "desc": item.desc,
      "status": item.status,
      "cover": item.cover,
      "releaseDate": item.releaseDate,
      "color": item.color,
      "geners": item.geners,
      "totalEpisodes": item.totalEpisodes,
      "type": item.type,
      "episodes": item.episodes,
      "episodeNumber": item.episodeNumber,
      "episodeTitle": item.episodeTitle,
      "titles": item.titles,
      "slug": item.slug,
      "is_censored": item.is_censored,
      "is_hentai": item.is_hentai,
    };
  }
}

// class ScheduleModel {
//   final AnimeModel details;
//   final Map schedule;

//   ScheduleModel(this.details, this.schedule);
//   static ScheduleModel fromJson(json) {
//     return ScheduleModel(AnimeModel.toTopAir(json["media"]),
//         {"airingAt": json["airingAt"], "episode": json["episode"].toString()});
//   }
// }


