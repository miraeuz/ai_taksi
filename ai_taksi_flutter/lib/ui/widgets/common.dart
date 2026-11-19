import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';

const primary = Color(0xFF009A8B);
const ink = Color(0xFF10283A);
class PageShell extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  const PageShell({super.key, required this.title, required this.child, this.actions});
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), actions: actions),
    body: SafeArea(child: child),
  );
}
class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const SoftCard({super.key, required this.child, this.padding = const EdgeInsets.all(20)});
  @override Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: ink.withValues(alpha: .06), blurRadius: 20, offset: const Offset(0, 8))]),
    child: child,
  );
}
class Loadable<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T) builder;
  final VoidCallback retry;
  const Loadable({super.key, required this.value, required this.builder, required this.retry});
  @override Widget build(BuildContext context) => value.when(
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (e, st) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.wifi_off_rounded, size: 42), const SizedBox(height: 12), Text(readableError(e), textAlign: TextAlign.center), const SizedBox(height: 12), OutlinedButton(onPressed: retry, child: const Text('Qayta urinish'))]))),
    data: builder,
  );
}
class PreviewNotice extends StatelessWidget {
  const PreviewNotice({super.key});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: const Color(0xFFFFF3D6), borderRadius: BorderRadius.circular(12)),
    child: const Row(children: [Icon(Icons.info_outline, color: Color(0xFF865C00)), SizedBox(width: 10), Expanded(child: Text('Namoyish rejimi: bu ekran hali serverga ulanmagan.', style: TextStyle(fontSize: 12)))]),
  );
}
void showError(BuildContext context, Object error) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(readableError(error)))); }
