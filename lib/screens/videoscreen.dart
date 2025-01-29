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
    _controllers = videoPaths.map((path) => VideoPlayerController.asset(path)).toList();
    _initializeControllers = _controllers.map((controller) => controller.initialize()).toList();

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
        title: const Text("Décryptage", style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder(
        future: Future.wait(_initializeControllers),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return PageView.builder(
              itemCount: _controllers.length,
              itemBuilder: (context, index) {
                final controller = _controllers[index];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      controller.value.isPlaying ? controller.pause() : controller.play();
                    });
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: controller.value.aspectRatio,
                        child: VideoPlayer(controller),
                      ),
                      if (!controller.value.isPlaying)
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
