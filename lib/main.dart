import 'package:elect241/screens/faqcreen.dart';
import 'package:elect241/screens/feedscreen.dart';
import 'package:elect241/screens/pdfviewer.dart';
import 'package:elect241/screens/videoscreen.dart';
import 'package:flutter/material.dart';

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

 