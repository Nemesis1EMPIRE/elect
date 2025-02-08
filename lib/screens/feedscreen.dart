import 'package:flutter/material.dart';
import 'package:elect241/screens/components/imageview.dart';
import 'package:video_player/video_player.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<Map<String, String>> feedItems = [
    {"image": "assets/images/election.png", "pdf": "assets/pdfs/date.pdf"},
    {"image": "assets/images/elect.jpeg", "pdf": "assets/pdfs/date.pdf"},
    {"image": "assets/images/elect.png", "pdf": "assets/pdfs/elect.pdf"},
    {"image": "assets/images/all.png", "pdf": "assets/pdfs/elect.pdf"},
    {"video": "assets/videos/sample.mp4"}, // 📌 Ajout d'une vidéo locale
    {"video": "https://www.example.com/video.mp4"} // 📌 Vidéo en ligne
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Actualités Politiques", style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: feedItems.length,
          itemBuilder: (context, index) {
            final item = feedItems[index];

            // Vérifie si c'est une vidéo ou une image
            if (item.containsKey("video")) {
              return VideoItem(videoUrl: item["video"]!);
            } else {
              return ImageItem(imagePath: item["image"]!, pdfPath: item["pdf"]!);
            }
          },
        ),
      ),
    );
  }
}

// 📌 Widget pour afficher une image avec navigation vers un PDF
class ImageItem extends StatelessWidget {
  final String imagePath;
  final String pdfPath;

  const ImageItem({required this.imagePath, required this.pdfPath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PDFViewScreen(
                pdfPath: pdfPath,
                title: "Document PDF",
              ),
            ),
          );
        },
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                spreadRadius: 2,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            imagePath,
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

// 📌 Widget pour afficher une vidéo
class VideoItem extends StatefulWidget {
  final String videoUrl;

  const VideoItem({required this.videoUrl});

  @override
  _VideoItemState createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();

    // Détection de la source locale ou en ligne
    if (widget.videoUrl.startsWith("http")) {
      _controller = VideoPlayerController.network(widget.videoUrl);
    } else {
      _controller = VideoPlayerController.asset(widget.videoUrl);
    }

    _controller.initialize().then((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isPlaying ? _controller.pause() : _controller.play();
            _isPlaying = !_isPlaying;
          });
        },
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                spreadRadius: 2,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: _controller.value.isInitialized ? _controller.value.aspectRatio : 16 / 9,
                child: _controller.value.isInitialized
                    ? VideoPlayer(_controller)
                    : const Center(child: CircularProgressIndicator()),
              ),
              if (!_isPlaying)
                Icon(
                  Icons.play_circle_fill,
                  color: Colors.white.withOpacity(0.8),
                  size: 60,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
