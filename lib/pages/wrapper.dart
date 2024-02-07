// ignore_for_file: prefer_const_constructors

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kenji/Model/anime.dart';
import 'package:kenji/components/Cards.dart';
import 'package:kenji/components/MediaPlayer.dart';
import 'package:kenji/pages/Details.dart';
import 'package:kenji/services/anilistFetcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toast/toast.dart';

class Wrapper extends StatefulWidget {
  final Future<List<RecentEps>> r;
  final Future<List<AnimeModel>> t;

  const Wrapper({super.key, required this.r, required this.t});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  List<AnimeModel> data = [];
  static List<RecentEps> recent = [];
  static List<AnimeModel> trending = [];
  static bool hasMore = true;
  bool isLoaded = true;
  bool showsearchbar = false;

  static int recentPage = 1;
  collectData() async {
    recent = await widget.r;
    trending = await widget.t;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    collectData();
  }

  bool clicked = false;

  final TextEditingController _controller = TextEditingController();

  List<Widget> sec1(Size screen) => trending.isNotEmpty
      ? [header("Trending"), trendingCards(context, trending, screen)]
      : [];

  // List<Widget> sec3 = [header("WatchList"), watchListCards()];
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.dark));
    Size screen = MediaQuery.of(context).size;
    List<Widget> sec2 =
        recent.isNotEmpty ? [header("Recent"), recentCards(recent)] : [];
    ToastContext().init(context);

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels ==
                notification.metrics.maxScrollExtent &&
            hasMore &&
            isLoaded) {
          isLoaded = false;
          AniList.fetchRecentEps(page: recentPage).then((value) {
            if (value.isNotEmpty) {
              recent.addAll(value);
              recentPage += 1;
            } else {
              hasMore = false;
              Toast.show("End of the list!");
            }
            setState(() {});
          });
        }
        return true;
      },
      child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text(
              "KENJI",
              style: GoogleFonts.getFont("Potta One",
                  color: Colors.blue, fontSize: 25),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: IconButton(
                    onPressed: () => setState(() {
                          showsearchbar = !showsearchbar;
                        }),
                    icon: Icon(Icons.search)),
              )
            ],
          ),
          backgroundColor: const Color.fromARGB(255, 23, 24, 59),
          body: Stack(
            children: [
              ListView(
                children: [
                  showsearchbar
                      ? AnimatedContainer(
                          duration: Duration(seconds: 200),
                          width: showsearchbar ? 0 : screen.width * 0.6,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 5),
                          alignment: Alignment.center,
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: const Color.fromARGB(151, 85, 85, 250)),
                          child: TextField(
                            onSubmitted: (value) {
                              showModalBottomSheet(
                                      enableDrag: true,
                                      isDismissible: true,
                                      backgroundColor: Colors.transparent,
                                      useSafeArea: true,
                                      showDragHandle: true,
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (context) => Myottomsheet(
                                          items: AniList.searchData(
                                              _controller.text)))
                                  .whenComplete(() => _controller.clear());
                            },
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white),
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                suffix: Container(
                                    width: 30,
                                    height: 50,
                                    padding: EdgeInsets.zero,
                                    child: IconButton(
                                      onPressed: () {
                                        _controller.clear();
                                      },
                                      icon: const Icon(
                                        Icons.cancel_outlined,
                                        color:
                                            Color.fromARGB(255, 227, 218, 218),
                                        size: 22,
                                      ),
                                    )),
                                hintText: "Search ?",
                                border: InputBorder.none,
                                hintStyle: const TextStyle(
                                    fontSize: 16, color: Colors.white)),
                            controller: _controller,
                          ),
                        )
                      : const Center(),
                  ...sec1(screen),
                  ...sec2
                ],
              ),
            ],
          )),
    );
  }
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
                        height: 100,
                        alignment: Alignment.bottomCenter,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                              Color.fromARGB(49, 23, 24, 59),
                              Color.fromARGB(190, 23, 24, 59),
                            ])),
                        child: Text(
                          e.title,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
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
          viewportFraction: 0.9));
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          alignment: Alignment.bottomCenter,
          height: double.maxFinite,
          width: double.maxFinite,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(49, 23, 24, 59),
                    Color.fromARGB(190, 23, 24, 59),
                  ])),
          child: Text(
            recent[index].title,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ),
        Positioned(
            right: 0,
            top: 0,
            child: IconButton(
                onPressed: () {}, icon: Icon(Icons.info_outline_rounded))),
        Center(
            child: Container(
          decoration: gradientBox(),
          child: TextButton(
              child: Text(
                "Eps ${recent[index].episodeNumber + 1}",
                textAlign: TextAlign.center,
              ),
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

class Myottomsheet extends StatefulWidget {
  final Future<List<AnimeModel>> items;
  const Myottomsheet({super.key, required this.items});

  @override
  State<Myottomsheet> createState() => _MybottomsheetState();
}

class _MybottomsheetState extends State<Myottomsheet> {
  late Size screen;
  final TextEditingController _controller = TextEditingController();
  static List<AnimeModel> data = [];

  @override
  void initState() {
    super.initState();
    widget.items.then((value) {
      setState(() => data = value);
    });
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
        child: data.isNotEmpty
            ? ListView(
                physics: const ClampingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                children: [
                  data.isNotEmpty ? Cards(data, "geners") : const Center(),
                  data.isNotEmpty
                      ? const Center(
                          child: Text(
                            "Toasty ©️",
                            style: TextStyle(
                                color: Color.fromARGB(193, 158, 158, 158)),
                          ),
                        )
                      : const Center()
                ],
              )
            : const Center(
                child: CircularProgressIndicator(),
              ));
  }
}

BoxDecoration gradientBox() => BoxDecoration(
      borderRadius: BorderRadius.circular(10.0),
      boxShadow: const [
        BoxShadow(
          color: Color(0x000ffeee),
          blurRadius: 20.0,
        ),
      ],
      gradient: LinearGradient(
        colors: const [
          Color.fromARGB(118, 141, 84, 200),
          Color.fromARGB(148, 71, 119, 200)
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ),
    );
