import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/chat_policy.dart';
import '../../models/models.dart';
import '../widgets/common.dart';

class TripOfferScreen extends ConsumerStatefulWidget {
  const TripOfferScreen({super.key});
  @override ConsumerState<TripOfferScreen> createState() => _TripOfferState();
}
class _TripOfferState extends ConsumerState<TripOfferScreen> {
  bool busy = false;
  @override Widget build(BuildContext context) => PageShell(title: 'Safar taklifi', child: ListView(padding: const EdgeInsets.all(18), children: [const PreviewNotice(), const SizedBox(height: 16), SoftCard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Container(height: 160, decoration: BoxDecoration(color: const Color(0xFFE0F6F2), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.airport_shuttle_rounded, size: 120, color: primary)), const SizedBox(height: 16), const Text('Damas', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)), const Text('01 A 123 BC'), const Divider(height: 32), const _Detail(icon: Icons.route, label: 'Yo‘nalish', value: 'Kosonsoy → Namangan / NamSU'), const _Detail(icon: Icons.schedule, label: 'Olib ketish vaqti', value: '10:40'), const _Detail(icon: Icons.groups, label: 'Yo‘lovchilar', value: '8 kishi'), const _Detail(icon: Icons.payments, label: 'Narx (bir kishi)', value: '20 000 so‘m'), const SizedBox(height: 18), const Text('Haqiqiy takliflar uchun rider offer listing API kerak.', style: TextStyle(color: Colors.black54, fontSize: 12)), const SizedBox(height: 14), FilledButton(onPressed: busy ? null : () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Namoyish: tasdiq serverga yuborilmadi'))), child: const Text('Tasdiqlash (namoyish)')), const SizedBox(height: 8), OutlinedButton(onPressed: busy ? null : () => Navigator.pop(context), child: const Text('Rad etish'))]))]));
}
class _Detail extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _Detail({required this.icon, required this.label, required this.value});
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [Icon(icon, color: primary), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)), Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold))]))]));
}
class ActiveTripScreen extends StatelessWidget {
  const ActiveTripScreen({super.key});
  @override Widget build(BuildContext context) => PageShell(title: 'Faol safar', child: ListView(padding: const EdgeInsets.all(18), children: [const PreviewNotice(), const SizedBox(height: 16), SoftCard(child: Column(children: [Container(height: 170, decoration: BoxDecoration(color: const Color(0xFFDBF4F0), borderRadius: BorderRadius.circular(16)), child: const Center(child: Icon(Icons.map_rounded, size: 100, color: primary))), const SizedBox(height: 16), const _Detail(icon: Icons.person, label: 'Haydovchi', value: 'Sherzod'), const _Detail(icon: Icons.airport_shuttle, label: 'Avtomobil', value: 'Damas · oq · 01 A 123 BC'), const _Detail(icon: Icons.place, label: 'Manzil', value: 'Namangan / NamSU'), const SizedBox(height: 12), OutlinedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(start: DateTime.now().add(const Duration(minutes: 30)), end: DateTime.now().add(const Duration(hours: 2))))), icon: const Icon(Icons.chat_bubble_outline), label: const Text('Safar chati (namoyish)')), FilledButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RatingScreen())), child: const Text('Safarni yakunlash va baholash (namoyish)'))]))]));
}
class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});
  @override State<RatingScreen> createState() => _RatingState();
}
class _RatingState extends State<RatingScreen> {
  int stars = 5;
  final comment = TextEditingController();
  bool submitting = false;
  @override void dispose() { comment.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => PageShell(title: 'Safarni baholash', child: ListView(padding: const EdgeInsets.all(18), children: [const PreviewNotice(), const SizedBox(height: 20), SoftCard(child: Column(children: [const Icon(Icons.stars_rounded, size: 64, color: primary), const SizedBox(height: 15), const Text('Safar qanday o‘tdi?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)), const SizedBox(height: 12), Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => IconButton(onPressed: () => setState(() => stars = i+1), icon: Icon(i < stars ? Icons.star_rounded : Icons.star_outline_rounded, size: 38, color: Colors.amber.shade700)))), TextField(controller: comment, maxLines: 3, decoration: const InputDecoration(labelText: 'Izoh (ixtiyoriy)', border: OutlineInputBorder())), const SizedBox(height: 18), FilledButton(onPressed: submitting ? null : () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Baholash API hali mavjud emas — baho yuborilmadi'))), child: const Text('Bahoni yuborish (namoyish)'))]))]));
}
class ChatScreen extends StatefulWidget {
  final DateTime start, end;
  const ChatScreen({super.key, required this.start, required this.end});
  @override State<ChatScreen> createState() => _ChatState();
}
class _ChatState extends State<ChatScreen> {
  final input = TextEditingController();
  final messages = <ChatMessage>[];
  String? error;
  @override void dispose() { input.dispose(); super.dispose(); }
  bool get open => ChatPolicy.withinWindow(DateTime.now(), widget.start, widget.end);
  void send() {
    if (!open) { setState(() => error = 'Chat oynasi yopilgan'); return; }
    if (!ChatPolicy.permitted(input.text)) { setState(() => error = 'Telefon raqami, @username yoki Telegram havolasi taqiqlangan'); return; }
    setState(() { error = null; messages.add(ChatMessage(sender: 'Siz', text: input.text.trim(), at: DateTime.now())); input.clear(); });
  }
  @override Widget build(BuildContext context) => PageShell(title: 'Safar chati · Namoyish', child: Column(children: [const Padding(padding: EdgeInsets.all(12), child: PreviewNotice()), Expanded(child: messages.isEmpty ? const Center(child: Text('Hozircha xabarlar yo‘q.\nBu faqat mahalliy chat namoyishi.', textAlign: TextAlign.center)) : ListView.builder(padding: const EdgeInsets.all(16), itemCount: messages.length, itemBuilder: (_, i) => Align(alignment: Alignment.centerRight, child: Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: SoftCard(child: Text(messages[i].text)))))), if (!open) const Padding(padding: EdgeInsets.all(12), child: Text('Chat faqat safardan 1 soat oldin va 1 soat keyingacha ochiq.')), if (error != null) Text(error!, style: const TextStyle(color: Colors.red)), Padding(padding: const EdgeInsets.all(12), child: Row(children: [Expanded(child: TextField(controller: input, enabled: open, decoration: const InputDecoration(hintText: 'Xabar yozing...', border: OutlineInputBorder()))), const SizedBox(width: 8), IconButton.filled(onPressed: open ? send : null, icon: const Icon(Icons.send))]))]));
}
