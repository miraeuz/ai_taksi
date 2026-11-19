import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../state/providers.dart';
import '../widgets/common.dart';
import 'trip_screens.dart';

class DriverHome extends ConsumerWidget {
  const DriverHome({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) => PageShell(title: 'AI Taksi · Haydovchi', actions: [IconButton(onPressed: () => ref.read(authProvider.notifier).logout(), icon: const Icon(Icons.logout))], child: RefreshIndicator(onRefresh: () async { ref.invalidate(driverOffersProvider); await ref.read(driverOffersProvider.future); }, child: ListView(padding: const EdgeInsets.all(18), children: [const Text('Bugungi takliflar', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 25)), const SizedBox(height: 12), Loadable(value: ref.watch(driverOffersProvider), retry: () => ref.invalidate(driverOffersProvider), builder: (rows) { final active = rows.where((r) => r.status == 'offered').toList(); if (active.isEmpty) return const SoftCard(child: Text('Hozircha faol taklif yo‘q. Pastga tortib yangilang.')); return Column(children: active.map((r) => Padding(padding: const EdgeInsets.only(bottom: 12), child: DriverOfferCard(offer: r))).toList()); }), const SizedBox(height: 16), SoftCard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [const Text('Narx jadvali', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)), const SizedBox(height: 12), OutlinedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DriverPricesScreen())), child: const Text('Guruh hajmi bo‘yicha narxlar'))])), const SizedBox(height: 12), const PreviewNotice(), const SizedBox(height: 12), OutlinedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DriverTripDetail())), child: const Text('Bekatlar ro‘yxati (namoyish)'))])));
}
class DriverOfferCard extends ConsumerStatefulWidget {
  final DriverOffer offer;
  const DriverOfferCard({super.key, required this.offer});
  @override ConsumerState<DriverOfferCard> createState() => _OfferState();
}
class _OfferState extends ConsumerState<DriverOfferCard> {
  bool busy = false;
  Timer? ticker;
  @override void initState() {
    super.initState();
    ticker = Timer.periodic(const Duration(seconds: 1), (_) { if (mounted) setState(() {}); });
  }
  @override void dispose() { ticker?.cancel(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final seconds = widget.offer.expiresAt?.difference(DateTime.now()).inSeconds ?? 0;
    return SoftCard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Row(children: [const Icon(Icons.local_taxi_rounded, color: primary), const SizedBox(width: 10), Expanded(child: Text('Safar #${widget.offer.tripId}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 19))), Text(seconds <= 0 ? 'Muddati o‘tgan' : '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))]), const SizedBox(height: 5), Text('Holat: ${widget.offer.status}'), const Text('Yo‘nalish, yo‘lovchilar va narx ma’lumotlari mavjud API javobida yo‘q.', style: TextStyle(color: Colors.black54, fontSize: 12)), const SizedBox(height: 12), Row(children: [Expanded(child: FilledButton(onPressed: busy || seconds <= 0 ? null : () => respond(true), child: busy ? const CircularProgressIndicator(color: Colors.white) : const Text('Qabul qilish'))), const SizedBox(width: 8), Expanded(child: OutlinedButton(onPressed: busy || seconds <= 0 ? null : () => respond(false), child: const Text('Rad etish')))]), const SizedBox(height: 8), const Text('Qolgan vaqt ma’lumot yangilanganda hisoblanadi.', style: TextStyle(fontSize: 11, color: Colors.black54))]));
  }
  Future<void> respond(bool accept) async {
    setState(() => busy = true);
    try { await ref.read(repositoryProvider).respondOffer(widget.offer.id, accept); ref.invalidate(driverOffersProvider); }
    catch (e) { if (mounted) showError(context, e); }
    finally { if (mounted) setState(() => busy = false); }
  }
}
class DriverPricesScreen extends ConsumerStatefulWidget {
  const DriverPricesScreen({super.key});
  @override ConsumerState<DriverPricesScreen> createState() => _PricesState();
}
class _PricesState extends ConsumerState<DriverPricesScreen> {
  final min = TextEditingController(text: '4'), max = TextEditingController(text: '8'), price = TextEditingController(text: '20000');
  bool busy = false;
  @override void dispose() { min.dispose(); max.dispose(); price.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => PageShell(title: 'Narxlar jadvali', child: ListView(padding: const EdgeInsets.all(18), children: [Loadable(value: ref.watch(driverPricesProvider), retry: () => ref.invalidate(driverPricesProvider), builder: (items) => Column(children: items.isEmpty ? [const SoftCard(child: Text('Narx oralig‘i kiritilmagan'))] : items.map((p) => Padding(padding: const EdgeInsets.only(bottom: 10), child: SoftCard(child: Row(children: [const Icon(Icons.payments_outlined, color: primary), const SizedBox(width: 12), Expanded(child: Text('${p.minRiders}–${p.maxRiders} yo‘lovchi', style: const TextStyle(fontWeight: FontWeight.bold))), Text('${prettyMoney(p.price)} so‘m')]))).toList())), const SizedBox(height: 20), SoftCard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [const Text('Narx belgilash', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)), const SizedBox(height: 16), Row(children: [Expanded(child: TextField(controller: min, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Min. kishi', border: OutlineInputBorder()))), const SizedBox(width: 8), Expanded(child: TextField(controller: max, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Maks. kishi', border: OutlineInputBorder())))]), const SizedBox(height: 10), TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Bir kishiga narx (so‘m)', border: OutlineInputBorder())), const SizedBox(height: 10), const Text('Yo‘nalish ID = 1 (pilot).', style: TextStyle(fontSize: 12)), const SizedBox(height: 14), FilledButton(onPressed: busy ? null : save, child: busy ? const CircularProgressIndicator(color: Colors.white) : const Text('Saqlash'))]))]));
  Future<void> save() async {
    final lo = int.tryParse(min.text), hi = int.tryParse(max.text), amount = double.tryParse(price.text);
    if (lo == null || hi == null || amount == null || lo < 1 || hi < lo || amount <= 0) { showError(context, 'Narx oralig‘ini to‘g‘ri kiriting'); return; }
    setState(() => busy = true);
    try { await ref.read(repositoryProvider).setPrice(1, lo, hi, amount); ref.invalidate(driverPricesProvider); }
    catch (e) { if (mounted) showError(context, e); }
    finally { if (mounted) setState(() => busy = false); }
  }
}
class DriverTripDetail extends StatelessWidget {
  const DriverTripDetail({super.key});
  @override Widget build(BuildContext context) => PageShell(title: 'Safar tafsilotlari', child: ListView(padding: const EdgeInsets.all(18), children: [const PreviewNotice(), const SizedBox(height: 16), const SoftCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Kosonsoy → NamSU', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)), Text('Olib ketish tartibi · namunaviy'), Divider(), ListTile(leading: CircleAvatar(child: Text('1')), title: Text('Kosonsoy markazi'), subtitle: Text('10:40 · 3 yo‘lovchi')), ListTile(leading: CircleAvatar(child: Text('2')), title: Text('Kosonsoy bozori'), subtitle: Text('10:50 · 3 yo‘lovchi')), ListTile(leading: CircleAvatar(child: Text('3')), title: Text('Kosonsoy janub'), subtitle: Text('11:00 · 2 yo‘lovchi'))])), const SizedBox(height: 16), FilledButton(onPressed: null, child: Text('Safarni boshlash · API kerak')), const SizedBox(height: 10), OutlinedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(start: DateTime.now().add(const Duration(minutes: 30)), end: DateTime.now().add(const Duration(hours: 2))))), child: const Text('Safar chati (namoyish)'))]));
}
