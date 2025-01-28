import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class PDFViewerScreen extends StatefulWidget {
  final String pdfPath; // 📌 Ex: "assets/pdfs/document.pdf"
  final String pdfName; // 📌 Ex: "document.pdf"

  const PDFViewerScreen({super.key, required this.pdfPath, required this.pdfName});

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  Future<String?>? _pdfFuture; // 📌 Utilisation de Future pour une gestion plus propre

  @override
  void initState() {
    super.initState();
    _pdfFuture = _loadPDF(); // 📌 Charge le PDF dès l'initialisation
  }

  /// 📌 Copie le fichier des assets vers un dossier temporaire pour pouvoir l'afficher
  Future<String?> _loadPDF() async {
    try {
      // 📌 Charge le fichier PDF depuis les assets
      final byteData = await rootBundle.load(widget.pdfPath);

      // 📌 Récupère un dossier temporaire
      final tempDir = await getTemporaryDirectory();
      final tempFile = File("${tempDir.path}/${widget.pdfName}");

      // 📌 Écrit les données du fichier
      await tempFile.writeAsBytes(byteData.buffer.asUint8List(), flush: true);

      return tempFile.path; // 📌 Retourne le chemin du fichier
    } catch (e) {
      print("Erreur lors du chargement du PDF : $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(45), // 📌 Réduction de la hauteur de l'AppBar
        child: AppBar(
          title: Text(widget.pdfName, style: const TextStyle(fontSize: 18)),
          backgroundColor: Colors.blue,
        ),
      ),
      body: FutureBuilder<String?>(
        future: _pdfFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // 📌 Chargement en cours
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text("Erreur lors du chargement du PDF"));
          } else {
            return PDFView(
              filePath: snapshot.data!,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageFling: true,
            );
          }
        },
      ),
    );
  }
}
