import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:elect241/screens/components/imageview.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  // 📌 Liste des médias (images, vidéos, PDF)
  List<Map<String, String>> feedItems = [
    {"type": "image", "source": "assets/images/election.png", "pdf": "assets/pdfs/date.pdf"},
    {"type": "image", "source": "assets/images/elect.jpeg", "pdf": "assets/pdfs/date.pdf"},
    {"type": "image", "source": "assets/images/elect.png", "pdf": "assets/pdfs/elect.pdf"},
    {"type": "video", "source": "assets/video4.mp4"},
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
            return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: feedItems[index]["type"] == "video"
                  ? VideoWidget(videoPath: feedItems[index]["source"]!)
                  : ImageWidget(imagePath: feedItems[index]["source"]!, pdfPath: feedItems[index]["pdf"]),
            );
          },
        ),
      ),
    );
  }
}

// 📌 Widget pour afficher une image avec redirection vers un PDF
class ImageWidget extends StatelessWidget {
  final String imagePath;
  final String? pdfPath;

  const ImageWidget({required this.imagePath, this.pdfPath, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (pdfPath != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PDFViewScreen(
                pdfPath: pdfPath!,
                title: "Document PDF",
              ),
            ),
          );
        }
      },
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, spreadRadius: 2),
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
    );
  }
}

// 📌 Widget pour afficher une vidéo avec un lecteur
class VideoWidget extends StatefulWidget {
  final String videoPath;

  const VideoWidget({required this.videoPath, super.key});

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
      });
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(_controller),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.black54,
                    onPressed: () {
                      setState(() {
                        _controller.value.isPlaying ? _controller.pause() : _controller.play();
                      });
                    },
                    child: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
                  ),
                ),
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
