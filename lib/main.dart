import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'package:path/path.dart' as path;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const Elect241App());
}

class Elect241App extends StatelessWidget {
  const Elect241App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const PDFViewerSection(),
    VideoScreen(),
    const FAQScreen(),
    const FeedScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        backgroundColor: Colors.white,
        title: Image.asset("assets/banner.png", height: 40),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({super.key, required this.currentIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.picture_as_pdf), label: "Lois Électorales"),
        BottomNavigationBarItem(icon: Icon(Icons.video_library), label: "Décryptages"),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: "FAQ"),
        BottomNavigationBarItem(icon: Icon(Icons.image_aspect_ratio), label: "Actualités"),
      ],
      onTap: onItemTapped,
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  final String videoUrl = 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'; // Test URL

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });

    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
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
      backgroundColor: Colors.black,
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final TextEditingController _questionController = TextEditingController();
  final Map<String, List<String>> _faqData = {};

  void _addQuestion() {
    String question = _questionController.text.trim();
    if (question.isNotEmpty) {
      setState(() {
        _faqData[question] = [];
      });
      _questionController.clear();
    }
  }

  void _addAnswer(String question, String answer) {
    if (answer.isNotEmpty) {
      setState(() {
        _faqData[question]?.add(answer);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: AppBar(
          title: const Text("FAQ", style: TextStyle(color: Colors.white, fontSize: 18)),
          backgroundColor: Colors.blue,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _questionController,
                    decoration: InputDecoration(
                      hintText: "Posez votre question...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _addQuestion,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _faqData.length,
              itemBuilder: (context, index) {
                String question = _faqData.keys.elementAt(index);
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ExpansionTile(
                    title: Text(
                      "❓ $question",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: [
                      ..._faqData[question]!.map((answer) => ListTile(
                            title: Text("💬 $answer"),
                            leading: const Icon(Icons.comment, color: Colors.blue),
                          )),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: "Votre réponse...",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onSubmitted: (value) => _addAnswer(question, value),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send, color: Colors.green),
                              onPressed: () {
                                _addAnswer(question, _questionController.text);
                                _questionController.clear();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PDFViewerSection extends StatefulWidget {
  const PDFViewerSection({super.key});

  @override
  State<PDFViewerSection> createState() => _PDFViewerSectionState();
}

class _PDFViewerSectionState extends State<PDFViewerSection> {
  List<String> _pdfFiles = [];
  List<String> _filteredFiles = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    getFiles();
  }

  Future<void> getFiles() async {
    try {
      String manifestContent = await rootBundle.loadString('AssetManifest.json');
      Map<String, dynamic> manifestMap = json.decode(manifestContent);

      List<String> assetPaths = manifestMap.keys
          .where((String key) => key.endsWith('.pdf'))
          .toList();

      setState(() {
        _pdfFiles = assetPaths;
        _filteredFiles = _pdfFiles;
      });
    } catch (e) {
      print("Erreur lors de la récupération des fichiers : $e");
    }
  }

  void _filterFiles(String query) {
    setState(() {
      _filteredFiles = query.isEmpty
          ? _pdfFiles
          : _pdfFiles.where((file) => path.basename(file).toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: AppBar(
          title: !_isSearching
              ? const Text("Lois électorales", style: TextStyle(color: Colors.white, fontSize: 18))
              : TextField(
                  decoration: const InputDecoration(
                    hintText: "Rechercher un PDF...",
                    border: InputBorder.none,
                  ),
                  onChanged: _filterFiles,
                ),
          backgroundColor: Colors.blue,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  _filteredFiles = _pdfFiles;
                });
              },
              icon: Icon(_isSearching ? Icons.cancel : Icons.search),
            )
          ],
        ),
      ),
      body: _filteredFiles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _filteredFiles.length,
              itemBuilder: (context, index) {
                String filePath = _filteredFiles[index];
                String fileName = path.basename(filePath);
                return Card(
                 
