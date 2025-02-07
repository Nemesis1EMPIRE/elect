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
  String? videoPath;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  Future<void> _loadVideo() async {
    final tempDir = await getTemporaryDirectory();
    final tempVideoFile = File("${tempDir.path}/video.mp4");

    // Vérifier si la vidéo existe déjà dans le répertoire temporaire
    if (!await tempVideoFile.exists()) {
      // Charger la vidéo depuis les assets
      final byteData = await rootBundle.load("assets/vid/video.mp4");
      await tempVideoFile.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
    }

    // Initialiser le contrôleur vidéo une fois le fichier prêt
    setState(() {
      videoPath = tempVideoFile.path;
      _controller = VideoPlayerController.file(tempVideoFile)
        ..initialize().then((_) {
          setState(() {});
          _controller.play();  // Lancer la lecture de la vidéo une fois initialisée
        });
    });
  }

  @override
  void dispose() {
    // Libérer les ressources du contrôleur vidéo lors de la destruction de l'écran
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lecture Vidéo")),
      body: videoPath == null
          ? const Center(child: CircularProgressIndicator())  // Afficher un indicateur de chargement
          : Center(
              child: SizedBox(
                height: 300, // Hauteur fixée pour éviter une vidéo invisible
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio > 0
                      ? _controller.value.aspectRatio
                      : 16 / 9, // Utiliser 16:9 si aspect ratio est 0
                  child: VideoPlayer(_controller),
                ),
              ),
            ),
    );
  }
}
