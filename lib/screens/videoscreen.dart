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
  VideoPlayerController? _controller;
  String? videoPath;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  Future<void> _loadVideo() async {
    try {
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
            setState(() {}); // Met à jour l'interface après l'initialisation
          });
      });
    } catch (e) {
      print("Erreur de chargement de la vidéo : $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lecture Vidéo")),
      body: Center(
        child: videoPath == null || _controller == null || !_controller!.value.isInitialized
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio > 0
                        ? _controller!.value.aspectRatio
                        : 16 / 9,
                    child: VideoPlayer(_controller!),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        ),
                        onPressed: () {
                          setState(() {
                            _controller!.value.isPlaying
                                ? _controller!.pause()
                                : _controller!.play();
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.stop),
                        onPressed: () {
                          setState(() {
                            _controller!.pause();
                            _controller!.seekTo(Duration.zero);
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
