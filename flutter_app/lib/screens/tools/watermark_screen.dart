import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
import '../../widgets/result_viewer.dart';

class WatermarkScreen extends StatefulWidget {
  const WatermarkScreen({super.key});
  @override
  State<WatermarkScreen> createState() => _WatermarkState();
}

class _WatermarkState extends State<WatermarkScreen> {
  File? _image;
  String? _resultUrl;
  bool _loading = false;
  String _status = '';

  Future<void> _pick() async {
    final xf = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (xf != null) setState(() { _image = File(xf.path); _resultUrl = null; });
  }

  Future<void> _process() async {
    if (_image == null) return;
    setState(() { _loading = true; _status = 'Removing watermark...'; });
    try {
      final res = await ApiService().removeWatermark(_image!);
      setState(() { _resultUrl = res['result_url']; _status = 'Done!'; });
    } catch (e) {
      setState(() => _status = 'Failed: ${e.toString().split(':').last.trim()}');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => _ToolScaffold(
    title: 'Watermark Remover',
    emoji: '✂️',
    accent: const Color(0xFF00F5D4),
    image: _image,
    resultUrl: _resultUrl,
    loading: _loading,
    status: _status,
    onPick: _pick,
    onProcess: _process,
    tips: const ['Works best on corner watermarks', 'For full-frame watermarks, try manual mask'],
  );
}

// ── BG Remove Screen ──────────────────────────────────────
class BgRemoveScreen extends StatefulWidget {
  const BgRemoveScreen({super.key});
  @override
  State<BgRemoveScreen> createState() => _BgState();
}

class _BgState extends State<BgRemoveScreen> {
  File? _image;
  String? _resultUrl;
  bool _loading = false;
  String _status = '';
  String? _bgColor;

  final _colors = {'Transparent': null, 'White': '#FFFFFF', 'Black': '#000000', 'Gray': '#808080'};
  String _selectedColor = 'Transparent';

  Future<void> _pick() async {
    final xf = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (xf != null) setState(() { _image = File(xf.path); _resultUrl = null; });
  }

  Future<void> _process() async {
    if (_image == null) return;
    setState(() { _loading = true; _status = 'Removing background...'; });
    try {
      final res = await ApiService().removeBackground(_image!, bgColor: _bgColor);
      setState(() { _resultUrl = res['result_url']; _status = 'Done!'; });
    } catch (e) {
      setState(() => _status = 'Failed: ${e.toString().split(':').last.trim()}');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF04040F),
    appBar: _appBar(context, 'BG Remover', '🎭'),
    body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(children: [
      _UploadArea(image: _image, onTap: _pick),
      const SizedBox(height: 20),
      // BG color selector
      const Align(alignment: Alignment.centerLeft,
        child: Text('OUTPUT BACKGROUND', style: TextStyle(color: Color(0xFF5A5A7A), fontSize: 11, letterSpacing: 2))),
      const SizedBox(height: 10),
      Row(children: _colors.entries.map((e) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: () => setState(() { _selectedColor = e.key; _bgColor = e.value; }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _selectedColor == e.key ? const Color(0xFF9B5DE5).withOpacity(0.15) : const Color(0xFF0E0E24),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _selectedColor == e.key ? const Color(0xFF9B5DE5) : const Color(0x12FFFFFF)),
            ),
            child: Text(e.key, style: TextStyle(
              color: _selectedColor == e.key ? const Color(0xFF9B5DE5) : const Color(0xFF5A5A7A),
              fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ),
      )).toList()),
      const SizedBox(height: 20),
      if (_status.isNotEmpty) _StatusBox(status: _status),
      const SizedBox(height: 12),
      if (_resultUrl != null) ResultViewer(url: _resultUrl!, original: _image),
      const SizedBox(height: 16),
      _ProcessBtn(label: 'Remove Background', onTap: _process, loading: _loading, color: const Color(0xFF9B5DE5)),
    ]))),
  );
}

// ── Shared widgets ─────────────────────────────────────────
class _ToolScaffold extends StatelessWidget {
  final String title, emoji;
  final Color accent;
  final File? image;
  final String? resultUrl;
  final bool loading;
  final String status;
  final VoidCallback onPick, onProcess;
  final List<String> tips;
  const _ToolScaffold({required this.title, required this.emoji, required this.accent,
    this.image, this.resultUrl, required this.loading, required this.status,
    required this.onPick, required this.onProcess, required this.tips});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF04040F),
    appBar: _appBar(context, title, emoji),
    body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(children: [
      _UploadArea(image: image, onTap: onPick),
      const SizedBox(height: 16),
      ...tips.map((t) => Padding(padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          Icon(Icons.info_outline, size: 14, color: accent.withOpacity(0.6)),
          const SizedBox(width: 8),
          Text(t, style: TextStyle(color: const Color(0xFF5A5A7A), fontSize: 12)),
        ]))),
      const SizedBox(height: 16),
      if (status.isNotEmpty) _StatusBox(status: status),
      const SizedBox(height: 12),
      if (resultUrl != null) ResultViewer(url: resultUrl!, original: image),
      const SizedBox(height: 16),
      _ProcessBtn(label: 'Process with AI', onTap: onProcess, loading: loading, color: accent),
    ]))),
  );
}

PreferredSizeWidget _appBar(BuildContext context, String title, String emoji) => AppBar(
  backgroundColor: const Color(0xFF04040F),
  elevation: 0,
  leading: IconButton(
    icon: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(color: const Color(0xFF0E0E24), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0x12FFFFFF))),
      child: const Icon(Icons.arrow_back_ios_new, size: 14, color: Colors.white),
    ),
    onPressed: () => Navigator.pop(context),
  ),
  title: Row(children: [
    Text(emoji, style: const TextStyle(fontSize: 22)),
    const SizedBox(width: 8),
    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17)),
  ]),
);

class _UploadArea extends StatelessWidget {
  final File? image;
  final VoidCallback onTap;
  const _UploadArea({this.image, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity, height: image != null ? 220 : 160,
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E24),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: image != null ? const Color(0xFF00F5D4).withOpacity(0.3) : const Color(0x14FFFFFF),
          style: image != null ? BorderStyle.solid : BorderStyle.none,
        ),
      ),
      child: image != null
        ? ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.file(image!, fit: BoxFit.cover))
        : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('📁', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 10),
            const Text('Tap to select image', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 4),
            const Text('JPG, PNG supported', style: TextStyle(color: Color(0xFF5A5A7A), fontSize: 12)),
          ]),
    ),
  );
}

class _StatusBox extends StatelessWidget {
  final String status;
  const _StatusBox({required this.status});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFF00F5D4).withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF00F5D4).withOpacity(0.2)),
    ),
    child: Text(status, style: const TextStyle(color: Color(0xFF00F5D4), fontSize: 13), textAlign: TextAlign.center),
  );
}

class _ProcessBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool loading;
  final Color color;
  const _ProcessBtn({required this.label, required this.onTap, required this.loading, required this.color});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity, height: 54,
    child: ElevatedButton(
      onPressed: loading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color, foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: loading
        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
        : Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 0.5)),
    ),
  );
}
