import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatelessWidget {
  const VideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 📌 Liste des vidéos stockées dans `assets/`
    List<String> videos = [
      "assets/vid/decryptage.mp4",
      "assets/vid/faq.mp4",
      "assets/vid/vid.mp4",
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vidéos", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: PageView.builder(
        scrollDirection: Axis.horizontal, // 📌 Défilement horizontal
        itemCount: videos.length,
        itemBuilder: (context, index) {
          return VideoPlayerWidget(videoPath: videos[index]);
        },
      ),
    );
  }
}

// 📌 Widget pour afficher une vidéo en plein écran avec lecture automatique
class VideoPlayerWidget extends StatefulWidget {
  final String videoPath;
  const VideoPlayerWidget({super.key, required this.videoPath});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        setState(() {});
        _controller.play(); // 📌 Lecture automatique au chargement
      });
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? GestureDetector(
            onTap: () {
              setState(() {
                _controller.value.isPlaying ? _controller.pause() : _controller.play();
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover, // 📌 Vidéo en plein écran sans déformation
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                ),
                if (!_controller.value.isPlaying)
                  const Icon(Icons.play_circle_fill, size: 80, color: Colors.white),
              ],
            ),
          )
        : const Center(child: CircularProgressIndicator());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
