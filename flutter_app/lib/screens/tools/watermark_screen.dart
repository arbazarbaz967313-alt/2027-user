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
    final xf = await ImagePicker().pickImage(
      source: ImageSource.gallery, imageQuality: 90);
    if (xf != null) {
      setState(() { _image = File(xf.path); _resultUrl = null; _status = ''; });
    }
  }

  Future<void> _process() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first'),
          backgroundColor: Color(0xFFF72585)));
      return;
    }
    setState(() { _loading = true; _status = 'Removing watermark...'; });
    try {
      final res = await ApiService().removeWatermark(_image!);
      setState(() {
        _resultUrl = res['result_url'] as String?;
        _status = 'Done! Watermark removed 鉁�';
      });
    } catch (e) {
      final msg = e.toString().contains('429')
        ? 'Daily limit reached. Upgrade to Pro.'
        : 'Processing failed. Try again.';
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
        Text('鉁傦笍', style: TextStyle(fontSize: 20)),
        SizedBox(width: 8),
        Text('Watermark Remover',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17)),
      ]),
    ),
    body: SafeArea(child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Upload area
        GestureDetector(
          onTap: _pick,
          child: Container(
            width: double.infinity,
            height: _image != null ? 220 : 160,
            decoration: BoxDecoration(
              color: const Color(0xFF0E0E24),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _image != null
                  ? const Color(0xFF00F5D4).withOpacity(0.4)
                  : const Color(0x14FFFFFF)),
            ),
            child: _image != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(_image!, fit: BoxFit.cover))
              : Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
                  Text('馃搧', style: TextStyle(fontSize: 40)),
                  SizedBox(height: 10),
                  Text('Tap to select image',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                  SizedBox(height: 4),
                  Text('JPG, PNG supported',
                    style: TextStyle(color: Color(0xFF5A5A7A), fontSize: 12)),
                ]),
          ),
        ),
        const SizedBox(height: 16),

        // Tips
        _tip('Works best on corner watermarks'),
        _tip('Upload a mask image for precise removal'),
        const SizedBox(height: 16),

        if (_status.isNotEmpty) ...[
          Container(
            width: double.infinity, padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF00F5D4).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00F5D4).withOpacity(0.2)),
            ),
            child: Text(_status,
              style: const TextStyle(color: Color(0xFF00F5D4), fontSize: 13),
              textAlign: TextAlign.center),
          ),
          const SizedBox(height: 12),
        ],

        if (_resultUrl != null) ResultViewer(url: _resultUrl!, original: _image),

        SizedBox(
          width: double.infinity, height: 54,
          child: ElevatedButton(
            onPressed: _loading ? null : _process,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00F5D4),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: _loading
              ? const SizedBox(width: 22, height: 22,
                  child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
              : const Text('Remove Watermark',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          ),
        ),
      ]),
    )),
  );

  Widget _tip(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      Icon(Icons.info_outline, size: 14, color: const Color(0xFF00F5D4).withOpacity(0.6)),
      const SizedBox(width: 8),
      Text(text, style: const TextStyle(color: Color(0xFF5A5A7A), fontSize: 12)),
    ]),
  );
}
