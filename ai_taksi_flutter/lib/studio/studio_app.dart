import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'studio_state.dart';
import 'studio_design.dart';
import 'rider_pages.dart';
import 'driver_pages.dart';
import 'shared_pages.dart';

/// Visual-only preference. Does not modify the API or demo business state.
final auroraThemeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

void toggleAuroraTheme(WidgetRef ref) {
  final current = ref.read(auroraThemeModeProvider);
  ref.read(auroraThemeModeProvider.notifier).state =
      current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
}

class AIStudioApp extends ConsumerWidget {
  const AIStudioApp({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'AI Taksi · Aurora 4',
    locale: const Locale('uz'),
    supportedLocales: const [Locale('uz'), Locale('ru'), Locale('en')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    theme: studioTheme(),
    darkTheme: studioTheme(dark: true),
    themeMode: ref.watch(auroraThemeModeProvider),
    themeAnimationDuration: const Duration(milliseconds: 280),
    home: const StudioWelcome(),
  );
}

class StudioWelcome extends ConsumerWidget {
  const StudioWelcome({super.key});
  void _open(BuildContext context, WidgetRef ref, StudioRole role) {
    ref.read(studioProvider.notifier).switchRole(role);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StudioShell()));
  }

  @override Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    body: AuroraBackdrop(child: SafeArea(child: Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 650),
      child: ListView(padding: const EdgeInsets.fromLTRB(22, 25, 22, 35), children: [
        Row(children: [
          const StudioIconBox(Icons.route_rounded, color: auroraCyan,
            background: auroraNavy, size: 48),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('AI Taksi', style: TextStyle(color: context.surfaceInk,
              fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -.7)),
            Text('AURORA EXPERIENCE', style: TextStyle(
              color: context.subInk, letterSpacing: 1.65,
              fontWeight: FontWeight.w800, fontSize: 9)),
          ]),
          const Spacer(),
          _ThemeToggle(ref: ref),
        ]),
        const SizedBox(height: 36),
        const StudioEyebrow('2026  /  AQLLI HAMROH SAFARLAR'),
        const SizedBox(height: 10),
        Text('Har bir safar\nendi aqlliroq.', style: TextStyle(
          color: context.surfaceInk, fontSize: 43, height: 1.04,
          fontWeight: FontWeight.w900, letterSpacing: -1.8)),
        const SizedBox(height: 13),
        Text('Kosonsoydan Namanganga — bir yo‘nalish, birga qulayroq. '
          'Hozir ilovani haqiqiy akkauntsiz sinab ko‘ring.',
          style: TextStyle(color: context.subInk, fontSize: 14.5, height: 1.6)),
        const SizedBox(height: 25),
        const AuroraJourneyHero(
          eyebrow: 'KOSONSOY   →   NAMANGAN',
          title: 'Sizning yo‘lingiz.',
          subtitle: 'Bizning aqlli rejamiz.',
          footer: 'Yengil  ·  Damas  ·  Avtobus', height: 278),
        const SizedBox(height: 16),
        const Row(children: [
          Expanded(child: _WelcomeTag(Icons.groups_rounded, 'Birga')),
          SizedBox(width: 10),
          Expanded(child: _WelcomeTag(Icons.shield_outlined, 'Xavfsiz')),
          SizedBox(width: 10),
          Expanded(child: _WelcomeTag(Icons.auto_awesome, 'Aqlli')),
        ]),
        const SizedBox(height: 27),
        const StudioSection('Qaysi rejimni sinaysiz?'),
        _WelcomeRole(icon: Icons.school_outlined, title: 'Yo‘lovchi',
          subtitle: 'Jadval · avtopark · safar · chat',
          onTap: () => _open(context, ref, StudioRole.passenger)),
        const SizedBox(height: 11),
        _WelcomeRole(icon: Icons.local_taxi_outlined, title: 'Haydovchi',
          subtitle: 'Takliflar · bekatlar · narxlar',
          onTap: () => _open(context, ref, StudioRole.driver)),
        const SizedBox(height: 22),
        const DemoDisclaimer(),
      ]))))));
}

class _ThemeToggle extends StatelessWidget {
  final WidgetRef ref;
  const _ThemeToggle({required this.ref});
  @override Widget build(BuildContext context) => IconButton(
    tooltip: context.isNight ? 'Yorug‘ rejim' : 'Tungi rejim',
    onPressed: () => toggleAuroraTheme(ref),
    style: IconButton.styleFrom(
      backgroundColor: context.glassSurface,
      side: BorderSide(color: context.glassLine),
      minimumSize: const Size(45, 45)),
    icon: Icon(context.isNight ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
      color: context.isNight ? auroraCyan : auroraPurple),
  );
}

class _WelcomeTag extends StatelessWidget {
  final IconData icon;
  final String label;
  const _WelcomeTag(this.icon, this.label);
  @override Widget build(BuildContext context) => StudioCard(
    padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 7),
    radius: 17,
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 17, color: context.isNight ? auroraCyan : auroraPurple),
      const SizedBox(width: 6),
      Flexible(child: Text(label, maxLines: 1, style: TextStyle(
        color: context.surfaceInk, fontSize: 12, fontWeight: FontWeight.w800))),
    ]));
}
class _WelcomeRole extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  const _WelcomeRole({required this.icon, required this.title,
    required this.subtitle, required this.onTap});
  @override Widget build(BuildContext context) => Material(
    color: Colors.transparent, child: InkWell(onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: StudioCard(padding: const EdgeInsets.all(17), child: Row(children: [
        StudioIconBox(icon, size: 53), const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(color: context.surfaceInk,
            fontSize: 16.5, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: context.subInk, fontSize: 12)),
        ])),
        Icon(Icons.arrow_forward_rounded,
          color: context.isNight ? auroraCyan : auroraPurple),
      ]))));
}

class StudioShell extends ConsumerWidget {
  const StudioShell({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(studioProvider);
    final driver = s.role == StudioRole.driver;
    final pages = driver
      ? const <Widget>[DriverHomePage(), DriverOffersPage(), DriverPricesPage(), StudioProfilePage()]
      : const <Widget>[RiderHomePage(), RiderSchedulePage(), RiderTripPage(), StudioProfilePage()];
    final labels = driver
      ? const ['Asosiy', 'Takliflar', 'Narxlar', 'Profil']
      : const ['Asosiy', 'Jadval', 'Safarlar', 'Profil'];
    final icons = driver
      ? const [Icons.space_dashboard_outlined, Icons.local_taxi_outlined,
          Icons.payments_outlined, Icons.person_outline_rounded]
      : const [Icons.grid_view_rounded, Icons.calendar_month_outlined,
          Icons.route_outlined, Icons.person_outline_rounded];
    return Scaffold(
      body: AuroraBackdrop(child: SafeArea(bottom: false, child: Column(children: [
        Container(padding: const EdgeInsets.fromLTRB(19, 11, 12, 12),
          decoration: const BoxDecoration(gradient: LinearGradient(
            colors: [auroraNavy, Color(0xFF261461), auroraIndigo])),
          child: Row(children: [
            const StudioIconBox(Icons.local_taxi_rounded, color: auroraCyan,
              background: Color(0xFF2D2670), size: 43),
            const SizedBox(width: 11),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('AI Taksi', style: TextStyle(color: Colors.white,
                fontSize: 19, fontWeight: FontWeight.w900, letterSpacing: -.4)),
              SizedBox(height: 3),
              Text('KOSONSOY   •   NAMANGAN', style: TextStyle(
                color: Color(0xFFBAC5ED), letterSpacing: .95,
                fontWeight: FontWeight.w800, fontSize: 9)),
            ])),
            IconButton(tooltip: 'Mavzuni almashtirish',
              onPressed: () => toggleAuroraTheme(ref),
              icon: Icon(context.isNight ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: auroraCyan, size: 22)),
            InkWell(onTap: () => showDemoNotifications(context, ref),
              borderRadius: BorderRadius.circular(40),
              child: Stack(children: [
                const Padding(padding: EdgeInsets.all(9),
                  child: Icon(Icons.notifications_none_rounded, color: Colors.white, size: 23)),
                if (!s.notificationsRead) Positioned(top: 7, right: 7,
                  child: Container(width: 8, height: 8,
                    decoration: const BoxDecoration(color: auroraCyan,
                      shape: BoxShape.circle))),
              ])),
            const SizedBox(width: 3),
            const StudioPill('DEMO', icon: Icons.bolt_rounded,
              foreground: auroraCyan, background: Color(0xFF342779)),
          ])),
        Expanded(child: Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: AnimatedSwitcher(duration: const Duration(milliseconds: 230),
            child: KeyedSubtree(key: ValueKey('${s.role.name}_${s.tab}'),
              child: pages[s.tab]))))),
      ]))),
      bottomNavigationBar: SafeArea(top: false, child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(gradient: const LinearGradient(
          colors: [Color(0xFF09142D), Color(0xFF1D1A53), Color(0xFF0A1935)]),
          border: Border(top: BorderSide(color: auroraCyan.withValues(alpha: .18))),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .13),
            blurRadius: 18, offset: const Offset(0, -6))]),
        child: Row(children: List.generate(4, (i) => Expanded(child: InkWell(
          key: Key('nav_${labels[i]}'),
          borderRadius: BorderRadius.circular(17),
          onTap: () => ref.read(studioProvider.notifier).tab(i),
          child: AnimatedContainer(duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: i == s.tab ? const Color(0xFF34246D) : Colors.transparent,
              borderRadius: BorderRadius.circular(17)),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(icons[i], size: 21,
                color: i == s.tab ? auroraCyan : const Color(0xFFB5BEE2)),
              const SizedBox(height: 4),
              Text(labels[i], maxLines: 1, style: TextStyle(
                color: i == s.tab ? Colors.white : const Color(0xFFADB8D9),
                fontSize: 10.5, fontWeight: i == s.tab ? FontWeight.w900 : FontWeight.w600)),
            ])),
        )))),
      )),
    );
  }
}

void demoSnack(BuildContext context, String message) => ScaffoldMessenger.of(context)
  .showSnackBar(SnackBar(content: Text(message),
    duration: const Duration(seconds: 3)));
