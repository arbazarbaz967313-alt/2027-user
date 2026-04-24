import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import 'tools/watermark_screen.dart';
import 'tools/bgremove_screen.dart';
import 'tools/enhance_screen.dart';
import 'tools/video_screen.dart';
import 'history_screen.dart';
import 'premium_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  int _tab = 0;

  final _pages = const [_HomePage(), HistoryScreen(), PremiumScreen()];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF04040F),
    body: _pages[_tab],
    bottomNavigationBar: Container(
      decoration: const BoxDecoration(
        color: Color(0xFF08081800),
        border: Border(top: BorderSide(color: Color(0x12FFFFFF))),
      ),
      child: NavigationBar(
        backgroundColor: const Color(0xFF080818).withOpacity(0.95),
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: Color(0xFF00F5D4)), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history, color: Color(0xFF00F5D4)), label: 'History'),
          NavigationDestination(icon: Icon(Icons.star_outline), selectedIcon: Icon(Icons.star, color: Color(0xFFFFD60A)), label: 'Pro'),
        ],
      ),
    ),
  );
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    return SafeArea(
      child: CustomScrollView(slivers: [
        // Header
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Row(children: [
            Row(children: [
              Container(width: 34, height: 34,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF00F5D4), Color(0xFF9B5DE5)]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(child: Text('✦', style: TextStyle(fontSize: 16))),
              ),
              const SizedBox(width: 8),
              RichText(text: const TextSpan(
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1),
                children: [
                  TextSpan(text: 'Clear', style: TextStyle(color: Colors.white)),
                  TextSpan(text: 'Cut', style: TextStyle(color: Color(0xFF00F5D4))),
                ],
              )),
            ]),
            const Spacer(),
            if (user.isPro) Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD60A).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFD60A).withOpacity(0.3)),
              ),
              child: const Text('★ PRO', style: TextStyle(color: Color(0xFFFFD60A), fontSize: 10, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _showMenu(context),
              child: Container(width: 34, height: 34,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF9B5DE5), Color(0xFFF72585)]),
                  shape: BoxShape.circle,
                ),
                child: const Center(child: Icon(Icons.person_outline, color: Colors.white, size: 18)),
              ),
            ),
          ]),
        )),

        // Greeting
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Good day 👋', style: TextStyle(color: Color(0xFF5A5A7A), fontSize: 13, letterSpacing: 1)),
            const SizedBox(height: 2),
            Text('What are we editing?', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
          ]),
        )),

        // Usage bar (free tier)
        if (!user.isPro) SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0E0E24),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x12FFFFFF)),
            ),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Daily limit', style: TextStyle(color: Color(0xFF5A5A7A), fontSize: 12)),
                Text('${user.remaining}/5 remaining', style: const TextStyle(color: Color(0xFF00F5D4), fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: user.remaining / 5,
                  backgroundColor: const Color(0xFF04040F),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF00F5D4)),
                  minHeight: 6,
                ),
              ),
            ]),
          ),
        )),

        // Feature grid
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
          child: const Text('TOOLS', style: TextStyle(color: Color(0xFF5A5A7A), fontSize: 11, letterSpacing: 2)),
        )),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.9),
            delegate: SliverChildListDelegate([
              _FeatureCard(emoji: '✂️', title: 'Watermark\nRemover', subtitle: 'Photo & Video',
                bg: [const Color(0xFF06161E), const Color(0xFF091F2C)],
                accent: const Color(0xFF00F5D4),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WatermarkScreen()))),
              _FeatureCard(emoji: '🎭', title: 'BG\nRemover', subtitle: 'Photo AI',
                bg: [const Color(0xFF100620), const Color(0xFF17082E)],
                accent: const Color(0xFF9B5DE5),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BgRemoveScreen()))),
              _FeatureCard(emoji: '✨', title: 'Quality\nEnhancer', subtitle: 'Up to 4x AI',
                bg: [const Color(0xFF1A0610), const Color(0xFF270816)],
                accent: const Color(0xFFF72585),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EnhanceScreen()))),
              _FeatureCard(emoji: '🎬', title: 'Video\nTools', subtitle: 'Compress & more',
                bg: [const Color(0xFF1A1400), const Color(0xFF261C00)],
                accent: const Color(0xFFFFD60A),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VideoScreen()))),
            ]),
          ),
        ),

        // Pro banner (free users)
        if (!user.isPro) SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen())),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1000),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFD60A).withOpacity(0.2)),
              ),
              child: Row(children: [
                const Text('★', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Upgrade to Pro', style: TextStyle(color: Color(0xFFFFD60A), fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text('Unlimited · No watermark · 4x enhance', style: TextStyle(color: const Color(0xFFFFD60A).withOpacity(0.5), fontSize: 11)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFFD60A), Color(0xFFFF9F0A)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('₹199/mo', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 12)),
                ),
              ]),
            ),
          ),
        )),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ]),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(context: context, backgroundColor: const Color(0xFF0E0E24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: const Icon(Icons.logout, color: Color(0xFFF72585)), title: const Text('Logout', style: TextStyle(color: Colors.white)),
            onTap: () async {
              await AuthService.logout();
              if (context.mounted) Navigator.pop(context);
            }),
        ]),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String emoji, title, subtitle;
  final List<Color> bg;
  final Color accent;
  final VoidCallback onTap;
  const _FeatureCard({required this.emoji, required this.title, required this.subtitle, required this.bg, required this.accent, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: bg, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withOpacity(0.15)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(emoji, style: const TextStyle(fontSize: 30)),
        const Spacer(),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800, height: 1.2)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: accent.withOpacity(0.7), fontSize: 10)),
      ]),
    ),
  );
}
