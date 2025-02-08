import 'package:flutter/material.dart';
import 'package:elect241/screens/components/imageview.dart';


class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 📌 Liste des images et leurs PDF associés
    List<Map<String, String>> feedItems = [
      {"image": "assets/images/election.png", "pdf": "assets/pdfs/date.pdf"},
       {"image": "assets/images/elect.jpeg", "pdf": "assets/pdfs/date.pdf"},
      {"image": "assets/images/elect.png", "pdf": "assets/pdfs/elect.pdf"},
      {"image": "assets/images/all.png", "pdf": "assets/pdfs/elect.pdf"},
     
    ];

    return Scaffold(
      appBar:  AppBar(
          title: const Text("Actualités Politiques", style: TextStyle(color: Colors.white, fontSize: 18)),
          backgroundColor: Colors.blue,
        ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: feedItems.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 15), // 📌 Espacement entre les images
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
                child: Container(
                  height: 160, // 📌 Hauteur du conteneur pour l'image
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
                    feedItems[index]["image"]!,
                    width: double.infinity, // 📌 Largeur adaptable
                    height: 160, // 📌 Hauteur fixe pour uniformiser
                    fit: BoxFit.cover, // 📌 Remplissage optimal sans distorsion
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

