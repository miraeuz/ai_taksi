import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/providers.dart';
import '../widgets/common.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override ConsumerState<LoginScreen> createState() => _LoginState();
}
class _LoginState extends ConsumerState<LoginScreen> {
  final phone = TextEditingController(text: '+998');
  final code = TextEditingController();
  final name = TextEditingController();
  bool isSignup = false, codeSent = false, busy = false;
  String? error;
  @override void dispose() { phone.dispose(); code.dispose(); name.dispose(); super.dispose(); }
  Future<void> request() async {
    if (!RegExp(r'^\+998\d{9}$').hasMatch(phone.text.trim())) { setState(() => error = 'Raqam +998XXXXXXXXX shaklida bo‘lishi kerak'); return; }
    setState(() { busy = true; error = null; });
    try { await ref.read(repositoryProvider).requestOtp(phone.text.trim(), isSignup ? 'signup' : 'login'); if (mounted) setState(() => codeSent = true); }
    catch (e) { if (mounted) setState(() => error = e.toString()); }
    finally { if (mounted) setState(() => busy = false); }
  }
  Future<void> verify() async {
    if (!RegExp(r'^\d{6}$').hasMatch(code.text)) { setState(() => error = '6 xonali kodni kiriting'); return; }
    if (isSignup && name.text.trim().length < 2) { setState(() => error = 'Ismingizni kiriting'); return; }
    setState(() { busy = true; error = null; });
    await ref.read(authProvider.notifier).verify(phone.text.trim(), code.text, isSignup ? 'signup' : 'login', name.text.trim());
    if (mounted) { final state = ref.read(authProvider); setState(() { busy = false; error = state.hasError ? state.error.toString() : null; }); }
  }
  @override Widget build(BuildContext context) => Scaffold(body: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 430), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    const Icon(Icons.directions_car_filled_rounded, color: primary, size: 76),
    const SizedBox(height: 12), const Text('AI Taksi', textAlign: TextAlign.center, style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: ink)),
    const Text('Bir yo‘nalish. Birga safar.', textAlign: TextAlign.center), const SizedBox(height: 38),
    SoftCard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(codeSent ? 'SMS orqali tasdiqlash' : 'Xush kelibsiz!', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)), const SizedBox(height: 18),
      if (!codeSent) ...[
        SegmentedButton<bool>(segments: const [ButtonSegment(value: false, label: Text('Kirish')), ButtonSegment(value: true, label: Text('Ro‘yxatdan o‘tish'))], selected: {isSignup}, onSelectionChanged: busy ? null : (v) => setState(() => isSignup = v.first)),
        const SizedBox(height: 16), TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Telefon raqami', prefixIcon: Icon(Icons.phone_outlined), border: OutlineInputBorder())),
        if (isSignup) ...[const SizedBox(height: 12), TextField(controller: name, decoration: const InputDecoration(labelText: 'Ism', border: OutlineInputBorder()))],
      ] else ...[
        Text('Kod ${phone.text} raqamiga yuborildi.'), const SizedBox(height: 14), TextField(controller: code, maxLength: 6, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '6 xonali SMS kod', prefixIcon: Icon(Icons.lock_outline), border: OutlineInputBorder())),
        const Text('Kod 5 daqiqa amal qiladi.', style: TextStyle(color: Colors.black54)),
        TextButton(onPressed: busy ? null : () => setState(() { codeSent = false; code.clear(); }), child: const Text('Raqamni o‘zgartirish')),
      ],
      if (error != null) ...[const SizedBox(height: 8), Text(error!, style: const TextStyle(color: Colors.red))],
      const SizedBox(height: 16), FilledButton(onPressed: busy ? null : (codeSent ? verify : request), child: busy ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(codeSent ? 'Tasdiqlash' : 'Davom etish')),
    ])), const SizedBox(height: 20), const Text('Haydovchilar faqat administrator tomonidan ro‘yxatdan o‘tkaziladi.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
  ])))));
}
