import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/user_provider.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});
  @override
  State<PremiumScreen> createState() => _PremiumState();
}

class _PremiumState extends State<PremiumScreen> {
  bool _loading = false;
  String _selected = 'pro_monthly';

  Future<void> _buy() async {
    setState(() => _loading = true);
    try {
      final order = await ApiService().createOrder(_selected);
      if (!mounted) return;
      // TODO: integrate razorpay_flutter plugin here
      // Razorpay().open({ 'key': order['key_id'], 'amount': order['amount'], ... })
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF0E0E24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Order Created ✅', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Order ID: ${order['order_id']}', style: const TextStyle(color: Color(0xFF5A5A7A), fontSize: 12)),
            const SizedBox(height: 8),
            const Text('Add razorpay_flutter plugin to complete payment flow.', style: TextStyle(color: Color(0xFF5A5A7A), fontSize: 13)),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Color(0xFFFFD60A), fontWeight: FontWeight.w700))),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: const Color(0xFFF72585)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFF04040F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF04040F),
        elevation: 0,
        title: const Text('Go Pro', style: TextStyle(color: Color(0xFFFFD60A), fontWeight: FontWeight.w800, fontSize: 20)),
      ),
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          if (user.isPro) ...[
            Container(
              width: double.infinity, padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD60A).withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFD60A).withOpacity(0.3)),
              ),
              child: Column(children: const [
                Text('★', style: TextStyle(fontSize: 40)),
                SizedBox(height: 8),
                Text('You are Pro!', style: TextStyle(color: Color(0xFFFFD60A), fontSize: 22, fontWeight: FontWeight.w800)),
                SizedBox(height: 4),
                Text('Enjoy unlimited access to all features', style: TextStyle(color: Color(0xFF5A5A7A), fontSize: 13)),
              ]),
            ),
          ] else ...[
            const Text('★', style: TextStyle(fontSize: 50)),
            const SizedBox(height: 8),
            const Text('Unlock Everything', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('Unlimited AI · 4K quality · No limits', style: TextStyle(color: Color(0xFF5A5A7A), fontSize: 13)),
            const SizedBox(height: 28),

            // Plans
            _PlanCard(
              planKey: 'pro_monthly', name: 'Pro Monthly', price: '₹199', per: '/month',
              features: const ['Unlimited exports', 'No watermark on output', '4x AI enhancement', 'Priority processing'],
              isPopular: true, isSelected: _selected == 'pro_monthly',
              onTap: () => setState(() => _selected = 'pro_monthly'),
            ),
            const SizedBox(height: 12),
            _PlanCard(
              planKey: 'pro_annual', name: 'Pro Annual', price: '₹999', per: '/year',
              features: const ['Everything in Monthly', 'Save 58% vs monthly', 'Early access to features', '10GB cloud storage'],
              isPopular: false, isSelected: _selected == 'pro_annual', saveBadge: 'SAVE 58%',
              onTap: () => setState(() => _selected = 'pro_annual'),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity, height: 54,
              child: ElevatedButton(
                onPressed: _loading ? null : _buy,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD60A),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _loading
                  ? const CircularProgressIndicator(color: Colors.black, strokeWidth: 2)
                  : const Text('Get Pro Now', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Secure payment via Razorpay & UPI\nCancel anytime · Instant activation',
              style: TextStyle(color: Color(0xFF5A5A7A), fontSize: 11), textAlign: TextAlign.center),
          ],

          // Stats
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF0E0E24),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x12FFFFFF)),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _Stat('2M+', 'Users'),
              Container(width: 1, height: 40, color: const Color(0x12FFFFFF)),
              _Stat('50M+', 'Files Edited'),
              Container(width: 1, height: 40, color: const Color(0x12FFFFFF)),
              _Stat('4.8 ★', 'Rating'),
            ]),
          ),
        ]),
      )),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String planKey, name, price, per;
  final List<String> features;
  final bool isPopular, isSelected;
  final String? saveBadge;
  final VoidCallback onTap;
  const _PlanCard({required this.planKey, required this.name, required this.price, required this.per,
    required this.features, required this.isPopular, required this.isSelected, this.saveBadge, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFD60A).withOpacity(0.05) : const Color(0xFF0E0E24),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isSelected ? const Color(0xFFFFD60A) : const Color(0x12FFFFFF), width: 1.5),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
            if (isPopular) ...[const SizedBox(width: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFFFD60A), borderRadius: BorderRadius.circular(4)),
                child: const Text('POPULAR', style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w800)))],
            if (saveBadge != null) ...[const SizedBox(width: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFF34D399), borderRadius: BorderRadius.circular(4)),
                child: Text(saveBadge!, style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w800)))],
          ]),
          const SizedBox(height: 8),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(children: [
              const Text('✓ ', style: TextStyle(color: Color(0xFF00F5D4), fontSize: 12, fontWeight: FontWeight.w700)),
              Text(f, style: const TextStyle(color: Color(0xFF5A5A7A), fontSize: 12)),
            ]),
          )),
        ])),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(price, style: const TextStyle(color: Color(0xFFFFD60A), fontSize: 22, fontWeight: FontWeight.w800)),
          Text(per, style: const TextStyle(color: Color(0xFF5A5A7A), fontSize: 11)),
        ]),
      ]),
    ),
  );
}

class _Stat extends StatelessWidget {
  final String val, label;
  const _Stat(this.val, this.label);
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
    const SizedBox(height: 2),
    Text(label, style: const TextStyle(color: Color(0xFF5A5A7A), fontSize: 10)),
  ]);
}
