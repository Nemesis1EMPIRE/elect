import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:elect241/screens/components/pdfview.dart';

class PDFViewerSection extends StatefulWidget {
  const PDFViewerSection({super.key});

  @override
  State<PDFViewerSection> createState() => _PDFViewerSectionState();
}

class _PDFViewerSectionState extends State<PDFViewerSection> {
  List<String> _pdfFiles = [];
  List<String> _filteredFiles = [];
  bool _isSearching = false;
  bool _isLoading = true; // Ajout d’un indicateur de chargement

  @override
  void initState() {
    super.initState();
    getFiles();
  }

  /// 📌 Charge les fichiers PDF depuis les assets
  Future<void> getFiles() async {
    try {
      setState(() {
        _isLoading = true;
      });

      String manifestContent = await rootBundle.loadString('AssetManifest.json');
      Map<String, dynamic> manifestMap = json.decode(manifestContent);

      List<String> assetPaths = manifestMap.keys
          .where((String key) => key.endsWith('.pdf')) // Filtre uniquement les PDF
          .toList();

      setState(() {
        _pdfFiles = assetPaths;
        _filteredFiles = _pdfFiles;
        _isLoading = false;
      });
    } catch (e) {
      print("Erreur lors de la récupération des fichiers : $e");
      setState(() {
        _isLoading = false;
      });
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


      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Chargement en cours
          : _filteredFiles.isEmpty
              ? const Center(
                  child: Text(
                    "Aucun fichier PDF trouvé",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                )
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
                        leading: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 30),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PDFViewScreen(pdfPath: filePath, pdfName: fileName),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => getFiles()),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
