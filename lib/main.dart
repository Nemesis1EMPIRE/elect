//import 'package:elect241/screens/faqcreen.dart';
//import 'package:elect241/screens/feedscreen.dart';
//import 'package:elect241/screens/pdfviewer.dart';
//import 'package:elect241/screens/videoscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:video_player/video_player.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as path;

void main() {
  runApp(const Elect241App());
}

class Elect241App extends StatelessWidget {
  const Elect241App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
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

  // 📌 Liste des pages affichées selon l'onglet sélectionné
  final List<Widget> _screens = [
    const PDFViewerSection(),
    const VideoScreen(),
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
      body: Column(
        children: [
          AppBar(
        backgroundColor: Colors.white,
        elevation: 4,
        title: Row(
          children: [
            Image.asset(
              "assets/banner.png",  // Assurez-vous que l'image est dans les assets
              height: 40,  // Ajuster la taille si nécessaire
            ),
            const SizedBox(width: 10),
           
          ],
        ),
      ),
          const BottomNavBar(), // BottomNavBar juste sous l'AppBar
          Expanded(child: _screens[_selectedIndex]), // Contenu dynamique
        ],
      ),
    );
  }
}

// 📌 Bottom Navigation Bar placée sous l'AppBar
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.picture_as_pdf), label: "Lois Électorales"),
          BottomNavigationBarItem(icon: Icon(Icons.video_library), label: "Décryptages"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "FAQ"),
          BottomNavigationBarItem(icon: Icon(Icons.image_aspect_ratio), label: "Actualités")
        ],
        onTap: (index) {
          // 📌 Permet de changer d'écran en fonction du bouton tapé
          final mainScreenState = context.findAncestorStateOfType<_MainScreenState>();
          if (mainScreenState != null) {
            mainScreenState._onItemTapped(index);
          }
        },
      ),
    );
  }
}


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

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 📌 Liste des images et leurs PDF associés
    List<Map<String, String>> feedItems = [
      {"image": "assets/images/election.png", "pdf": "assets/pdfs/date.pdf"},
      {"image": "assets/images/elect.png", "pdf": "assets/pdfs/elect.pdf"},
      {"image": "assets/images/all.png", "pdf": "assets/pdfs/elect.pdf"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Feed", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: feedItems.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20), // Espacement entre les images
              child: GestureDetector(
                onTap: () {
                  // 📌 Navigation vers la page PDF
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PDFViewScreen(
                        pdfPath: feedItems[index]["pdf"]!,
                        title: "Document PDF",
                      ),
                    ),
                  );
                },
                child: Center(
                  child: Image.asset(
                    feedItems[index]["image"]!,
                    fit: BoxFit.none, // Garde la taille originale de l'image
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PDFViewScreen extends StatelessWidget {
  final String pdfPath;
  final String title;

  const PDFViewScreen({super.key, required this.pdfPath, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PDFView(
        filePath: pdfPath,
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
  final Map<String, List<String>> _faqData = {}; // Stocke les questions et réponses

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
      appBar: AppBar(
        title: const Text("FAQ", style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // 📌 Champ pour poser une question
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

          // 📌 Liste des questions et réponses
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
                      // 📌 Liste des réponses
                      ..._faqData[question]!.map((answer) => ListTile(
                            title: Text("💬 $answer"),
                            leading: const Icon(Icons.comment, color: Colors.blue),
                          )),

                      // 📌 Champ pour répondre
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
    getFiles();  // Charge les fichiers PDF au démarrage
  }

  /// 📌 Charge les fichiers PDF depuis les assets
  Future<void> getFiles() async {
    try {
      // Charge la liste des fichiers déclarés dans `pubspec.yaml`
      String manifestContent = await rootBundle.loadString('AssetManifest.json');
      Map<String, dynamic> manifestMap = json.decode(manifestContent);

      List<String> assetPaths = manifestMap.keys
          .where((String key) => key.endsWith('.pdf'))  // Filtre uniquement les PDF
          .toList();

      setState(() {
        _pdfFiles = assetPaths;
        _filteredFiles = _pdfFiles;
      });
    } catch (e) {
      print("Erreur lors de la récupération des fichiers : $e");
    }
  }

  /// 📌 Filtre les fichiers en fonction de la recherche
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
      appBar: AppBar(
        title: !_isSearching
            ? const Text("Lois électorales", style: TextStyle(color: Colors.white),)
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
      body: _filteredFiles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _filteredFiles.length,
              itemBuilder: (context, index) {
                String filePath = _filteredFiles[index];
                String fileName = path.basename(filePath);
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(fileName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 30),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PDFViewerScreen(pdfPath: filePath, pdfName: fileName),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: getFiles,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}


class PDFViewerScreen extends StatefulWidget {
  final String pdfPath;
  final String pdfName;
  const PDFViewerScreen({super.key, required this.pdfPath, required this.pdfName});
  

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  int totalPages = 0;
  int currentPage = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.pdfName),
      ),
      body: PDFView(
        filePath: widget.pdfPath,
        pageFling: false,
        autoSpacing: false,
        onRender: (pages){
          setState(() {
            totalPages = pages!;
          });
        },
        onPageChanged: (page, tota){
          setState(() {
            currentPage = page!;
          });
        },
      ),
    );
  }
}




