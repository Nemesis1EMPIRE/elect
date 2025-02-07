import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class PDFViewScreen extends StatefulWidget {
  final String pdfPath;
  final String pdfName;

  const PDFViewScreen({super.key, required this.pdfPath, required this.pdfName});

  @override
  State<PDFViewScreen> createState() => _PDFViewScreenState();
}

class _PDFViewScreenState extends State<PDFViewScreen> {
  String? localPDFPath;
  bool _isLoading = true; // 📌 Indicateur de chargement

  @override
  void initState() {
    super.initState();
    _loadPDF();
  }

  /// 📌 Copie le fichier PDF depuis les assets vers un dossier temporaire
  Future<void> _loadPDF() async {
    try {
      final byteData = await rootBundle.load(widget.pdfPath);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File("${tempDir.path}/${widget.pdfName}");
      await tempFile.writeAsBytes(byteData.buffer.asUint8List(), flush: true);

      setState(() {
        localPDFPath = tempFile.path;
        _isLoading = false; // 📌 Fin du chargement
      });
    } catch (e) {
      print("Erreur lors du chargement du PDF : $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pdfName),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // 📌 Chargement
          : localPDFPath == null
              ? const Center(child: Text("Erreur lors du chargement du fichier"))
              : PDFView(
                  filePath: localPDFPath!,
                  enableSwipe: true,
                  swipeHorizontal: false,
                  autoSpacing: true,
                  pageFling: true,
                ),
    );
  }
}
