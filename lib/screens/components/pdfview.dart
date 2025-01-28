import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

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