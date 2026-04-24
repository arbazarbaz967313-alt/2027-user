import 'package:flutter/material.dart';
import '../services/api_service.dart';

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
    try { _items = await ApiService().getHistory(); } catch (_) {}
    setState(() => _loading = false);
  }

  String _emoji(String t) {
    if (t.contains('watermark')) return '✂️';
    if (t.contains('bgremove'))  return '🎭';
    if (t.contains('enhance'))   return '✨';
    if (t.contains('video'))     return '🎬';
    return '📁';
  }

  String _name(String t) {
    if (t.contains('watermark')) return 'Watermark Removed';
    if (t.contains('bgremove'))  return 'Background Removed';
    if (t.contains('enhance'))   return 'Image Enhanced';
    if (t.contains('video'))     return 'Video Processed';
    return t;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF04040F),
    appBar: AppBar(
      backgroundColor: const Color(0xFF04040F),
      elevation: 0,
      title: const Text('History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
      actions: [
        IconButton(icon: const Icon(Icons.refresh, color: Color(0xFF00F5D4)), onPressed: _load),
      ],
    ),
    body: _loading
      ? const Center(child: CircularProgressIndicator(color: Color(0xFF00F5D4)))
      : _items.isEmpty
        ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: const [
            Text('📂', style: TextStyle(fontSize: 48)),
            SizedBox(height: 12),
            Text('No history yet', style: TextStyle(color: Color(0xFF5A5A7A), fontSize: 16)),
            SizedBox(height: 4),
            Text('Processed files will appear here', style: TextStyle(color: Color(0xFF5A5A7A), fontSize: 13)),
          ]))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _items.length,
            itemBuilder: (_, i) {
              final item = _items[i] as Map;
              final tool = item['tool']?.toString() ?? '';
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E0E24),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x12FFFFFF)),
                ),
                child: Row(children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(color: const Color(0xFF04040F), borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Text(_emoji(tool), style: const TextStyle(fontSize: 22))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_name(tool), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 3),
                    Text('ID: ${item['job_id']?.toString().substring(0, 8) ?? ''}',
                      style: const TextStyle(color: Color(0xFF5A5A7A), fontSize: 11)),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00F5D4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Done', style: TextStyle(color: Color(0xFF00F5D4), fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ]),
              );
            },
          ),
  );
}
