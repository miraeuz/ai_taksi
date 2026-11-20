import 'package:flutter/material.dart';

const navy = Color(0xFF102C36);
const teal = Color(0xFF008F86);
const mint = Color(0xFFE2F6F1);
const canvas = Color(0xFFF5F8F8);
const muted = Color(0xFF71858A);
const gold = Color(0xFFFFBE63);

ThemeData demoTheme() {
  final base = ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: teal, primary: teal, surface: Colors.white), scaffoldBackgroundColor: canvas);
  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: navy, displayColor: navy),
    appBarTheme: const AppBarTheme(backgroundColor: canvas, foregroundColor: navy, elevation: 0, centerTitle: false),
    navigationBarTheme: NavigationBarThemeData(backgroundColor: Colors.white, indicatorColor: mint,
      labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
    inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2EAEB))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2EAEB)))),
    filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(backgroundColor: teal, foregroundColor: Colors.white,
      minimumSize: const Size(0, 52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(fontWeight: FontWeight.w800))),
    outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(foregroundColor: teal,
      minimumSize: const Size(0, 50), side: const BorderSide(color: Color(0xFFCCE6E2)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))),
  );
}

class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const Panel({super.key, required this.child, this.padding = const EdgeInsets.all(20)});
  @override Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFEAF0F0)),
      boxShadow: [BoxShadow(color: navy.withValues(alpha: .035), blurRadius: 22, offset: const Offset(0, 9))]),
    child: child,
  );
}
class Label extends StatelessWidget {
  final String text;
  final Color color;
  const Label(this.text, {super.key, this.color = teal});
  @override Widget build(BuildContext context) => Text(text.toUpperCase(), style: TextStyle(fontSize: 11, letterSpacing: 1.25, color: color, fontWeight: FontWeight.w900));
}
class SectionHeading extends StatelessWidget {
  final String title;
  final String? caption;
  const SectionHeading(this.title, {super.key, this.caption});
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 14, top: 6), child: Row(children: [Expanded(child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900))), if (caption != null) Text(caption!, style: const TextStyle(color: teal, fontWeight: FontWeight.w700))]));
}
class DemoBadge extends StatelessWidget {
  const DemoBadge({super.key});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(color: const Color(0xFFFFF1D7), borderRadius: BorderRadius.circular(40)),
    child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.science_outlined, color: Color(0xFF966518), size: 14), SizedBox(width: 5), Text('DEMO · OFFLINE', style: TextStyle(fontSize: 10, letterSpacing: .4, fontWeight: FontWeight.w900, color: Color(0xFF966518)))]));
}
class InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const InfoPill(this.icon, this.label, {super.key});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8), decoration: BoxDecoration(color: mint, borderRadius: BorderRadius.circular(25)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 15, color: teal), const SizedBox(width: 5), Text(label, style: const TextStyle(fontSize: 12, color: teal, fontWeight: FontWeight.w800))]));
}
class RouteArt extends StatelessWidget {
  final double height;
  const RouteArt({super.key, this.height = 170});
  @override Widget build(BuildContext context) => Container(height: height,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFDAF5EE), Color(0xFFAFDFDB), Color(0xFF8FC7C9)])),
    child: Stack(children: [Positioned.fill(child: CustomPaint(painter: _MapPainter())), Positioned(left: 18, top: 18, child: const InfoPill(Icons.route_rounded, 'Kosonsoy  →  NamSU')),
      Positioned(right: 19, bottom: 13, child: Container(width: 70, height: 55, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black12)]), child: const Icon(Icons.airport_shuttle_rounded, size: 38, color: teal)))]));
}
class _MapPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final block = Paint()..color = Colors.white.withValues(alpha: .21);
    for (var i = 0; i < 7; i++) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH((i*83.0)%size.width, (i*49.0)%size.height, 50, 27), const Radius.circular(7)), block);
    }
    final road = Path()..moveTo(-10, size.height*.82)..cubicTo(size.width*.22, size.height*.45, size.width*.40, size.height*.92, size.width*.60, size.height*.46)..quadraticBezierTo(size.width*.83, size.height*.11, size.width+10, size.height*.38);
    canvas.drawPath(road, Paint()..color = Colors.white.withValues(alpha: .9)..strokeWidth = 7..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    canvas.drawPath(road, Paint()..color = teal..strokeWidth = 2.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    for (final point in [Offset(size.width*.20,size.height*.60), Offset(size.width*.60,size.height*.46)]) {
      canvas.drawCircle(point, 10, Paint()..color = Colors.white);
      canvas.drawCircle(point, 5, Paint()..color = teal);
    }
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
