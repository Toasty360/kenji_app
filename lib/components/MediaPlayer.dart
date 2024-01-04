import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../Services/anilistFetcher.dart';
import '../Settings.dart';

class MediaPlayer extends StatefulWidget {
  final File? videoFile;
  final String? m3u8Url;
  final String? id;
  final String? title;

  const MediaPlayer({
    super.key,
    this.videoFile,
    this.m3u8Url,
    this.id,
    this.title,
  });

  @override
  State<MediaPlayer> createState() => _MediaPlayerState();
}

class _MediaPlayerState extends State<MediaPlayer> {
  late final player = Player();
  late final controller = VideoController(player);

  String currentQuality = "";
  Map quality = {};

  @override
  void initState() {
    print(widget.title);
    readym3u8();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    super.initState();
  }

  readym3u8() {
    AniList.fetchSteamingLinks(widget.id!).then((response) {
      for (Map e in response) {
        quality[e["quality"]] = e["url"];
      }
      player.open(Media(currentQuality != ""
          ? currentQuality
          : quality[settings.qualityChoice] ?? quality["default"]));

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Video(controller: controller));
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }
}
