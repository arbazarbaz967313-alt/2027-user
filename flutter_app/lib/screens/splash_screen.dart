// ═══════════════════════════════════════════════════
// lib/screens/splash_screen.dart
// ═══════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashState();
}

class _SplashState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale, _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _scale = Tween(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade  = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF04040F),
    body: Center(child: AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => FadeTransition(
        opacity: _fade,
        child: ScaleTransition(
          scale: _scale,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF00F5D4), Color(0xFF9B5DE5)]),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [BoxShadow(color: const Color(0xFF00F5D4).withOpacity(0.4), blurRadius: 40)],
              ),
              child: const Center(child: Text('✦', style: TextStyle(fontSize: 40))),
            ),
            const SizedBox(height: 20),
            RichText(text: const TextSpan(
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: 3),
              children: [
                TextSpan(text: 'Clear', style: TextStyle(color: Colors.white)),
                TextSpan(text: 'Cut', style: TextStyle(color: Color(0xFF00F5D4))),
              ],
            )),
            const SizedBox(height: 8),
            const Text('AI MEDIA TOOLKIT', style: TextStyle(color: Color(0xFF5A5A7A), fontSize: 11, letterSpacing: 3)),
          ]),
        ),
      ),
    )),
  );
}
