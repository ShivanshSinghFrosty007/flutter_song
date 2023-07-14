import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';

class Player extends StatefulWidget {
  static const id = 'Player';

  final String type;
  final String index;

  const Player({super.key, required this.type, required this.index});

  @override
  _Player createState() => _Player(type: type, index: index);
}

class _Player extends State<Player> {
  final String type;
  String index;

  _Player({required this.type, required this.index});

  String name = "Loading...";
  String image = "Loading...";
  int length = 0;

  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    setAudio(index);

    audioPlayer.onPlayerStateChanged.listen((event) {
      setState(() {
        isPlaying = event == PlayerState.playing;
      });
    });

    audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        this.duration = duration;
      });
    });

    audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        this.position = position;
      });
    });
  }

  @override
  void dispose() {
    if (isPlaying) {
      audioPlayer.pause();
      audioPlayer.dispose();
    }
    super.dispose();
  }

  Future setAudio(String index) async {
    FirebaseDatabase.instance
        .reference()
        .child(type)
        .child(index)
        .onValue
        .listen((event) {
      setState(() {
        audioPlayer.setSourceUrl(event.snapshot.child("song").value.toString());
        name = event.snapshot.child("name").value.toString();
        image = event.snapshot.child("image").value.toString();
        length = event.snapshot.children.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff26201e),
      appBar: AppBar(
        backgroundColor: const Color(0xff181413),
      ),
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffF28080), Color(0xff000000)],
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50.0, bottom: 50.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    image,
                    height: 270,
                    width: 270,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Text(name,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold)),
              Slider(
                  min: 0,
                  max: duration.inSeconds.toDouble(),
                  value: position.inSeconds.toDouble(),
                  onChanged: (value) async {
                    setState(() async {
                      position = Duration(seconds: value.toInt());
                      await audioPlayer.seek(position);
                    });
                  }),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      position.toString().substring(2, 7),
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      duration.toString().substring(2, 7),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: IconButton(
                        onPressed: () {
                          setState(() {
                            if (isPlaying) {
                              audioPlayer.pause();
                              isPlaying = false;
                            }
                            if (index != '-1') {
                              int nextIndex = int.parse(index) - 1;
                              index = nextIndex.toString();
                              setAudio(nextIndex.toString());
                            }
                            position = Duration.zero;
                          });
                        },
                        icon: const Icon(Icons.skip_previous),
                        iconSize: 40),
                  ),
                  CircleAvatar(
                    radius: 30,
                    child: IconButton(
                        onPressed: () {
                          setState(() {
                            if (isPlaying) {
                              audioPlayer.pause();
                              isPlaying = false;
                            } else {
                              audioPlayer.resume();
                              isPlaying = true;
                            }
                          });
                        },
                        icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                        iconSize: 40),
                  ),
                  CircleAvatar(
                    radius: 30,
                    child: IconButton(
                        onPressed: () {
                          setState(() {
                            if (isPlaying) {
                              audioPlayer.pause();
                              isPlaying = false;
                            }
                            if (index != length.toString()) {
                              int nextIndex = int.parse(index) + 1;
                              index = nextIndex.toString();
                              setAudio(nextIndex.toString());
                            }
                            position = Duration.zero;
                          });
                        },
                        icon: const Icon(Icons.skip_next),
                        iconSize: 40),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
