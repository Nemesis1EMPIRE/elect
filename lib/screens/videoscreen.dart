import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  final List<String> videoPaths = [
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
    _initializeControllers = _controllers.map((controller) {
      return controller.initialize().then((_) {
        setState(() {}); // 📌 Rafraîchit l'interface après initialisation
      });
    }).toList();

    // Activer la lecture automatique en boucle
    for (var controller in _controllers) {
      controller.setLooping(true);
      controller.setVolume(1.0);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecteur Vidéo Défilant'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder(
        future: Future.wait(_initializeControllers), // 📌 Attendre l'initialisation
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return PageView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _controllers.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _controllers[index].value.isPlaying
                          ? _controllers[index].pause()
                          : _controllers[index].play();
                    });
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: _controllers[index].value.aspectRatio,
                        child: VideoPlayer(_controllers[index]),
                      ),
                      if (!_controllers[index].value.isPlaying)
                        const Icon(Icons.play_circle_fill, size: 80, color: Colors.white),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
