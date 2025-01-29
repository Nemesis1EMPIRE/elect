import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatefulWidget {
  @override
  _VideoScreen createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  List<String> videoPaths = [
    'assets/vid/video1.mp4',
    'assets/vid/video.mp4',
  ];

  late List<VideoPlayerController> _controllers;
  late List<Future<void>> _initializeControllers;

  @override
  void initState() {
    super.initState();

    // Initialisation des contrôleurs vidéo
    _controllers = videoPaths.map((path) => VideoPlayerController.asset(path)).toList();
    _initializeControllers = _controllers.map((controller) => controller.initialize()).toList();

    // Activer la lecture en boucle et le son pour chaque vidéo
    for (var controller in _controllers) {
      controller.setLooping(true);
      controller.setVolume(1.0);
    }
  }

  @override
  void dispose() {
    // Libérer la mémoire des vidéos
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lecteur Vidéo Défilant'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder(
        future: Future.wait(_initializeControllers), // Attendre l'initialisation de toutes les vidéos
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return PageView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _controllers.length,
              itemBuilder: (context, index) {
                return Center(
                  child: AspectRatio(
                    aspectRatio: _controllers[index].value.aspectRatio,
                    child: VideoPlayer(_controllers[index]),
                  ),
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator()); // Affiche un loader pendant le chargement
          }
        },
      ),
    );
  }
}
