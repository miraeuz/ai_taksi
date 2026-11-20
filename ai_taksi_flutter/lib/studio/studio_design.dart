import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';

// AURORA 4 / Slide-derived visual system. All visuals remain offline.
const ink = Color(0xFF111A34);
const inkSoft = Color(0xFF52617F);
const emerald = Color(0xFF713FF5); // Existing semantic action token; violet is intentional.
const emeraldDark = Color(0xFF5228CF);
const paleMint = Color(0xFFF0ECFF);
const softBackground = Color(0xFFF7F8FE);
const borderColor = Color(0xFFE3E7F6);
const softGrey = Color(0xFF8793AF);
const warmGold = Color(0xFFF5BB58);
const auroraNavy = Color(0xFF08142D);
const auroraIndigo = Color(0xFF17265A);
const auroraPurple = Color(0xFF713FF5);
const auroraCyan = Color(0xFF00E7E8);
const auroraCyanSoft = Color(0xFFE1FFFE);
const auroraDeep = Color(0xFF0B1129);

String uzs(int amount) => '${amount.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ' ')} so‘m';

extension AuroraContext on BuildContext {
  bool get isNight => Theme.of(this).brightness == Brightness.dark;
  Color get surfaceInk => Theme.of(this).colorScheme.onSurface;
  Color get subInk => isNight ? const Color(0xFFB1BEDB) : inkSoft;
  Color get glassSurface => isNight ? const Color(0xDC192445) : const Color(0xEEFFFFFF);
  Color get glassLine => isNight ? const Color(0xFF39456E) : const Color(0xFFE2E6F5);
}

ThemeData studioTheme({bool dark = false}) {
  final base = ThemeData(
    useMaterial3: true,
    brightness: dark ? Brightness.dark : Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: auroraPurple,
      brightness: dark ? Brightness.dark : Brightness.light,
      primary: dark ? const Color(0xFFA995FF) : auroraPurple,
      secondary: auroraCyan,
      surface: dark ? const Color(0xFF141D37) : Colors.white,
      onSurface: dark ? const Color(0xFFF4F5FF) : ink,
    ),
  );
  final surface = dark ? const Color(0xFF111B37) : Colors.white;
  final outline = dark ? const Color(0xFF344168) : borderColor;
  final muted = dark ? const Color(0xFFB1BEDB) : inkSoft;
  return base.copyWith(
    scaffoldBackgroundColor: dark ? auroraDeep : softBackground,
    canvasColor: surface,
    dividerColor: outline,
    textTheme: base.textTheme.apply(
      bodyColor: dark ? const Color(0xFFF4F5FF) : ink,
      displayColor: dark ? Colors.white : ink,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: dark ? auroraDeep : softBackground,
      foregroundColor: dark ? Colors.white : ink,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: surface,
      selectedColor: dark ? const Color(0xFF41287C) : paleMint,
      side: BorderSide(color: outline),
      labelStyle: TextStyle(color: dark ? Colors.white : ink, fontWeight: FontWeight.w700),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
    ),
    dividerTheme: DividerThemeData(color: outline, thickness: 1),
    filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
      backgroundColor: auroraPurple,
      foregroundColor: Colors.white,
      disabledBackgroundColor: dark ? const Color(0xFF38405F) : const Color(0xFFD7D1EB),
      minimumSize: const Size(0, 54),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      textStyle: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -.15),
    )),
    outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(
      foregroundColor: dark ? const Color(0xFFBFB4FF) : auroraPurple,
      side: BorderSide(color: dark ? const Color(0xFF6554A3) : const Color(0xFFD8CDFC)),
      minimumSize: const Size(0, 54),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      textStyle: const TextStyle(fontWeight: FontWeight.w800),
    )),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(
      foregroundColor: dark ? const Color(0xFFBFB4FF) : auroraPurple,
      textStyle: const TextStyle(fontWeight: FontWeight.w800))),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? const Color(0xFF212C4B) : Colors.white,
      hintStyle: TextStyle(color: muted),
      labelStyle: TextStyle(color: muted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: BorderSide(color: outline)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: BorderSide(color: outline)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide(color: dark ? auroraCyan : auroraPurple, width: 1.6)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: dark ? const Color(0xFF182342) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: dark ? const Color(0xFF192544) : Colors.white,
      modalBackgroundColor: dark ? const Color(0xFF192544) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: dark ? const Color(0xFF39306C) : auroraNavy,
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}

// Subtle environmental glow behind all pages, no network assets or animation jank.
class AuroraBackdrop extends StatelessWidget {
  final Widget child;
  const AuroraBackdrop({super.key, required this.child});
  @override Widget build(BuildContext context) => Stack(children: [
    Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: context.isNight
        ? const [Color(0xFF0A1331), Color(0xFF161137), Color(0xFF081B31)]
        : const [Color(0xFFF3F5FF), Color(0xFFF9F9FF), Color(0xFFEAF9FF)])))),
    Positioned(right: -135, top: -115, child: _Glow(size: 340,
      color: context.isNight ? auroraPurple.withValues(alpha: .17) : auroraPurple.withValues(alpha: .11))),
    Positioned(left: -130, bottom: -95, child: _Glow(size: 280,
      color: auroraCyan.withValues(alpha: context.isNight ? .10 : .13))),
    Positioned.fill(child: child),
  ]);
}
class _Glow extends StatelessWidget {
  final double size;
  final Color color;
  const _Glow({required this.size, required this.color});
  @override Widget build(BuildContext context) => Container(width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle,
      gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)])));
}

class StudioCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Border? border;
  final double radius;
  const StudioCard({super.key, required this.child,
    this.padding = const EdgeInsets.all(19), this.color,
    this.border, this.radius = 24});
  @override Widget build(BuildContext context) {
    final fill = color == paleMint && context.isNight
      ? const Color(0xFF29214D) : color ?? context.glassSurface;
    return DecoratedBox(decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [BoxShadow(
        color: (context.isNight ? Colors.black : auroraIndigo)
          .withValues(alpha: context.isNight ? .12 : .055),
        blurRadius: 24, offset: const Offset(0, 12))]),
      child: ClipRRect(borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: DecoratedBox(decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(radius),
            border: border ?? Border.all(color: context.glassLine.withValues(alpha: .88))),
            child: Padding(padding: padding, child: child)))));
  }
}

class StudioEyebrow extends StatelessWidget {
  final String title;
  final Color? color;
  const StudioEyebrow(this.title, {super.key, this.color});
  @override Widget build(BuildContext context) => Text(title.toUpperCase(),
    style: TextStyle(color: color ?? (context.isNight ? auroraCyan : auroraPurple),
      fontSize: 10.5, letterSpacing: 1.7, fontWeight: FontWeight.w900));
}
class StudioHeadline extends StatelessWidget {
  final String title, subtitle;
  final String? eyebrow;
  const StudioHeadline({super.key, required this.title, required this.subtitle, this.eyebrow});
  @override Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (eyebrow != null) ...[StudioEyebrow(eyebrow!), const SizedBox(height: 7)],
      Text(title, style: TextStyle(color: context.surfaceInk, fontSize: 29, height: 1.12,
        fontWeight: FontWeight.w900, letterSpacing: -1.05)),
      const SizedBox(height: 8),
      Text(subtitle, style: TextStyle(color: context.subInk,
        fontSize: 13.5, height: 1.55)),
    ]);
}
class StudioSection extends StatelessWidget {
  final String title;
  final String? trailing;
  final VoidCallback? onTap;
  const StudioSection(this.title, {super.key, this.trailing, this.onTap});
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 14),
    child: Row(children: [Expanded(child: Text(title,
      style: TextStyle(color: context.surfaceInk, fontSize: 18.5,
        letterSpacing: -.35, fontWeight: FontWeight.w900))),
      if (trailing != null) InkWell(onTap: onTap,
        child: Text(trailing!, style: TextStyle(
          color: context.isNight ? auroraCyan : auroraPurple,
          fontSize: 12, fontWeight: FontWeight.w800)))]));
}
class StudioPill extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color foreground, background;
  const StudioPill(this.text, {super.key, this.icon,
    this.foreground = auroraPurple, this.background = paleMint});
  @override Widget build(BuildContext context) {
    final useNight = context.isNight && background == paleMint;
    final fg = useNight ? const Color(0xFFD5C8FF) : foreground;
    final bg = useNight ? const Color(0xFF382664) : background;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(30)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, color: fg, size: 13), const SizedBox(width: 5)],
        Text(text, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900,
            color: fg, letterSpacing: .2)),
      ]));
  }
}
class StudioIconBox extends StatelessWidget {
  final IconData icon;
  final Color color, background;
  final double size;
  const StudioIconBox(this.icon, {super.key,
    this.color = Colors.white, this.background = auroraPurple, this.size = 44});
  @override Widget build(BuildContext context) {
    final bg = background == paleMint && context.isNight ? const Color(0xFF37266C) : background;
    final fg = color == auroraPurple && background == paleMint && context.isNight
      ? const Color(0xFFD5C8FF) : color;
    return Container(width: size, height: size, alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: background == auroraPurple
          ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF9664FF), Color(0xFF6338E6)]) : null,
        color: background == auroraPurple ? null : bg,
        borderRadius: BorderRadius.circular(size * .32)),
      child: Icon(icon, color: fg, size: size * .48));
  }
}
class StudioMetric extends StatelessWidget {
  final String figure, label;
  final IconData icon;
  const StudioMetric(this.figure, this.label, this.icon, {super.key});
  @override Widget build(BuildContext context) => StudioCard(
    padding: const EdgeInsets.all(15), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        StudioIconBox(icon, size: 38), const SizedBox(height: 13),
        Text(figure, style: TextStyle(color: context.surfaceInk,
          fontSize: 24, fontWeight: FontWeight.w900)),
        Text(label, style: TextStyle(color: context.subInk, fontSize: 11.5)),
      ]));
}

class StudioRouteMap extends StatelessWidget {
  final double height;
  final bool dark;
  const StudioRouteMap({super.key, this.height = 194, this.dark = false});
  @override Widget build(BuildContext context) {
    final night = dark || context.isNight;
    return ClipRRect(borderRadius: BorderRadius.circular(24), child: Container(
      height: height, decoration: BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: night ? const [Color(0xFF0B1633), Color(0xFF302075), Color(0xFF112A56)]
          : const [Color(0xFFEAE9FF), Color(0xFFDCE9FF), Color(0xFFCCFAFF)])),
      child: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _RoutePainter(night))),
        Positioned(left: 16, top: 15, child: StudioPill('KOSONSOY',
          icon: Icons.trip_origin_rounded,
          foreground: night ? Colors.white : auroraPurple,
          background: night ? const Color(0xFF44368A) : Colors.white)),
        Positioned(right: 16, bottom: 15, child: StudioPill('NAMSU',
          icon: Icons.location_on_rounded,
          foreground: night ? Colors.white : auroraPurple,
          background: night ? const Color(0xFF44368A) : Colors.white)),
        Positioned(left: 19, bottom: 16, child: StudioIconBox(Icons.airport_shuttle_rounded,
          color: auroraCyan, background: auroraNavy, size: 44)),
      ])));
  }
}
class _RoutePainter extends CustomPainter {
  final bool dark;
  const _RoutePainter(this.dark);
  @override void paint(Canvas canvas, Size size) {
    final block = dark ? const Color(0xFF51428E) : const Color(0xFFB8C7ED);
    for (int i = 0; i < 22; i++) {
      final x = ((i * 73 + 22) % 371) / 371 * size.width;
      final y = ((i * 43 + 9) % 211) / 211 * size.height;
      canvas.save(); canvas.translate(x, y); canvas.rotate(i.isEven ? -.2 : .18);
      canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, 24 + (i % 3) * 15, 12 + (i % 4) * 5),
        const Radius.circular(4)), Paint()..color = block.withValues(alpha: .36));
      canvas.restore();
    }
    final path = Path()..moveTo(-12, size.height * .77)
      ..cubicTo(size.width * .31, size.height * 1.04,
        size.width * .22, size.height * .17, size.width * .57, size.height * .47)
      ..cubicTo(size.width * .8, size.height * .61,
        size.width * .8, size.height * .10, size.width + 16, size.height * .26);
    canvas.drawPath(path, Paint()..color = auroraCyan.withValues(alpha: .20)
      ..style = PaintingStyle.stroke..strokeWidth = 18..strokeCap = StrokeCap.round);
    canvas.drawPath(path, Paint()..color = Colors.white.withValues(alpha: .80)
      ..style = PaintingStyle.stroke..strokeWidth = 7..strokeCap = StrokeCap.round);
    canvas.drawPath(path, Paint()..color = auroraCyan
      ..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round);
    for (final point in [Offset(size.width * .16, size.height * .79),
      Offset(size.width * .56, size.height * .47), Offset(size.width * .88, size.height * .3)]) {
      canvas.drawCircle(point, 8, Paint()..color = auroraCyan.withValues(alpha: .25));
      canvas.drawCircle(point, 5, Paint()..color = Colors.white);
      canvas.drawCircle(point, 3, Paint()..color = auroraPurple);
    }
    final subtle = Paint()..color = (dark ? Colors.white : auroraPurple).withValues(alpha: .11)
      ..style = PaintingStyle.stroke..strokeWidth = 1.1;
    for (int i = 0; i < 5; i++) {
      final x = i * size.width / 4;
      canvas.drawArc(Rect.fromCenter(center: Offset(x, size.height * .13),
        width: 29, height: 12), math.pi, math.pi, false, subtle);
    }
  }
  @override bool shouldRepaint(covariant _RoutePainter old) => old.dark != dark;
}

class AuroraJourneyHero extends StatelessWidget {
  final String eyebrow, title, subtitle, footer;
  final double height;
  const AuroraJourneyHero({super.key,
    this.eyebrow = 'AQLLI YO‘NALISH',
    this.title = 'Kosonsoy',
    this.subtitle = 'Namangan / NamSU',
    this.footer = 'Du · Ch / 13:00 gacha',
    this.height = 246});
  @override Widget build(BuildContext context) => Container(
    height: height, clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(29),
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [auroraNavy, Color(0xFF271060), Color(0xFF673BE2)]),
      border: Border.all(color: const Color(0xFF755CB4).withValues(alpha: .52)),
      boxShadow: [BoxShadow(color: auroraPurple.withValues(alpha: context.isNight ? .22 : .17),
        blurRadius: 29, offset: const Offset(0, 13))]),
    child: Stack(fit: StackFit.expand, children: [
      Positioned(right: -100, top: 36, bottom: -5, width: 355,
        child: Image.asset('assets/images/vehicle_scene.webp',
          fit: BoxFit.cover, alignment: Alignment.center)),
      const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
        begin: Alignment.centerLeft, end: Alignment.centerRight,
        stops: [.0, .33, .7, 1],
        colors: [Color(0xFF08142D), Color(0xF50E1740), Color(0x9B2C1665), Color(0x33713FF5)]))),
      Positioned(right: -35, top: -95, child: Container(width: 200, height: 200,
        decoration: BoxDecoration(shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: auroraPurple.withValues(alpha: .45),
            spreadRadius: 30, blurRadius: 95)]))),
      Positioned(right: 15, top: 17, child: Container(padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(shape: BoxShape.circle,
          color: const Color(0x79392C88), border: Border.all(color: const Color(0x6658FFFF))),
        child: const Icon(Icons.auto_awesome_rounded, color: auroraCyan, size: 20))),
      Positioned(left: -2, right: -2, bottom: 41,
        child: IgnorePointer(child: SizedBox(height: 72, child: CustomPaint(painter: _HeroRoutePainter())))),
      Padding(padding: const EdgeInsets.all(21), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Container(width: 4, height: 16,
            decoration: BoxDecoration(color: auroraCyan,
              borderRadius: BorderRadius.circular(8))),
            const SizedBox(width: 9), Flexible(child: Text(eyebrow.toUpperCase(),
              style: const TextStyle(color: auroraCyan, letterSpacing: 1.3,
                fontWeight: FontWeight.w900, fontSize: 10)))]),
          const SizedBox(height: 19),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 30,
              fontWeight: FontWeight.w900, letterSpacing: -.8)),
          const SizedBox(height: 3),
          const Icon(Icons.south_rounded, color: auroraCyan, size: 21),
          const SizedBox(height: 3),
          Text(subtitle, maxLines: 2,
            style: const TextStyle(color: Colors.white,
              fontSize: 18, fontWeight: FontWeight.w800)),
          const Spacer(),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(color: const Color(0x9E0B1D42),
              border: Border.all(color: const Color(0x445CF3FD)),
              borderRadius: BorderRadius.circular(13)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.calendar_month_outlined, color: auroraCyan, size: 16),
              const SizedBox(width: 8), Flexible(child: Text(footer, maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFFEAF0FF),
                  fontSize: 11.5, fontWeight: FontWeight.w800))),
            ])),
        ])),
    ]));
}
class _HeroRoutePainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final path = Path()..moveTo(-8, size.height * .95)
      ..cubicTo(size.width * .25, size.height * .36,
        size.width * .31, size.height * 1.2, size.width * .53, size.height * .54)
      ..cubicTo(size.width * .77, size.height * -.15,
        size.width * .85, size.height * .67, size.width + 8, size.height * .08);
    canvas.drawPath(path, Paint()..color = auroraCyan.withValues(alpha: .26)
      ..style = PaintingStyle.stroke..strokeWidth = 14..strokeCap = StrokeCap.round);
    canvas.drawPath(path, Paint()..color = auroraCyan
      ..style = PaintingStyle.stroke..strokeWidth = 3.3..strokeCap = StrokeCap.round);
    canvas.drawCircle(Offset(size.width * .52, size.height * .53), 7,
      Paint()..color = Colors.white);
    canvas.drawCircle(Offset(size.width * .52, size.height * .53), 4,
      Paint()..color = auroraPurple);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
