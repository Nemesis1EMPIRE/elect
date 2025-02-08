import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';



class VideoListPage extends StatefulWidget {
  @override
  _VideoListPageState createState() => _VideoListPageState();
}

class _VideoListPageState extends State<VideoListPage> {
  final List<Map<String, String>> videos = [
    {
      'title': 'test',
      'url': 'https://drive.google.com/file/d/1IMi6oa83sQ_eVhaOJGp17IQPTabKJFuV/view?usp=sharing',
      'thumbnail': 'assets/images/elect.png',
    },
    {
      'title': 'Vidéo 2',
      'url': 'assets/vid/video.mp4',
      'thumbnail': 'assets/images/elect.jpeg',
    },
    {
      'title': 'Vidéo 3',
      'url': 'https://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_5mb.mp4',
      'thumbnail': 'https://via.placeholder.com/150',
    },
    {
      'title': 'Vidéo 4',
      'url': 'https://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_10mb.mp4',
      'thumbnail': 'https://via.placeholder.com/150',
    },
  ];

  List<Map<String, String>> filteredVideos = [];

  @override
  void initState() {
    super.initState();
    filteredVideos = videos;
  }

  void searchVideos(String query) {
    setState(() {
      filteredVideos = videos
          .where((video) =>
              video['title']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lecteur de Vidéos'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: searchVideos,
              decoration: InputDecoration(
                labelText: 'Rechercher',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredVideos.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Image.network(
                    filteredVideos[index]['thumbnail']!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.error, color: Colors.red);
                    },
                  ),
                  title: Text(filteredVideos[index]['title']!),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoPlayerPage(
                          videoUrl: filteredVideos[index]['url']!,
                        ),
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

class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;

  VideoPlayerPage({required this.videoUrl});

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isFullScreen = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      }).catchError((error) {
        setState(() {
          _hasError = true;
        });
      });
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isFullScreen
          ? null
          : AppBar(
              title: Text('Lecture de Vidéo'),
            ),
      body: _hasError
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 50),
                  SizedBox(height: 10),
                  Text(
                    'Erreur de chargement de la vidéo',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Center(
                    child: _controller.value.isInitialized
                        ? AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                VideoPlayer(_controller),
                                _ControlsOverlay(controller: _controller),
                                VideoProgressIndicator(
                                  _controller,
                                  allowScrubbing: true,
                                  colors: VideoProgressColors(
                                    playedColor: Colors.red,
                                    bufferedColor: Colors.grey,
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : CircularProgressIndicator(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(
                          _controller.value.volume == 0
                              ? Icons.volume_off
                              : Icons.volume_up,
                        ),
                        onPressed: () {
                          setState(() {
                            _controller.setVolume(
                                _controller.value.volume == 0 ? 1.0 : 0.0);
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.fullscreen),
                        onPressed: _toggleFullScreen,
                      ),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: _hasError
          ? null
          : FloatingActionButton(
              onPressed: () {
                setState(() {
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    _controller.play();
                  }
                });
              },
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  final VideoPlayerController controller;

  const _ControlsOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Center(
                  child: Icon(
                    Icons.play_arrow,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}
