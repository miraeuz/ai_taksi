import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../state/providers.dart';
import '../widgets/common.dart';
import 'trip_screens.dart';

const dayNames = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];
class RiderHome extends ConsumerWidget {
  const RiderHome({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull;
    return PageShell(title: 'AI Taksi', actions: [IconButton(onPressed: () => ref.read(authProvider.notifier).logout(), icon: const Icon(Icons.logout))], child: RefreshIndicator(onRefresh: () async { ref.invalidate(confirmationsProvider); ref.invalidate(schedulesProvider); await ref.read(confirmationsProvider.future); }, child: ListView(padding: const EdgeInsets.all(18), children: [
      Text('Assalomu alaykum, ${user?.name ?? 'Talaba'}!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: ink)), const SizedBox(height: 8), const Text('Kosonsoy → Namangan / NamSU'), const SizedBox(height: 20),
      SoftCard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [const Row(children: [Icon(Icons.event_available, color: primary), SizedBox(width: 10), Text('Bugun borasizmi?', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800))]), const SizedBox(height: 16), Loadable(value: ref.watch(confirmationsProvider), retry: () => ref.invalidate(confirmationsProvider), builder: (confirmations) => confirmations.isEmpty ? const Text('Bugunga rejalashtirilgan qatnov yo‘q.') : Column(children: confirmations.map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Safar: ${c.date}  ·  ${c.status == 'yes' ? 'Boraman' : c.status == 'no' ? 'Bormayman' : 'Javob kutilmoqda'}'), const SizedBox(height: 9), Row(children: [Expanded(child: FilledButton(onPressed: () => _answer(context, ref, c.id, 'yes'), child: const Text('Ha'))), const SizedBox(width: 8), Expanded(child: OutlinedButton(onPressed: () => _answer(context, ref, c.id, 'no'), child: const Text('Yo‘q')))]), const SizedBox(height: 8), OutlinedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScheduleEditor())), icon: const Icon(Icons.access_time), label: const Text('Vaqtni o‘zgartirish — jadval'))]))).toList()))])),
      const SizedBox(height: 18), SoftCard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [const Text('Mening rejalarim', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Loadable(value: ref.watch(schedulesProvider), retry: () => ref.invalidate(schedulesProvider), builder: (rows) => Text(rows.where((e) => e.active).isEmpty ? 'Hozircha jadval yo‘q.' : '${rows.where((e) => e.active).length} ta faol qatnov kuni')), const SizedBox(height: 12), OutlinedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScheduleEditor())), icon: const Icon(Icons.edit_calendar), label: const Text('Haftalik jadvalni tahrirlash'))])),
      const SizedBox(height: 18), const PreviewNotice(), const SizedBox(height: 10), SoftCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Safar taklifi', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)), const SizedBox(height: 6), const Text('Damas · 8 yo‘lovchi · 20 000 so‘m'), const SizedBox(height: 12), FilledButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TripOfferScreen())), child: const Text('Taklifni ko‘rish (namoyish)'))])),
      const SizedBox(height: 12), OutlinedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveTripScreen())), child: const Text('Faol safarni ko‘rish (namoyish)')),
    ])));
  }
  Future<void> _answer(BuildContext context, WidgetRef ref, int id, String value) async {
    try { await ref.read(repositoryProvider).answer(id, value); ref.invalidate(confirmationsProvider); } catch (e) { if (context.mounted) showError(context, e); }
  }
}
class ScheduleEditor extends ConsumerStatefulWidget {
  const ScheduleEditor({super.key});
  @override ConsumerState<ScheduleEditor> createState() => _ScheduleState();
}
class _ScheduleState extends ConsumerState<ScheduleEditor> {
  final selected = <int>{0, 2};
  TimeOfDay arrive = const TimeOfDay(hour: 13, minute: 0);
  String direction = 'outbound';
  int pickup = 1, route = 1;
  bool saving = false;
  // These stop IDs are only illustrative; the current API has no route/stop listing.
  final stops = const {1: 'Kosonsoy markazi', 2: 'Kosonsoy bozori', 3: 'Kosonsoy janub', 4: 'Yo‘l bo‘yi 1', 5: 'Yo‘l bo‘yi 2', 6: 'Namangan kirish'};
  @override Widget build(BuildContext context) => PageShell(title: 'Haftalik jadval', child: ListView(padding: const EdgeInsets.all(18), children: [
    const PreviewNotice(), const SizedBox(height: 8), const Text('Bekat identifikatorlari namoyish uchun kiritilgan. Saqlashdan oldin API bilan tekshiriladi.', style: TextStyle(fontSize: 12, color: Colors.black54)), const SizedBox(height: 18),
    SoftCard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [const Text('Qatnov kunlari', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), const SizedBox(height: 14), Wrap(spacing: 8, children: List.generate(7, (i) => FilterChip(label: Text(dayNames[i]), selected: selected.contains(i), onSelected: (checked) => setState(() => checked ? selected.add(i) : selected.remove(i))))), const SizedBox(height: 18), ListTile(leading: const Icon(Icons.schedule), title: const Text('Yetib borish vaqti'), trailing: Text(arrive.format(context)), onTap: () async { final time = await showTimePicker(context: context, initialTime: arrive); if (time != null) setState(() => arrive = time); }), const SizedBox(height: 12), DropdownButtonFormField<String>(value: direction, decoration: const InputDecoration(labelText: 'Yo‘nalish', border: OutlineInputBorder()), items: const [DropdownMenuItem(value: 'outbound', child: Text('Kosonsoy → Namangan')), DropdownMenuItem(value: 'return', child: Text('Namangan → Kosonsoy'))], onChanged: (v) => setState(() => direction = v!)), const SizedBox(height: 12), DropdownButtonFormField<int>(value: pickup, decoration: const InputDecoration(labelText: 'Chiqish bekati', border: OutlineInputBorder()), items: stops.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(), onChanged: (v) => setState(() => pickup = v!)), const SizedBox(height: 16), FilledButton(onPressed: saving || selected.isEmpty ? null : save, child: saving ? const CircularProgressIndicator(color: Colors.white) : const Text('Jadvalni saqlash'))])), const SizedBox(height: 18), const Text('Saqlangan rejalar', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)), const SizedBox(height: 10),
    Loadable(value: ref.watch(schedulesProvider), retry: () => ref.invalidate(schedulesProvider), builder: (items) => Column(children: items.where((s) => s.active).map((s) => Padding(padding: const EdgeInsets.only(bottom: 8), child: SoftCard(child: Row(children: [Expanded(child: Text('${dayNames[s.weekday]}  ${s.arriveByTime.substring(0, 5)}  ·  ${stops[s.pickupPointId] ?? 'Bekat ${s.pickupPointId}'}')), IconButton(tooltip: 'O‘chirish', onPressed: () => remove(s.id), icon: const Icon(Icons.delete_outline))]))).toList())),
  ]));
  Future<void> save() async {
    setState(() => saving = true);
    try {
      for (final day in selected.toList()..sort()) {
        await ref.read(repositoryProvider).createSchedule({'route_id': route, 'weekday': day, 'arrive_by_time': '${arrive.hour.toString().padLeft(2,'0')}:${arrive.minute.toString().padLeft(2,'0')}:00', 'direction': direction, 'pickup_point_id': pickup});
      }
      ref.invalidate(schedulesProvider);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jadval saqlandi')));
    } catch (e) { if (mounted) showError(context, e); }
    finally { if (mounted) setState(() => saving = false); }
  }
  Future<void> remove(int id) async { try { await ref.read(repositoryProvider).deleteSchedule(id); ref.invalidate(schedulesProvider); } catch (e) { if (mounted) showError(context, e); } }
}
