import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatefulWidget {
  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late List<VideoPlayerController> _controllers;
  late List<Future<void>> _initializeVideoPlayerFutures;

  @override
  void initState() {
    super.initState();
    // Liste des vidéos à charger
    _controllers = [
      VideoPlayerController.asset('assets/video.mp4'),
      VideoPlayerController.asset('assets/video1.mp4'),
      VideoPlayerController.asset('assets/decryptage.mp4')
    ];
    // Initialisation de toutes les vidéos
    _initializeVideoPlayerFutures = _controllers
        .map((controller) {
          controller.setLooping(true); // Mettre en boucle
          return controller.initialize();
        })
        .toList();
  }

  @override
  void dispose() {
    super.dispose();
    // Dispose de tous les contrôleurs de vidéos
    for (var controller in _controllers) {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('décryptage'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: FutureBuilder(
          // Attendre l'initialisation de toutes les vidéos
          future: Future.wait(_initializeVideoPlayerFutures),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _controllers.map((controller) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width * 2,
                      child: VideoPlayer(controller),
                    );
                  }).toList(),
                ),
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
