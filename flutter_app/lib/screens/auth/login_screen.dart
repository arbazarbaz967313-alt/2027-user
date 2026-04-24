import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _emailC = TextEditingController();
  final _passC  = TextEditingController();
  final _nameC  = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose(); _emailC.dispose(); _passC.dispose(); _nameC.dispose();
    super.dispose();
  }

  void _go() => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));

  void _err(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: const Color(0xFFF72585)));

  Future<void> _login() async {
    if (_emailC.text.isEmpty || _passC.text.isEmpty) { _err('Fill all fields'); return; }
    setState(() => _loading = true);
    try {
      await AuthService.login(_emailC.text.trim(), _passC.text);
      _go();
    } on FirebaseAuthException catch (e) {
      _err(e.message ?? 'Login failed');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signup() async {
    if (_nameC.text.isEmpty || _emailC.text.isEmpty || _passC.text.isEmpty) { _err('Fill all fields'); return; }
    if (_passC.text.length < 6) { _err('Password min 6 characters'); return; }
    setState(() => _loading = true);
    try {
      final cred = await AuthService.signUp(_emailC.text.trim(), _passC.text);
      await cred.user?.updateDisplayName(_nameC.text.trim());
      _go();
    } on FirebaseAuthException catch (e) {
      _err(e.message ?? 'Signup failed');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _google() async {
    setState(() => _loading = true);
    try {
      final cred = await AuthService.googleSignIn();
      if (cred != null) _go();
    } catch (e) {
      _err('Google sign in failed');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF04040F),
    body: Stack(children: [
      // Background glow
      Positioned(top: -100, left: -50, child: Container(
        width: 300, height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF00F5D4).withOpacity(0.06),
        ),
      )),
      Column(children: [
        // Top preview
        Expanded(flex: 2, child: Center(child: Column(
          mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF00F5D4), Color(0xFF9B5DE5)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(child: Text('✦', style: TextStyle(fontSize: 32))),
            ),
            const SizedBox(height: 12),
            RichText(text: const TextSpan(
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 2),
              children: [
                TextSpan(text: 'Clear', style: TextStyle(color: Colors.white)),
                TextSpan(text: 'Cut', style: TextStyle(color: Color(0xFF00F5D4))),
              ],
            )),
            const SizedBox(height: 4),
            const Text('Remove • Enhance • Transform', style: TextStyle(color: Color(0xFF5A5A7A), fontSize: 12)),
          ],
        ))),

        // Bottom sheet
        Expanded(flex: 3, child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0E0E24),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(top: BorderSide(color: Color(0x14FFFFFF))),
          ),
          child: Column(children: [
            const SizedBox(height: 12),
            Container(width: 36, height: 4, decoration: BoxDecoration(color: const Color(0x26FFFFFF), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),

            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: const Color(0xFF04040F), borderRadius: BorderRadius.circular(14)),
              child: TabBar(
                controller: _tab,
                indicator: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF00F5D4), Color(0xFF9B5DE5)]),
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF5A5A7A),
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                tabs: const [Tab(text: 'Login'), Tab(text: 'Sign Up')],
              ),
            ),

            Expanded(child: TabBarView(
              controller: _tab,
              children: [_buildLogin(), _buildSignup()],
            )),
          ]),
        )),
      ]),
    ]),
  );

  Widget _buildLogin() => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(children: [
      _field(_emailC, 'Email', Icons.email_outlined, TextInputType.emailAddress),
      const SizedBox(height: 12),
      _field(_passC, 'Password', Icons.lock_outline, TextInputType.visiblePassword, obscure: true),
      Align(alignment: Alignment.centerRight,
        child: TextButton(onPressed: _forgotPass, child: const Text('Forgot password?', style: TextStyle(color: Color(0xFF00F5D4), fontSize: 12)))),
      const SizedBox(height: 8),
      _mainBtn('Login', _login),
      const SizedBox(height: 16),
      _divider(),
      const SizedBox(height: 16),
      _googleBtn(),
    ]),
  );

  Widget _buildSignup() => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(children: [
      _field(_nameC, 'Full Name', Icons.person_outline, TextInputType.name),
      const SizedBox(height: 12),
      _field(_emailC, 'Email', Icons.email_outlined, TextInputType.emailAddress),
      const SizedBox(height: 12),
      _field(_passC, 'Password (min 6 chars)', Icons.lock_outline, TextInputType.visiblePassword, obscure: true),
      const SizedBox(height: 16),
      _mainBtn('Create Account', _signup),
      const SizedBox(height: 16),
      _divider(),
      const SizedBox(height: 16),
      _googleBtn(),
    ]),
  );

  Widget _field(TextEditingController c, String hint, IconData icon, TextInputType type, {bool obscure = false}) =>
    TextField(
      controller: c,
      keyboardType: type,
      obscureText: obscure && _obscure,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF5A5A7A)),
        prefixIcon: Icon(icon, color: const Color(0xFF5A5A7A), size: 20),
        suffixIcon: obscure ? IconButton(
          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xFF5A5A7A), size: 20),
          onPressed: () => setState(() => _obscure = !_obscure),
        ) : null,
        filled: true, fillColor: const Color(0xFF04040F),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0x14FFFFFF))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0x14FFFFFF))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF00F5D4))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );

  Widget _mainBtn(String label, VoidCallback action) => SizedBox(
    width: double.infinity, height: 52,
    child: ElevatedButton(
      onPressed: _loading ? null : action,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ).copyWith(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF00F5D4), Color(0xFF9B5DE5)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(alignment: Alignment.center,
          child: _loading
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 1)),
        ),
      ),
    ),
  );

  Widget _divider() => Row(children: const [
    Expanded(child: Divider(color: Color(0x14FFFFFF))),
    Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('or', style: TextStyle(color: Color(0xFF5A5A7A), fontSize: 12))),
    Expanded(child: Divider(color: Color(0x14FFFFFF))),
  ]);

  Widget _googleBtn() => SizedBox(
    width: double.infinity, height: 48,
    child: OutlinedButton.icon(
      onPressed: _loading ? null : _google,
      icon: const Text('🌐', style: TextStyle(fontSize: 18)),
      label: const Text('Continue with Google', style: TextStyle(color: Colors.white, fontSize: 14)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0x26FFFFFF)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );

  void _forgotPass() async {
    if (_emailC.text.isEmpty) { _err('Enter your email first'); return; }
    await AuthService.resetPassword(_emailC.text.trim());
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reset email sent!'), backgroundColor: Color(0xFF00F5D4)));
  }
}
