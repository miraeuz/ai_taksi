import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'demo/demo_screens.dart';
import 'demo/demo_state.dart';
import 'demo/demo_theme.dart';
import 'state/providers.dart';
import 'ui/screens/auth_screen.dart';
import 'ui/screens/rider_screens.dart';
import 'ui/screens/driver_screens.dart';
import 'ui/widgets/common.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AITaksiApp()));
}

class AITaksiApp extends StatelessWidget {
  const AITaksiApp({super.key});
  @override Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'AI Taksi',
    locale: const Locale('uz'),
    supportedLocales: const [Locale('uz'), Locale('ru'), Locale('en')],
    localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate, GlobalWidgetsLocalizations.delegate],
    theme: demoTheme(),
    home: const LaunchScreen(),
  );
}

class LaunchScreen extends ConsumerWidget {
  const LaunchScreen({super.key});
  void enter(BuildContext context, WidgetRef ref, DemoRole role) {
    ref.read(demoProvider.notifier).switchRole(role);
    Navigator.push(context, MaterialPageRoute(builder: (_) => const DemoApp()));
  }
  @override Widget build(BuildContext context, WidgetRef ref) => Scaffold(body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 600), child: ListView(padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 29), children: [
    const Row(children: [Icon(Icons.route_rounded, size: 32, color: teal), SizedBox(width: 10), Text('AI Taksi', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900))]),
    const SizedBox(height: 44), const Label('YANGI MOBIL TAJRIBA'), const SizedBox(height: 12),
    const Text('Bir yo‘nalish.\nBirga safar.', style: TextStyle(fontSize: 43, height: 1.12, fontWeight: FontWeight.w900, letterSpacing: -1.5)),
    const SizedBox(height: 12), const Text('Kosonsoydan Namanganga aqlli, qulay va hamyonbop qatnov.', style: TextStyle(fontSize: 16, color: muted, height: 1.6)),
    const SizedBox(height: 24), const RouteArt(height: 205), const SizedBox(height: 26),
    const SectionHeading('Dizaynni sinab ko‘ring'),
    Panel(padding: const EdgeInsets.all(16), child: Column(children: [
      ListTile(contentPadding: EdgeInsets.zero, leading: const CircleAvatar(radius: 25, backgroundColor: mint, child: Icon(Icons.school_rounded, color: teal)), title: const Text('Yo‘lovchi sifatida', style: TextStyle(fontWeight: FontWeight.w900)), subtitle: const Text('Jadval · safar · chat · baholash'), trailing: const Icon(Icons.arrow_forward_rounded, color: teal), onTap: () => enter(context, ref, DemoRole.rider)),
      const Divider(),
      ListTile(contentPadding: EdgeInsets.zero, leading: const CircleAvatar(radius: 25, backgroundColor: mint, child: Icon(Icons.drive_eta_rounded, color: teal)), title: const Text('Haydovchi sifatida', style: TextStyle(fontWeight: FontWeight.w900)), subtitle: const Text('Takliflar · bekatlar · narxlar'), trailing: const Icon(Icons.arrow_forward_rounded, color: teal), onTap: () => enter(context, ref, DemoRole.driver)),
    ])), const SizedBox(height: 17),
    const Row(mainAxisAlignment: MainAxisAlignment.center, children: [DemoBadge()]), const SizedBox(height: 18),
    OutlinedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EntryGate())), icon: const Icon(Icons.cloud_outlined), label: const Text('Haqiqiy API orqali kirish')),
    const SizedBox(height: 9), const Center(child: Text('Demo internet va SMSsiz ishlaydi. Ma’lumotlar namunaviy.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: muted))),
  ])))));
}

// Existing backend-connected role gate stays separate from offline demo.
class EntryGate extends ConsumerWidget {
  const EntryGate({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    return Loadable(value: auth, retry: () => ref.invalidate(authProvider), builder: (user) => user == null
      ? const LoginScreen()
      : user.role == 'rider' ? const RiderHome()
      : user.role == 'driver' ? const DriverHome()
      : Scaffold(body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('Admin paneli veb-ilovada mavjud.'), OutlinedButton(onPressed: () => ref.read(authProvider.notifier).logout(), child: const Text('Chiqish'))]))));
  }
}
