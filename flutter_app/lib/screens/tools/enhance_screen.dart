// ═══════════════════════════════════════════════════
// lib/screens/tools/enhance_screen.dart
// ═══════════════════════════════════════════════════
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../providers/user_provider.dart';
import '../../widgets/result_viewer.dart';

class EnhanceScreen extends StatefulWidget {
  const EnhanceScreen({super.key});
  @override
  State<EnhanceScreen> createState() => _EnhanceState();
}

class _EnhanceState extends State<EnhanceScreen> {
  File? _image;
  String? _resultUrl;
  bool _loading = false;
  String _status = '';
  int _scale = 2;
  String _type = 'upscale';

  final _types = {'upscale': 'Upscale', 'denoise': 'Denoise', 'sharpen': 'Sharpen', 'brightness': 'Auto Brightness'};

  Future<void> _pick() async {
    final xf = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (xf != null) setState(() { _image = File(xf.path); _resultUrl = null; });
  }

  Future<void> _process() async {
    if (_image == null) return;
    final isPro = context.read<UserProvider>().isPro;
    if (_scale == 4 && !isPro) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('4x requires Pro'), backgroundColor: Color(0xFFF72585)));
      return;
    }
    setState(() { _loading = true; _status = 'Enhancing image...'; });
    try {
      final res = await ApiService().enhanceImage(_image!, scale: _scale, enhanceType: _type);
      setState(() { _resultUrl = res['result_url']; _status = 'Done!'; });
    } catch (e) {
      setState(() => _status = 'Failed: ${e.toString().split(':').last.trim()}');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPro = context.watch<UserProvider>().isPro;
    return Scaffold(
      backgroundColor: const Color(0xFF04040F),
      appBar: _toolAppBar(context, 'Quality Enhancer', '✨'),
      body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _UploadBox(image: _image, onTap: _pick),
        const SizedBox(height: 20),
        const Text('ENHANCE TYPE', style: TextStyle(color: Color(0xFF5A5A7A), fontSize: 11, letterSpacing: 2)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: _types.entries.map((e) => _Chip(
          label: e.value, selected: _type == e.key, color: const Color(0xFFF72585),
          onTap: () => setState(() => _type = e.key),
        )).toList()),
        const SizedBox(height: 20),
        const Text('SCALE', style: TextStyle(color: Color(0xFF5A5A7A), fontSize: 11, letterSpacing: 2)),
        const SizedBox(height: 10),
        Row(children: [2, 4].map((s) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _Chip(
            label: s == 4 && !isPro ? '${s}x ★ Pro' : '${s}x',
            selected: _scale == s, color: const Color(0xFFF72585),
            onTap: () => setState(() => _scale = s),
          ),
        )).toList()),
        const SizedBox(height: 20),
        if (_status.isNotEmpty) _StatusWidget(status: _status, color: const Color(0xFFF72585)),
        const SizedBox(height: 12),
        if (_resultUrl != null) ResultViewer(url: _resultUrl!, original: _image),
        const SizedBox(height: 16),
        _ActionBtn(label: 'Enhance Now', color: const Color(0xFFF72585), loading: _loading, onTap: _process),
      ]))),
    );
  }
}

// ═══════════════════════════════════════════════════
// lib/screens/tools/video_screen.dart
// ═══════════════════════════════════════════════════
class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});
  @override
  State<VideoScreen> createState() => _VideoState();
}

class _VideoState extends State<VideoScreen> {
  File? _video;
  String? _resultUrl;
  bool _loading = false;
  String _status = '';
  String _tool = 'compress';
  String _quality = 'medium';
  String _format = 'mp4';

  final _tools = {'compress': 'Compress', 'convert': 'Convert Format', 'trim': 'Trim', 'remove_audio': 'Remove Audio', 'extract_audio': 'Extract Audio'};
  final _qualities = ['low', 'medium', 'high'];
  final _formats = ['mp4', 'avi', 'mov', 'webm'];

  Future<void> _pick() async {
    final xf = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (xf != null) setState(() { _video = File(xf.path); _resultUrl = null; });
  }

  Future<void> _process() async {
    if (_video == null) return;
    setState(() { _loading = true; _status = 'Processing video...'; });
    try {
      final params = _tool == 'compress' ? {'quality': _quality} : _tool == 'convert' ? {'format': _format} : {};
      final res = await ApiService().processVideo(_video!, tool: _tool, params: params);
      // Poll for status since video is async
      final jobId = res['job_id'] as String;
      await _pollJob(jobId);
    } catch (e) {
      setState(() => _status = 'Failed: ${e.toString().split(':').last.trim()}');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _pollJob(String jobId) async {
    for (int i = 0; i < 60; i++) {
      await Future.delayed(const Duration(seconds: 3));
      try {
        final res = await ApiService().getJobStatus(jobId);
        final status = res['status'] as String;
        setState(() => _status = 'Status: $status...');
        if (status == 'done') {
          setState(() { _resultUrl = res['result_url']; _status = 'Done! Ready to download.'; });
          return;
        }
        if (status == 'failed') {
          setState(() => _status = 'Processing failed. Try again.');
          return;
        }
      } catch (_) {}
    }
    setState(() => _status = 'Timed out. Check history later.');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF04040F),
    appBar: _toolAppBar(context, 'Video Tools', '🎬'),
    body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _VideoPickBox(video: _video, onTap: _pick),
      const SizedBox(height: 20),
      const Text('TOOL', style: TextStyle(color: Color(0xFF5A5A7A), fontSize: 11, letterSpacing: 2)),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: _tools.entries.map((e) => _Chip(
        label: e.value, selected: _tool == e.key, color: const Color(0xFFFFD60A),
        onTap: () => setState(() => _tool = e.key),
      )).toList()),
      if (_tool == 'compress') ...[
        const SizedBox(height: 20),
        const Text('QUALITY', style: TextStyle(color: Color(0xFF5A5A7A), fontSize: 11, letterSpacing: 2)),
        const SizedBox(height: 10),
        Row(children: _qualities.map((q) => Padding(padding: const EdgeInsets.only(right: 8),
          child: _Chip(label: q.toUpperCase(), selected: _quality == q, color: const Color(0xFFFFD60A),
            onTap: () => setState(() => _quality = q)))).toList()),
      ],
      if (_tool == 'convert') ...[
        const SizedBox(height: 20),
        const Text('OUTPUT FORMAT', style: TextStyle(color: Color(0xFF5A5A7A), fontSize: 11, letterSpacing: 2)),
        const SizedBox(height: 10),
        Row(children: _formats.map((f) => Padding(padding: const EdgeInsets.only(right: 8),
          child: _Chip(label: f.toUpperCase(), selected: _format == f, color: const Color(0xFFFFD60A),
            onTap: () => setState(() => _format = f)))).toList()),
      ],
      const SizedBox(height: 20),
      if (_status.isNotEmpty) _StatusWidget(status: _status, color: const Color(0xFFFFD60A)),
      if (_resultUrl != null) Padding(padding: const EdgeInsets.only(top: 12),
        child: _DownloadCard(url: _resultUrl!)),
      const SizedBox(height: 16),
      _ActionBtn(label: 'Process Video', color: const Color(0xFFFFD60A), loading: _loading, onTap: _process, dark: true),
    ]))),
  );
}

// ═══════════════════════════════════════════════════
// lib/screens/history_screen.dart
// ═══════════════════════════════════════════════════
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryState();
}

class _HistoryState extends State<HistoryScreen> {
  List _items = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _items = await ApiService().getHistory();
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF04040F),
    appBar: AppBar(
      backgroundColor: const Color(0xFF04040F), elevation: 0,
      title: const Text('History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
      actions: [IconButton(icon: const Icon(Icons.refresh, color: Color(0xFF00F5D4)), onPressed: _load)],
    ),
    body: _loading
      ? const Center(child: CircularProgressIndicator(color: Color(0xFF00F5D4)))
      : _items.isEmpty
        ? const Center(child: Text('No history yet', style: TextStyle(color: Color(0xFF5A5A7A))))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _items.length,
            itemBuilder: (_, i) {
              final item = _items[i] as Map;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E0E24),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x12FFFFFF)),
                ),
                child: Row(children: [
                  Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFF04040F), borderRadius: BorderRadius.circular(10)),
                    child: Center(child: Text(_toolEmoji(item['tool'] ?? ''), style: const TextStyle(fontSize: 22)))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_toolName(item['tool'] ?? ''), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(item['job_id']?.toString().substring(0, 8) ?? '', style: const TextStyle(color: Color(0xFF5A5A7A), fontSize: 11)),
                  ])),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFF00F5D4).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                    child: const Text('Done', style: TextStyle(color: Color(0xFF00F5D4), fontSize: 10, fontWeight: FontWeight.w700))),
                ]),
              );
            }),
  );

  String _toolEmoji(String t) {
    if (t.contains('watermark')) return '✂️';
    if (t.contains('bgremove')) return '🎭';
    if (t.contains('enhance')) return '✨';
    if (t.contains('video')) return '🎬';
    return '📁';
  }
  String _toolName(String t) {
    if (t.contains('watermark')) return 'Watermark Removed';
    if (t.contains('bgremove')) return 'Background Removed';
    if (t.contains('enhance')) return 'Image Enhanced';
    if (t.contains('video')) return 'Video Processed';
    return t;
  }
}

// ═══════════════════════════════════════════════════
// lib/screens/premium_screen.dart
// ═══════════════════════════════════════════════════
class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});
  @override
  State<PremiumScreen> createState() => _PremState();
}

class _PremState extends State<PremiumScreen> {
  bool _loading = false;
  String _selected = 'pro_monthly';

  Future<void> _buy() async {
    setState(() => _loading = true);
    try {
      final order = await ApiService().createOrder(_selected);
      // Razorpay checkout — in real app use razorpay_flutter plugin
      // For now show dialog
      if (mounted) showDialog(context: context, builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0E0E24),
        title: const Text('Payment', style: TextStyle(color: Colors.white)),
        content: Text('Order created: ${order['order_id']}\nIntegrate razorpay_flutter plugin to complete payment.', style: const TextStyle(color: Color(0xFF5A5A7A))),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK', style: TextStyle(color: Color(0xFFFFD60A))))],
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: const Color(0xFFF72585)));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF04040F),
    appBar: AppBar(backgroundColor: const Color(0xFF04040F), elevation: 0,
      title: const Text('Go Pro', style: TextStyle(color: Color(0xFFFFD60A), fontWeight: FontWeight.w800))),
    body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(children: [
      const Text('★', style: TextStyle(fontSize: 50)),
      const SizedBox(height: 8),
      const Text('Unlock Everything', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      const Text('Unlimited AI processing, 4K quality, no watermarks', style: TextStyle(color: Color(0xFF5A5A7A), fontSize: 13), textAlign: TextAlign.center),
      const SizedBox(height: 28),
      // Plans
      ...[
        {'key': 'pro_monthly', 'name': 'Pro Monthly', 'price': '₹199', 'per': '/month', 'popular': true},
        {'key': 'pro_annual',  'name': 'Pro Annual',  'price': '₹999', 'per': '/year',  'save': 'SAVE 58%', 'popular': false},
      ].map((p) => GestureDetector(
        onTap: () => setState(() => _selected = p['key'] as String),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _selected == p['key'] ? const Color(0xFFFFD60A).withOpacity(0.05) : const Color(0xFF0E0E24),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _selected == p['key'] ? const Color(0xFFFFD60A) : const Color(0x12FFFFFF), width: 1.5),
          ),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(p['name'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                if (p['popular'] == true) ...[const SizedBox(width: 8),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFFFD60A), borderRadius: BorderRadius.circular(4)),
                    child: const Text('POPULAR', style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w800)))],
                if (p.containsKey('save')) ...[const SizedBox(width: 8),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFF34D399), borderRadius: BorderRadius.circular(4)),
                    child: Text(p['save'] as String, style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w800)))],
              ]),
              const SizedBox(height: 6),
              ...[' Unlimited exports', ' No watermark', ' 4x AI enhance', ' Priority queue'].map((f) =>
                Text('✓$f', style: const TextStyle(color: Color(0xFF5A5A7A), fontSize: 12))),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(p['price'] as String, style: const TextStyle(color: Color(0xFFFFD60A), fontSize: 22, fontWeight: FontWeight.w800)),
              Text(p['per'] as String, style: const TextStyle(color: Color(0xFF5A5A7A), fontSize: 11)),
            ]),
          ]),
        ),
      )),
      const SizedBox(height: 8),
      SizedBox(width: double.infinity, height: 54,
        child: ElevatedButton(
          onPressed: _loading ? null : _buy,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFD60A), foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
          child: _loading ? const CircularProgressIndicator(color: Colors.black, strokeWidth: 2)
            : const Text('Get Pro Now', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        )),
      const SizedBox(height: 12),
      const Text('Secure payment via Razorpay & UPI\nCancel anytime', style: TextStyle(color: Color(0xFF5A5A7A), fontSize: 11), textAlign: TextAlign.center),
    ]))),
  );
}

// ── Shared small widgets ───────────────────────────────────
class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? color.withOpacity(0.12) : const Color(0xFF0E0E24),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? color : const Color(0x12FFFFFF)),
      ),
      child: Text(label, style: TextStyle(color: selected ? color : const Color(0xFF5A5A7A), fontSize: 12, fontWeight: FontWeight.w600)),
    ),
  );
}

class _StatusWidget extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusWidget({required this.status, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))),
    child: Text(status, style: TextStyle(color: color, fontSize: 13), textAlign: TextAlign.center),
  );
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final bool loading;
  final VoidCallback onTap;
  final bool dark;
  const _ActionBtn({required this.label, required this.color, required this.loading, required this.onTap, this.dark = false});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity, height: 54,
    child: ElevatedButton(
      onPressed: loading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color, foregroundColor: dark ? Colors.black : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
      child: loading ? CircularProgressIndicator(color: dark ? Colors.black : Colors.white, strokeWidth: 2)
        : Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
    ),
  );
}

class _VideoPickBox extends StatelessWidget {
  final File? video;
  final VoidCallback onTap;
  const _VideoPickBox({this.video, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity, height: 140,
      decoration: BoxDecoration(color: const Color(0xFF0E0E24), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0x14FFFFFF))),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(video != null ? '🎬' : '📹', style: const TextStyle(fontSize: 40)),
        const SizedBox(height: 8),
        Text(video != null ? 'Video selected ✓' : 'Tap to select video', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(video != null ? video!.path.split('/').last : 'MP4, MOV, AVI supported', style: const TextStyle(color: Color(0xFF5A5A7A), fontSize: 11)),
      ]),
    ),
  );
}

class _DownloadCard extends StatelessWidget {
  final String url;
  const _DownloadCard({required this.url});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14), margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(color: const Color(0xFF00F5D4).withOpacity(0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF00F5D4).withOpacity(0.2))),
    child: Row(children: [
      const Text('✅', style: TextStyle(fontSize: 22)),
      const SizedBox(width: 12),
      const Expanded(child: Text('File ready!', style: TextStyle(color: Color(0xFF00F5D4), fontWeight: FontWeight.w700))),
      TextButton(onPressed: () {}, child: const Text('Download', style: TextStyle(color: Color(0xFF00F5D4)))),
    ]),
  );
}

PreferredSizeWidget _toolAppBar(BuildContext context, String title, String emoji) => AppBar(
  backgroundColor: const Color(0xFF04040F), elevation: 0,
  leading: IconButton(
    icon: Container(width: 36, height: 36,
      decoration: BoxDecoration(color: const Color(0xFF0E0E24), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0x12FFFFFF))),
      child: const Icon(Icons.arrow_back_ios_new, size: 14, color: Colors.white)),
    onPressed: () => Navigator.pop(context)),
  title: Row(children: [
    Text(emoji, style: const TextStyle(fontSize: 20)),
    const SizedBox(width: 8),
    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17)),
  ]),
);

class _UploadBox extends StatelessWidget {
  final File? image;
  final VoidCallback onTap;
  const _UploadBox({this.image, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(width: double.infinity, height: image != null ? 220 : 160,
      decoration: BoxDecoration(color: const Color(0xFF0E0E24), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0x14FFFFFF))),
      child: image != null
        ? ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.file(image!, fit: BoxFit.cover))
        : Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
            Text('📁', style: TextStyle(fontSize: 40)),
            SizedBox(height: 10),
            Text('Tap to select image', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
            SizedBox(height: 4),
            Text('JPG, PNG supported', style: TextStyle(color: Color(0xFF5A5A7A), fontSize: 12)),
          ]),
    ),
  );
}
