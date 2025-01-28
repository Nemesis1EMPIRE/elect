import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late List<VideoPlayerController> _controllers;
  late List<Future<void>> _initializeVideoPlayerFutures;

  @override
  void initState() {
    super.initState();
    _controllers = [
      VideoPlayerController.asset('assets/video.mp4'),
      VideoPlayerController.asset('assets/video1.mp4'),
      VideoPlayerController.asset('assets/decryptage.mp4')
    ];
    _initializeVideoPlayerFutures = _controllers.map((controller) {
      controller.setLooping(true); // 📌 Met en boucle
      return controller.initialize().then((_) {
        setState(() {}); // 📌 Met à jour l'UI après initialisation
      });
    }).toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose(); // 📌 `super.dispose()` doit être appelé en dernier
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40), // 📌 Réduction de l'AppBar
        child: AppBar(
          title: const Text("Décryptage", style: TextStyle(color: Colors.white, fontSize: 18)),
          backgroundColor: Colors.blue,
        ),
      ),
      body: FutureBuilder(
        future: Future.wait(_initializeVideoPlayerFutures), // 📌 Attente de toutes les vidéos
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return PageView.builder(
              scrollDirection: Axis.horizontal, // 📌 Swipe horizontal
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
