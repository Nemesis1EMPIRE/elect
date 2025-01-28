import 'package:elect241/screens/components/imageview.dart';
import 'package:flutter/material.dart';

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
