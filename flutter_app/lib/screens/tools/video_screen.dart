import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});
  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  File? _video;
  String? _resultUrl;
  bool _loading = false;
  String _status = '';
  String _tool = 'compress';
  String _quality = 'medium';
  String _format = 'mp4';

  final _tools = {
    'compress':      'Compress',
    'convert':       'Convert Format',
    'trim':          'Trim',
    'remove_audio':  'Remove Audio',
    'extract_audio': 'Extract Audio',
  };
  final _qualities = ['low', 'medium', 'high'];
  final _formats   = ['mp4', 'avi', 'mov', 'webm'];

  Future<void> _pick() async {
    final xf = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (xf != null) setState(() { _video = File(xf.path); _resultUrl = null; _status = ''; });
  }

  Future<void> _process() async {
    if (_video == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a video first'), backgroundColor: Color(0xFFF72585)));
      return;
    }
    setState(() { _loading = true; _status = 'Uploading video...'; });
    try {
      final params = <String, dynamic>{};
      if (_tool == 'compress') params['quality'] = _quality;
      if (_tool == 'convert')  params['format']  = _format;

      final res = await ApiService().processVideo(_video!, tool: _tool, params: params);
      final jobId = res['job_id'] as String;
      setState(() => _status = 'Processing... please wait');
      await _poll(jobId);
    } catch (e) {
      final msg = e.toString().contains('429') ? 'Daily limit reached. Upgrade to Pro.' : 'Processing failed. Try again.';
      setState(() => _status = msg);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _poll(String jobId) async {
    for (int i = 0; i < 60; i++) {
      await Future.delayed(const Duration(seconds: 4));
      try {
        final res = await ApiService().getJobStatus(jobId);
        final s = res['status'] as String;
        setState(() => _status = 'Status: $s...');
        if (s == 'done') {
          setState(() { _resultUrl = res['result_url']; _status = '✅ Done! Ready to download.'; });
          return;
        }
        if (s == 'failed') { setState(() => _status = '❌ Processing failed.'); return; }
      } catch (_) {}
    }
    setState(() => _status = 'Timed out. Check History tab later.');
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
          decoration: BoxDecoration(color: const Color(0xFF0E0E24), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0x12FFFFFF))),
          child: const Icon(Icons.arrow_back_ios_new, size: 14, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Row(children: [
        Text('🎬', style: TextStyle(fontSize: 20)),
        SizedBox(width: 8),
        Text('Video Tools', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17)),
      ]),
    ),
    body: SafeArea(child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Video picker
        GestureDetector(
          onTap: _pick,
          child: Container(
            width: double.infinity, height: 140,
            decoration: BoxDecoration(
              color: const Color(0xFF0E0E24),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _video != null ? const Color(0xFFFFD60A).withOpacity(0.3) : const Color(0x14FFFFFF)),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(_video != null ? '🎬' : '📹', style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              Text(_video != null ? '✓ Video selected' : 'Tap to select video',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 4),
              Text(_video != null ? _video!.path.split('/').last : 'MP4, MOV, AVI supported',
                style: const TextStyle(color: Color(0xFF5A5A7A), fontSize: 11)),
            ]),
          ),
        ),
        const SizedBox(height: 20),

        // Tool selector
        const Text('TOOL', style: TextStyle(color: Color(0xFF5A5A7A), fontSize: 11, letterSpacing: 2)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8,
          children: _tools.entries.map((e) => GestureDetector(
            onTap: () => setState(() => _tool = e.key),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: _tool == e.key ? const Color(0xFFFFD60A).withOpacity(0.12) : const Color(0xFF0E0E24),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _tool == e.key ? const Color(0xFFFFD60A) : const Color(0x12FFFFFF)),
              ),
              child: Text(e.value, style: TextStyle(
                color: _tool == e.key ? const Color(0xFFFFD60A) : const Color(0xFF5A5A7A),
                fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          )).toList(),
        ),

        if (_tool == 'compress') ...[
          const SizedBox(height: 20),
          const Text('QUALITY', style: TextStyle(color: Color(0xFF5A5A7A), fontSize: 11, letterSpacing: 2)),
          const SizedBox(height: 10),
          Row(children: _qualities.map((q) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _quality = q),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: _quality == q ? const Color(0xFFFFD60A).withOpacity(0.12) : const Color(0xFF0E0E24),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _quality == q ? const Color(0xFFFFD60A) : const Color(0x12FFFFFF)),
                ),
                child: Text(q.toUpperCase(), style: TextStyle(
                  color: _quality == q ? const Color(0xFFFFD60A) : const Color(0xFF5A5A7A),
                  fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
          )).toList()),
        ],

        if (_tool == 'convert') ...[
          const SizedBox(height: 20),
          const Text('OUTPUT FORMAT', style: TextStyle(color: Color(0xFF5A5A7A), fontSize: 11, letterSpacing: 2)),
          const SizedBox(height: 10),
          Row(children: _formats.map((f) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _format = f),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: _format == f ? const Color(0xFFFFD60A).withOpacity(0.12) : const Color(0xFF0E0E24),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _format == f ? const Color(0xFFFFD60A) : const Color(0x12FFFFFF)),
                ),
                child: Text(f.toUpperCase(), style: TextStyle(
                  color: _format == f ? const Color(0xFFFFD60A) : const Color(0xFF5A5A7A),
                  fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
          )).toList()),
        ],

        const SizedBox(height: 20),
        if (_status.isNotEmpty) ...[
          Container(
            width: double.infinity, padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD60A).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFD60A).withOpacity(0.2)),
            ),
            child: Text(_status, style: const TextStyle(color: Color(0xFFFFD60A), fontSize: 13), textAlign: TextAlign.center),
          ),
          const SizedBox(height: 12),
        ],

        if (_resultUrl != null) ...[
          Container(
            width: double.infinity, padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF00F5D4).withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF00F5D4).withOpacity(0.2)),
            ),
            child: Row(children: [
              const Text('✅', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              const Expanded(child: Text('File ready!', style: TextStyle(color: Color(0xFF00F5D4), fontWeight: FontWeight.w700))),
              TextButton(
                onPressed: () {},
                child: const Text('Open', style: TextStyle(color: Color(0xFF00F5D4))),
              ),
            ]),
          ),
          const SizedBox(height: 16),
        ],

        SizedBox(
          width: double.infinity, height: 54,
          child: ElevatedButton(
            onPressed: _loading ? null : _process,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD60A),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: _loading
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
              : const Text('Process Video', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          ),
        ),
      ]),
    )),
  );
}
