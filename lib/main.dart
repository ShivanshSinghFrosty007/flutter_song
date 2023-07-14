import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

import 'Player.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'song',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AnimatedSplashScreen(
          splash: Image.network(
              "https://media.istockphoto.com/id/1203005440/vector/headphones-icon-logo-isolated-on-white-background-earphones-icon.jpg?s=612x612&w=0&k=20&c=tptRd5CLSXrlfSGS-xDwY5uB7IP_YN3SdI5wtG8Cwbg="),
          duration: 2500,
          splashTransition: SplashTransition.fadeTransition,
          animationDuration: const Duration(seconds: 2),
          backgroundColor: Colors.white,
          nextScreen: const MyHomePage(title: "splash")),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final dbRef = FirebaseDatabase.instance.reference();
  late TabController tabController;
  final searchFilter = TextEditingController();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      if (tabController.indexIsChanging) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xff26201e),
        appBar: AppBar(
          backgroundColor: const Color(0xff181413),
        ),
        body: TabBarView(controller: tabController, children: [
          Container(
            child: bodyWid(),
          ),
          Container(
            child: SearchLayout(),
          ),
        ]),
        bottomNavigationBar:
            TabBar(controller: tabController, tabs: const [
          Tab(
            icon: Icon(Icons.home),
          ),
          Tab(
            icon: Icon(Icons.search),
          ),
        ]),
      ),
    );
  }

  Widget SearchLayout() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Container(
              margin:
                  const EdgeInsets.only(top: 20, left: 5, right: 5, bottom: 30),
              child: TextField(
                controller: searchFilter,
                onChanged: (text) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Search',
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(width: 2, color: Colors.grey),
                      borderRadius: BorderRadius.circular(10)),
                  border: OutlineInputBorder(
                      borderSide:
                          const BorderSide(width: 2, color: Colors.white),
                      borderRadius: BorderRadius.circular(10)),
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
            ),
            Expanded(
                child:
                    FirebaseListFetchVertical('search', dbRef.child('search')))
          ],
        ),
      ),
    );
  }

  Widget bodyWid() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(left: 15, top: 20, bottom: 40),
              child: Text("Good Morning",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold)),
            ),
            HorizontalList('recommend'),
            HorizontalList('trending'),
            HorizontalList('popular'),
          ],
        ),
      ),
    );
  }

  Widget HorizontalList(String type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(type.capitalize(),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 220,
          child: FirebaseListFetch(type, dbRef.child(type)),
        ),
      ],
    );
  }

  Widget FirebaseListFetch(String type, Query reference) {
    return FirebaseAnimatedList(
      scrollDirection: Axis.horizontal,
      query: reference,
      itemBuilder: (context, snapshot, animation, index) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Card(
            color: const Color(0xff26201e),
            elevation: 10,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: GestureDetector(
              onTap: () {
                dbRef.child(index.toString()).onValue.listen((event) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Player(
                            type: type,
                            index: index.toString(),
                          )));
                  // builder: (context) => Player(name: name, image: image, song: song)));
                });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(
                        snapshot.child("image").value.toString(),
                        fit: BoxFit.fill,
                        height: 150,
                        width: 150),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(snapshot.child("name").value.toString(),
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.left),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget FirebaseListFetchVertical(String type, Query reference) {
    return FirebaseAnimatedList(
      query: reference,
      itemBuilder: (context, snapshot, animation, index) {
        if (searchFilter.text.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Card(
              color: const Color(0xff26201e),
              elevation: 10,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: GestureDetector(
                onTap: () {
                  dbRef.child(index.toString()).onValue.listen((event) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => Player(
                              type: type,
                              index: index.toString(),
                            )));
                    // builder: (context) => Player(name: name, image: image, song: song)));
                  });
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.network(
                          snapshot.child("image").value.toString(),
                          fit: BoxFit.fill,
                          height: 100,
                          width: 100),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(snapshot.child("name").value.toString(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (snapshot
            .child('name')
            .value
            .toString()
            .toLowerCase()
            .contains(searchFilter.text.toLowerCase())) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Card(
              color: const Color(0xff26201e),
              elevation: 10,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: GestureDetector(
                onTap: () {
                  dbRef.child(index.toString()).onValue.listen((event) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => Player(
                              type: type,
                              index: index.toString(),
                            )));
                    // builder: (context) => Player(name: name, image: image, song: song)));
                  });
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.network(
                          snapshot.child("image").value.toString(),
                          fit: BoxFit.fill,
                          height: 100,
                          width: 100),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(snapshot.child("name").value.toString(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
