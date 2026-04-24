import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultViewer extends StatelessWidget {
  final String url;
  final File? original;
  const ResultViewer({super.key, required this.url, this.original});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('RESULT', style: TextStyle(color: Color(0xFF5A5A7A), fontSize: 11, letterSpacing: 2)),
    const SizedBox(height: 10),
    ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: CachedNetworkImage(
        imageUrl: url,
        width: double.infinity, height: 220,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          height: 220, color: const Color(0xFF0E0E24),
          child: const Center(child: CircularProgressIndicator(color: Color(0xFF00F5D4))),
        ),
        errorWidget: (_, __, ___) => Container(
          height: 100, color: const Color(0xFF0E0E24),
          child: const Center(child: Text('Preview not available', style: TextStyle(color: Color(0xFF5A5A7A)))),
        ),
      ),
    ),
    const SizedBox(height: 10),
    SizedBox(width: double.infinity, height: 44,
      child: OutlinedButton.icon(
        onPressed: () => launchUrl(Uri.parse(url)),
        icon: const Icon(Icons.download_outlined, size: 18, color: Color(0xFF00F5D4)),
        label: const Text('Download Result', style: TextStyle(color: Color(0xFF00F5D4), fontWeight: FontWeight.w700)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF00F5D4)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      )),
    const SizedBox(height: 16),
  ]);
}
