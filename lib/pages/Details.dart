// ignore_for_file: prefer_const_constructors

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kenji/Model/anime.dart';
import 'package:kenji/services/anilistFetcher.dart';
import 'package:toast/toast.dart';

import '../components/MediaPlayer.dart';

class Details extends StatefulWidget {
  final AnimeModel item;
  const Details(this.item, {super.key});

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  late AnimeModel data;
  bool showmore = false;
  List<EpisodeModel> episodeData = [];
  // final TextEditingController _textEditingController = TextEditingController();
  bool isLoaded = false;
  bool saved = false;

  bool hasNoImage = false;

  bool isDub = false;

  static Map<String, AnimeModel> tempAniDetails = {};

  List<EpisodeModel> showEps = [];

  fetchData(bool isDub) {
    AniList.fetchInfo(data.aniId, provider: "gogoanime", dub: isDub)
        .then((value) {
      data = value;
      if (value.episodes.isEmpty) {
        Toast.show("Not ${isDub ? "dub" : "sub"} not available!");
      } else {
        Toast.show("Loaded");
        episodeData = value.episodes;
        isLoaded = true;
        splitData(value);
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    super.initState();

    data = widget.item;
    if (tempAniDetails.containsKey(data.aniId)) {
      data = tempAniDetails[data.aniId]!;
      isLoaded = true;
      splitData(data);
    }
    fetchData(isDub);
    setState(() {});
  }

  splitData(AnimeModel data) {
    episodeData = data.episodes.reversed.toList().cast<EpisodeModel>();
    if (episodeData.isNotEmpty &&
        data.type.toLowerCase() != "movie" &&
        episodeData.length > 2) {
      hasNoImage = episodeData[0].image == episodeData[1].image ? true : false;
    }
    showEps =
        episodeData.length > 15 ? episodeData.sublist(0, 15) : episodeData;
  }

  @override
  Widget build(BuildContext context) {
    final widthCount = (MediaQuery.of(context).size.width ~/ 300).toInt();
    const minCount = 4;
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent));
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 8, 8, 45),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels ==
                  notification.metrics.maxScrollExtent &&
              showEps.length != episodeData.length &&
              episodeData.length > 15) {
            showEps.addAll(episodeData.sublist(
                showEps.length,
                showEps.length + 15 > episodeData.length
                    ? null
                    : showEps.length + 15));
            // print("${showEps.length}, ${episodeData.length}");
            setState(() {});
          }
          return true;
        },
        child: ListView(padding: EdgeInsets.zero, children: [
          SizedBox(
            height: 300,
            child: Stack(
              children: [
                Container(
                  width: screen.width,
                  height: 200,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: NetworkImage(
                        data.cover != "" ? data.cover : data.image),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      Container(
                          color: Colors.amber,
                          alignment: Alignment.center,
                          child: const Text(
                            'Whoops!',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ));
                    },
                  )),
                ),
                Container(
                  height: 210,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromRGBO(8, 8, 45, 0),
                          Color.fromRGBO(8, 8, 45, 0.7),
                          Color.fromRGBO(8, 8, 45, 1),
                        ]),
                  ),
                  width: screen.width,
                ),
                // Positioned(
                //     right: 10,
                //     top: 40,
                //     child: isLoaded
                //         ? InkWell(
                //             radius: 0,
                //             onTap: () {
                //               setState(() {
                //                 if (saved) {
                //                   removeItem(data.aniId).then((value) {
                //                     print("removed? $value");
                //                   });
                //                   saved = false;
                //                 } else {
                //                   saveItem(data).then((value) {
                //                     print("saved? $value");
                //                   });
                //                   saved = true;
                //                 }
                //               });
                //             },
                //             child: Container(
                //               padding: const EdgeInsets.symmetric(
                //                   horizontal: 10, vertical: 5),
                //               decoration: BoxDecoration(
                //                   color:
                //                       const Color.fromARGB(168, 104, 58, 183),
                //                   borderRadius: BorderRadius.circular(8)),
                //               child: Text(
                //                 saved ? "Saved" : "WatchLater",
                //                 style: TextStyle(color: Colors.white),
                //               ),
                //             ))
                //         : const Center()),
                screen.width > 600
                    ? Positioned(
                        left: 20,
                        top: 35,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(168, 104, 58, 183),
                                  borderRadius: BorderRadius.circular(50)),
                              child: const Icon(Icons.close)),
                        ))
                    : const Center(),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(data.image, width: 150),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                data.title,
                maxLines: 3,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 20,
              runSpacing: 10,
              children: [
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.deepPurple),
                    child: Text(
                        "Ep ${data.episodes.length}/${data.totalEpisodes}",
                        style: TextStyle(color: Colors.white))),
                Text(
                  data.type,
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  data.subOrDub.toUpperCase(),
                  style: TextStyle(color: Colors.white),
                ),
                isLoaded
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            // if (saved) {
                            //   laterbox.delete(data.aniId);
                            //   saved = false;
                            // } else {
                            //   laterbox.put(data.aniId, data);
                            //   saved = true;
                            // }
                          });
                        },
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                color: const Color.fromARGB(168, 104, 58, 183),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              saved ? "Saved" : "WatchLater",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ))
                    : const Center(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: data.geners
                  .split(",")
                  .map((e) => Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(width: 1, color: Colors.white)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Text(e, style: TextStyle(color: Colors.white)),
                      ))
                  .cast<Widget>()
                  .toList(),
            ),
          ),
          isLoaded && data.nextAiringEpisode != 0
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      const Text("Next Episode in ",
                          style: TextStyle(color: Colors.white)),
                      Text(
                        "${DateTime.fromMillisecondsSinceEpoch(data.nextAiringEpisode * 1000).difference(DateTime.now()).inDays} Days",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent),
                      )
                    ],
                  ))
              : const Center(),
          data.desc != ""
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  margin: const EdgeInsets.only(bottom: 10),
                  width: screen.width,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    children: [
                      const Text(
                        "Description",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.greenAccent),
                      ),
                      SizedBox(
                        height: showmore || data.desc.length < 30 ? null : 100,
                        child: Text(data.desc,
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                      ),
                      !showmore
                          ? TextButton(
                              onPressed: () {
                                showmore = !showmore;
                                setState(() {});
                              },
                              child: const Text("More"))
                          : const Center()
                    ],
                  ),
                )
              : const Center(),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 20),
                child: const Text(
                  "Episodes",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent),
                ),
              ),
              InkWell(
                enableFeedback: true,
                mouseCursor: SystemMouseCursors.click,
                onTap: () {
                  Feedback.forTap(context);
                  Toast.show("Fetching!");
                  isDub = !isDub;
                  print("isdub $isDub");
                  fetchData(isDub);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: const Color.fromARGB(168, 104, 58, 183)),
                  margin: const EdgeInsets.only(left: 10),
                  child: Text(
                    '${isDub ? "Dub" : "Sub"} - ${data.episodes.length} ',
                    style: GoogleFonts.getFont("Nova Square",
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          episodeData.isEmpty
              ? isLoaded
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          "No Episodes found",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    )
              : GridView.builder(
                  padding: const EdgeInsets.only(bottom: 10, top: 10),
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: showEps.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisExtent: hasNoImage ? 100 : 150,
                      crossAxisCount:
                          screen.width > 600 ? min(widthCount, minCount) : 1),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MediaPlayer(
                                  id: showEps[index].id,
                                  title: showEps[index].title),
                            ));
                      },
                      child: hasNoImage
                          ? Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color:
                                      const Color.fromARGB(144, 123, 128, 164)),
                              child: Center(
                                  child: Text(
                                "Episode ${index + 1}",
                                textAlign: TextAlign.center,
                              )),
                            )
                          : Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  height: hasNoImage ? 100 : 150,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: hasNoImage
                                          ? null
                                          : DecorationImage(
                                              image: NetworkImage(
                                                  showEps[index].image),
                                              fit: BoxFit.cover)),
                                ),
                                Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    height: hasNoImage ? 101 : 151,
                                    decoration: hasNoImage
                                        ? BoxDecoration(
                                            color: const Color.fromARGB(
                                                112, 0, 0, 0),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          )
                                        : BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            gradient: const LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Color.fromRGBO(31, 27, 36, 0),
                                                  Color.fromRGBO(31, 27, 36, 1),
                                                ])),
                                    child: Container(
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        decoration: const BoxDecoration(
                                            color: Color.fromRGBO(
                                                31, 27, 36, 0.3)),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              showEps[index].title,
                                              maxLines: 1,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  color: Colors.white),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              showEps[index].description,
                                              maxLines: 2,
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Colors.white),
                                            )
                                          ],
                                        ))),
                                hasNoImage
                                    ? const Center()
                                    : Positioned(
                                        left: 20,
                                        top: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(8),
                                                  bottomRight:
                                                      Radius.circular(8)),
                                              color: Color.fromARGB(
                                                  141, 68, 137, 255)),
                                          child: Text(
                                            showEps[index].number.toString(),
                                            style: const TextStyle(
                                                color: Colors.greenAccent),
                                          ),
                                        ))
                              ],
                            ),
                    );
                  },
                ),
        ]),
      ),
    );
  }
}
