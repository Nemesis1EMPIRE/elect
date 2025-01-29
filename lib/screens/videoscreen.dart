import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late VideoPlayerController _controller;
  String? videoPath; // 📌 Stocke le chemin local de la vidéo

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  Future<void> _loadVideo() async {
    // 📌 Copier la vidéo depuis les assets vers le stockage temporaire
    final tempDir = await getTemporaryDirectory();
    final tempVideoFile = File("${tempDir.path}/video.mp4");

    if (!await tempVideoFile.exists()) {
      final byteData = await rootBundle.load("assets/vid/video.mp4");
      await tempVideoFile.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
    }

    setState(() {
      videoPath = tempVideoFile.path;
      _controller = VideoPlayerController.file(tempVideoFile)
        ..initialize().then((_) {
          setState(() {});
          _controller.play();
        });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lecture Vidéo")),
      body: videoPath == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ),
    );
  }
}
