import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kenji/Model/anime.dart';
import 'package:kenji/Settings.dart';
import 'package:kenji/components/Cards.dart';
import 'package:kenji/components/MediaPlayer.dart';
import 'package:kenji/pages/Details.dart';
import 'package:kenji/services/anilistFetcher.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  bool showSearch = false;
  bool showRecent = true;
  List<AnimeModel> data = [];
  static List<RecentEps> recent = [];
  static List<AnimeModel> trending = [];
  bool isSearchActive = false;
  bool loaded = false;

  late PersistentBottomSheetController _bottomcontroller;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  update() {
    setState(() {});
  }

  Future<void> fetchData(r, t) async {
    recent = await r;
    trending = await t;
    setState(() {
      loaded = true;
    });
    // AniList.fetchRecentEps(page: 1)
    //     .then((value) => {recent = value, update(), print(value.length)});
    // AniList.Trending(page: 1)
    //     .then((value) => {trending = value, update(), print(value.length)});
  }

  @override
  void initState() {
    super.initState();
    var r = AniList.fetchRecentEps(page: 1);
    var t = AniList.Trending(page: 1);
    fetchData(r, t);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.dark));
    Size screen = MediaQuery.of(context).size;

    List<Widget> sec1 = trending.isNotEmpty
        ? [header("Trending"), trendingCards(context, trending, screen)]
        : [];
    List<Widget> sec2 =
        recent.isNotEmpty ? [header("Recent"), recentCards(recent)] : [];
    return Scaffold(
        floatingActionButton: !isSearchActive
            ? IconButton(
                onPressed: () {
                  showModalBottomSheet(
                      enableDrag: true,
                      isDismissible: true,
                      backgroundColor: Colors.transparent,
                      useSafeArea: true,
                      showDragHandle: true,
                      isScrollControlled: true,
                      context: context,
                      builder: (context) => const Myottomsheet());
                },
                icon: const Icon(Icons.search))
            : null,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: TextButton(
            style: const ButtonStyle(splashFactory: NoSplash.splashFactory),
            child: Text(
              "KENJI",
              style: GoogleFonts.getFont("Potta One",
                  color: Colors.blue, fontSize: 25),
            ),
            onPressed: () async {
              showSearch = false;
              showRecent = true;
              recent.isEmpty
                  ? AniList.fetchRecentEps(page: 1).then((value) =>
                      {recent = value, update(), print(value.length)})
                  : null;
              setState(() {});
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                dialogBoxForBaseURL(context);
              },
              child: Lottie.network(
                  "https://lottie.host/a72b255d-8611-4168-b3b8-f973547de914/8NvjTXwBX5.json"),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 23, 24, 59),
        body: Stack(
          children: [
            ListView(
              children: [...sec1, ...sec2],
            ),
            // DraggableScrollableSheet(
            //   initialChildSize: 0.25,
            //   builder: (context, scrollController) {
            //     return Container(
            //       alignment: Alignment.center,
            //       padding: const EdgeInsets.only(top: 20),
            //       decoration: const BoxDecoration(
            //           gradient: LinearGradient(
            //               begin: Alignment.bottomCenter,
            //               end: Alignment.topCenter,
            //               colors: [
            //                 Color.fromARGB(255, 23, 24, 59),
            //                 Color.fromARGB(255, 123, 82, 82),
            //               ]),
            //           borderRadius: BorderRadius.only(
            //               topLeft: Radius.circular(20),
            //               topRight: Radius.circular(20))),
            //       child: ListView(
            //         controller: scrollController,
            //         padding: const EdgeInsets.symmetric(
            //             horizontal: 20, vertical: 20),
            //         children: items,
            //       ),
            //     );
            //   },
            // )
          ],
        ));
  }
}

Future<void> dialogBoxForBaseURL(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext ctx) {
      TextEditingController baseCont = TextEditingController();
      return AlertDialog(
        backgroundColor: const Color.fromARGB(255, 8, 8, 45),
        title: const Text(
          "Change baseURL?",
          style: TextStyle(fontSize: 16),
        ),
        content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color.fromARGB(151, 85, 85, 250)),
            child: TextField(
              controller: baseCont,
              decoration: const InputDecoration(border: InputBorder.none),
            )),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          GestureDetector(
            onTap: () async {
              AniList.updateurl(baseCont.text);
              await SharedPreferences.getInstance().then((value) => {
                    value.setString("baseURL", baseCont.text),
                    print(settings.baseURL),
                    Navigator.pop(ctx)
                  });
            },
            child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color.fromARGB(192, 33, 149, 243)),
                child: const Text(
                  "Submit",
                  style: TextStyle(
                      color: Colors.white70, fontWeight: FontWeight.bold),
                )),
          )
        ],
      );
    },
  );
}

header(String text) {
  return Container(
    margin: const EdgeInsets.only(left: 20, top: 20),
    alignment: Alignment.centerLeft,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(right: 10),
          color: Colors.red,
          width: 5,
          height: 20,
        ),
        Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color.fromARGB(255, 229, 223, 223)))
      ],
    ),
  );
}

trendingCards(BuildContext ctx, List<AnimeModel> trending, Size screen) {
  return CarouselSlider(
      items: trending
          .map((e) => GestureDetector(
                onTap: () => Navigator.push(
                    ctx,
                    MaterialPageRoute(
                      builder: (context) => Details(e),
                    )),
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        width: screen.width,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                                image: NetworkImage(e.cover),
                                fit: BoxFit.cover)),
                      ),
                      Container(
                        alignment: Alignment.bottomCenter,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        width: screen.width,
                        decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                              Color.fromARGB(119, 23, 24, 59),
                              Color.fromARGB(255, 23, 24, 59),
                            ])),
                        child: Text(
                          e.title,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ))
          .cast<Widget>()
          .toList(),
      options: CarouselOptions(
        enlargeStrategy: CenterPageEnlargeStrategy.scale,
        autoPlay: true,
        enlargeCenterPage: true,
      ));
}

recentCards(List<RecentEps> recent) {
  return GridView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    shrinkWrap: true,
    physics: const ClampingScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        mainAxisExtent: 250,
        crossAxisSpacing: 10),
    itemCount: recent.length,
    itemBuilder: (context, index) {
      return Stack(children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(recent[index].image),
                fit: BoxFit.cover,
              )),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.bottomCenter,
          height: double.maxFinite,
          width: double.maxFinite,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(119, 23, 24, 59),
                    Color.fromARGB(255, 23, 24, 59),
                  ])),
          child: Text(
            recent[index].title,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        Container(
          width: 40,
          decoration: const BoxDecoration(
              color: Color.fromARGB(107, 33, 149, 243),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8))),
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            recent[index].episodeNumber.toString(),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        Center(
            child: Container(
          decoration: BoxDecoration(
              color: const Color.fromARGB(87, 155, 39, 176),
              borderRadius: BorderRadius.circular(50)),
          child: IconButton(
              icon: const Icon(Icons.play_arrow_rounded),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MediaPlayer(
                          id: recent[index].episodeId,
                          title: recent[index].title),
                    ));
              }),
        ))
      ]);
    },
  );
}

// class RecentCards extends StatelessWidget {
//   final List<RecentEps> recent;
//   const RecentCards({super.key, required this.recent});
//   @override
//   Widget build(BuildContext context) {
//     Size screen = MediaQuery.of(context).size;
//     return ListView.builder(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       shrinkWrap: true,
//       physics: const ClampingScrollPhysics(),
//       itemCount: recent.length,
//       itemBuilder: (context, index) {
//         return Container(
//           margin: const EdgeInsets.symmetric(vertical: 5),
//           child: Stack(
//             children: [
//               Container(
//                 width: screen.width,
//                 height: 120,
//                 decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8),
//                     image: DecorationImage(
//                         image: NetworkImage(recent[index].image),
//                         fit: BoxFit.cover,
//                         alignment: Alignment.center)),
//               ),
//               Container(
//                 width: screen.width,
//                 height: 120,
//                 decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8),
//                     color: const Color.fromARGB(120, 23, 24, 59)),
//               ),
//               Container(
//                 alignment: Alignment.center,
//                 padding: const EdgeInsets.symmetric(horizontal: 10),
//                 width: screen.width,
//                 height: 120,
//                 decoration: const BoxDecoration(),
//                 child: Text(
//                   recent[index].title.length > 50
//                       ? '${recent[index].title.substring(0, 50)}...'
//                       : recent[index].title,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Color.fromARGB(255, 155, 237, 139),
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//               Positioned(
//                   child: Container(
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                 decoration: const BoxDecoration(
//                     borderRadius:
//                         BorderRadius.only(topLeft: Radius.circular(8)),
//                     color: Color.fromARGB(118, 67, 64, 211)),
//                 child: Text(
//                   recent[index].episodeNumber.toString(),
//                   style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white),
//                 ),
//               )),
//               Positioned(
//                   bottom: 5,
//                   right: 5,
//                   child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 10, vertical: 10),
//                       decoration: BoxDecoration(
//                           color: const Color.fromARGB(255, 39, 39, 176),
//                           borderRadius: BorderRadius.circular(50)),
//                       child: InkWell(
//                           child: const Icon(
//                             Icons.play_arrow,
//                             color: Colors.white,
//                           ),
//                           onTap: () {
//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => MediaPlayer(
//                                       id: recent[index].episodeId,
//                                       title: recent[index].title),
//                                 ));
//                           })))
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

class Myottomsheet extends StatefulWidget {
  // final List<Widget> items;
  const Myottomsheet({super.key});

  @override
  State<Myottomsheet> createState() => _MybottomsheetState();
}

class _MybottomsheetState extends State<Myottomsheet> {
  late Size screen;
  static bool showSearch = false;
  final TextEditingController _controller = TextEditingController();
  static List<AnimeModel> data = [];
  bool clicked = false;

  @override
  void initState() {
    super.initState();
    _controller.notifyListeners();
  }

  @override
  void dispose() {
    _controller.dispose();
    data = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size;
    return Container(
      height: data.isEmpty
          ? clicked
              ? 400
              : 200
          : null,
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 20),
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Color.fromARGB(255, 23, 24, 59),
                Color.fromARGB(255, 123, 82, 82),
              ]),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: ListView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          Container(
            alignment: Alignment.center,
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color.fromARGB(151, 85, 85, 250)),
            child: TextField(
              onTap: () => clicked = true,
              onSubmitted: (value) {
                showSearch = true;
                setState(() {});
                AniList.searchData(_controller.text)
                    .then((value) => setState(() {
                          data = value;
                        }));
              },
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  suffix: Container(
                      width: 30,
                      height: 50,
                      padding: EdgeInsets.zero,
                      child: IconButton(
                        onPressed: () {
                          _controller.clear();
                          data = [];
                          showSearch = !showSearch;
                        },
                        icon: const Icon(
                          Icons.cancel_outlined,
                          color: Color.fromARGB(255, 227, 218, 218),
                          size: 22,
                        ),
                      )),
                  hintText: "What do you want 🤨?",
                  border: InputBorder.none,
                  hintStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              controller: _controller,
            ),
          ),
          !showSearch || data.isEmpty
              ? SizedBox(
                  height: 110,
                  child: Lottie.network(
                    "https://lottie.host/f351a2bb-867a-479c-8447-d9a44088965d/fHvkOukxBm.json",
                  ),
                )
              : const Center(),
          data.isNotEmpty ? Cards(data, "geners") : const Center(),
          data.isNotEmpty
              ? const Center(
                  child: Text(
                    "Toasty ©️",
                    style: TextStyle(color: Color.fromARGB(193, 158, 158, 158)),
                  ),
                )
              : const Center()
        ],
      ),
    );
  }
}
