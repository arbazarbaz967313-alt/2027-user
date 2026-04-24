import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
import '../../widgets/result_viewer.dart';

class BgRemoveScreen extends StatefulWidget {
  const BgRemoveScreen({super.key});
  @override
  State<BgRemoveScreen> createState() => _BgRemoveState();
}

class _BgRemoveState extends State<BgRemoveScreen> {
  File? _image;
  String? _resultUrl;
  bool _loading = false;
  String _status = '';
  String _selectedBg = 'Transparent';
  String? _bgColor;

  final _bgOptions = {
    'Transparent': null,
    'White': '#FFFFFF',
    'Black': '#000000',
    'Gray': '#808080',
  };

  Future<void> _pick() async {
    final xf = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (xf != null) setState(() { _image = File(xf.path); _resultUrl = null; _status = ''; });
  }

  Future<void> _process() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first'), backgroundColor: Color(0xFFF72585)));
      return;
    }
    setState(() { _loading = true; _status = 'Removing background...'; });
    try {
      final res = await ApiService().removeBackground(_image!, bgColor: _bgColor);
      setState(() { _resultUrl = res['result_url']; _status = 'Done! Background removed ✓'; });
    } catch (e) {
      final msg = e.toString().contains('429') ? 'Daily limit reached. Upgrade to Pro.' : 'Processing failed. Try again.';
      setState(() => _status = msg);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF04040F),
    appBar: AppBar(
      backgroundColor: const Color(0xFF04040F),
      elevation: 0,
      leading: IconButton(
        icon: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF0E0E24),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0x12FFFFFF)),
          ),
          child: const Icon(Icons.arrow_back_ios_new, size: 14, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Row(children: [
        Text('🎭', style: TextStyle(fontSize: 20)),
        SizedBox(width: 8),
        Text('BG Remover', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17)),
      ]),
    ),
    body: SafeArea(child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Upload area
        GestureDetector(
          onTap: _pick,
          child: Container(
            width: double.infinity, height: _image != null ? 220 : 160,
            decoration: BoxDecoration(
              color: const Color(0xFF0E0E24),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _image != null
                ? const Color(0xFF9B5DE5).withOpacity(0.4)
                : const Color(0x14FFFFFF)),
            ),
            child: _image != null
              ? ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.file(_image!, fit: BoxFit.cover))
              : Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
                  Text('📁', style: TextStyle(fontSize: 40)),
                  SizedBox(height: 10),
                  Text('Tap to select image', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                  SizedBox(height: 4),
                  Text('JPG, PNG supported', style: TextStyle(color: Color(0xFF5A5A7A), fontSize: 12)),
                ]),
          ),
        ),
        const SizedBox(height: 20),

        // BG color
        const Text('OUTPUT BACKGROUND', style: TextStyle(color: Color(0xFF5A5A7A), fontSize: 11, letterSpacing: 2)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8,
          children: _bgOptions.entries.map((e) => GestureDetector(
            onTap: () => setState(() { _selectedBg = e.key; _bgColor = e.value; }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: _selectedBg == e.key ? const Color(0xFF9B5DE5).withOpacity(0.12) : const Color(0xFF0E0E24),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _selectedBg == e.key ? const Color(0xFF9B5DE5) : const Color(0x12FFFFFF)),
              ),
              child: Text(e.key, style: TextStyle(
                color: _selectedBg == e.key ? const Color(0xFF9B5DE5) : const Color(0xFF5A5A7A),
                fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          )).toList(),
        ),
        const SizedBox(height: 20),

        if (_status.isNotEmpty) ...[
          Container(
            width: double.infinity, padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF9B5DE5).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF9B5DE5).withOpacity(0.2)),
            ),
            child: Text(_status, style: const TextStyle(color: Color(0xFF9B5DE5), fontSize: 13), textAlign: TextAlign.center),
          ),
          const SizedBox(height: 12),
        ],

        if (_resultUrl != null) ...[
          ResultViewer(url: _resultUrl!, original: _image),
        ],

        SizedBox(
          width: double.infinity, height: 54,
          child: ElevatedButton(
            onPressed: _loading ? null : _process,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9B5DE5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: _loading
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Remove Background', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
          ),
        ),
      ]),
    )),
  );
}
