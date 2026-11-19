import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'state/providers.dart';
import 'ui/widgets/common.dart';
import 'ui/screens/auth_screen.dart';
import 'ui/screens/rider_screens.dart';
import 'ui/screens/driver_screens.dart';

void main() { WidgetsFlutterBinding.ensureInitialized(); runApp(const ProviderScope(child: AITaksiApp())); }
class AITaksiApp extends StatelessWidget {
  const AITaksiApp({super.key});
  @override Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'AI Taksi',
    locale: const Locale('uz'),
    supportedLocales: const [Locale('uz'), Locale('ru'), Locale('en')],
    localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate, GlobalWidgetsLocalizations.delegate],
    theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: const Color(0xFFF4F8F9), colorScheme: ColorScheme.fromSeed(seedColor: primary, primary: primary), textTheme: GoogleFonts.interTextTheme(), appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFF4F8F9), foregroundColor: ink, centerTitle: false), filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))))),
    home: const EntryGate(),
  );
}
class EntryGate extends ConsumerWidget {
  const EntryGate({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    return Loadable(value: auth, retry: () => ref.invalidate(authProvider), builder: (user) => user == null ? const LoginScreen() : user.role == 'rider' ? const RiderHome() : user.role == 'driver' ? const DriverHome() : Scaffold(body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('Admin paneli veb-ilovada mavjud.'), OutlinedButton(onPressed: () => ref.read(authProvider.notifier).logout(), child: const Text('Chiqish'))]))));
  }
}
