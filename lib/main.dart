import 'package:elect241/screens/faqcreen.dart';
import 'package:elect241/screens/feedscreen.dart';
import 'package:elect241/screens/pdfviewer.dart';
import 'package:elect241/screens/videoscreen.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';



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

  // 📌 Liste des pages affichées selon l'onglet sélectionné
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50), // 📌 Réduction de la hauteur de l'AppBar
        child: AppBar(
          elevation: 4,
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Image.asset(
                "assets/banner.png",
                height: 40, // 📌 Ajuste la taille de l’image
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex, // 📌 Passe l’index actif
        onItemTapped: _onItemTapped,  // 📌 Gère le changement d’écran
      ),

       body: IndexedStack(
        index: _selectedIndex, // 📌 Garde les écrans en mémoire
        children: _screens,
      ),
    );
  }
}

// 📌 Bottom Navigation Bar placée sous l'AppBar
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({super.key, required this.currentIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex, // 📌 Définit l'élément actif
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.picture_as_pdf), label: "Lois Électorales"),
        BottomNavigationBarItem(icon: Icon(Icons.video_library), label: "Décryptages"),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: "FAQ"),
        BottomNavigationBarItem(icon: Icon(Icons.image_aspect_ratio), label: "Actualités"),
      ],
      onTap: onItemTapped, // 📌 Appelle la fonction de navigation
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

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/vid.mp4'); // Assurez-vous d'avoir la vidéo dans les assets
    _initializeVideoPlayerFuture = _controller.initialize();

    // Une fois la vidéo terminée, on passe à l'écran principal
    _controller.setLooping(false); // Ne pas boucler la vidéo
    _controller.play();

    Timer(Duration(seconds: 5), () { // Ajustez le temps pour correspondre à la durée de la vidéo
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}


