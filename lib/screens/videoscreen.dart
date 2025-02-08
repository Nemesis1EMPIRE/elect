import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class VideoListScreen extends StatefulWidget {
  const VideoListScreen({super.key});

  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  List<Map<String, String>> videos = [
    {"title": "Nature", "path": "assets/vid/video1.mp4", "thumbnail": "assets/images/elect.png"},
    {"title": "Ville", "path": "assets/vid/video2.mp4", "thumbnail": "assets/images/elect.png"},
    {"title": "Mer", "path": "assets/vid/video3.mp4", "thumbnail": "assets/images/elect.png"},
  ];

  List<Map<String, String>> filteredVideos = [];
  
  @override
  void initState() {
    super.initState();
    filteredVideos = videos;
  }

  void _filterVideos(String query) {
    setState(() {
      filteredVideos = videos.where((video) {
        return video["title"]!.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<String> _loadVideo(String assetPath) async {
    final tempDir = await getTemporaryDirectory();
    final tempVideoFile = File("${tempDir.path}/${assetPath.split('/').last}");
    
    if (!await tempVideoFile.exists()) {
      final byteData = await rootBundle.load(assetPath);
      await tempVideoFile.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
    }

    return tempVideoFile.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Liste des Vidéos")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Rechercher une vidéo...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: _filterVideos,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredVideos.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Image.asset(
                    filteredVideos[index]["thumbnail"]!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                  title: Text(filteredVideos[index]["title"]!),
                  onTap: () async {
                    String videoPath = await _loadVideo(filteredVideos[index]["path"]!);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoPlayerScreen(videoPath: videoPath),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;

  const VideoPlayerScreen({super.key, required this.videoPath});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
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
      body: Center(
        child: _controller.value.isInitialized
            ? Stack(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        ),
                        onPressed: () {
                          setState(() {
                            _controller.value.isPlaying ? _controller.pause() : _controller.play();
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.stop),
                        onPressed: () {
                          setState(() {
                            _controller.pause();
                            _controller.seekTo(Duration.zero);
                          });
                        },
                      ),
                    ],
                  ),
                ],
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
