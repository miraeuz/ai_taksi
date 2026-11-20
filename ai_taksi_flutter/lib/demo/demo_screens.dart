import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/chat_policy.dart';
import '../models/models.dart';
import 'demo_state.dart';
import 'demo_theme.dart';

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});
  @override Widget build(BuildContext context) => Theme(data: demoTheme(), child: const DemoShell());
}

class DemoShell extends ConsumerWidget {
  const DemoShell({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(demoProvider);
    final driver = state.role == DemoRole.driver;
    final pages = driver
      ? const [DriverDashboard(), DriverOffersPage(), DriverPricesPage(), DemoProfilePage()]
      : const [RiderDashboard(), RiderSchedulePage(), RiderTripsPage(), DemoProfilePage()];
    return Scaffold(
      appBar: AppBar(toolbarHeight: 76, titleSpacing: 20,
        title: Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: teal, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.route_rounded, color: Colors.white)),
          const SizedBox(width: 10), const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('AI Taksi', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, height: 1.1)), Text('Birga borish — osonroq', style: TextStyle(fontSize: 10, color: muted))])]),
        actions: const [DemoBadge(), SizedBox(width: 16)]),
      body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 760), child: pages[state.activeTab]))),
      bottomNavigationBar: NavigationBar(height: 76, selectedIndex: state.activeTab,
        onDestinationSelected: ref.read(demoProvider.notifier).tab,
        destinations: driver ? const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard_rounded), label: 'Bosh sahifa'),
          NavigationDestination(icon: Icon(Icons.local_taxi_outlined), selectedIcon: Icon(Icons.local_taxi), label: 'Takliflar'),
          NavigationDestination(icon: Icon(Icons.payments_outlined), selectedIcon: Icon(Icons.payments_rounded), label: 'Narxlar'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ] : const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Asosiy'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month_rounded), label: 'Jadval'),
          NavigationDestination(icon: Icon(Icons.directions_car_outlined), selectedIcon: Icon(Icons.directions_car), label: 'Safarlar'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ]),
    );
  }
}

class RiderDashboard extends ConsumerWidget {
  const RiderDashboard({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(demoProvider);
    final actions = ref.read(demoProvider.notifier);
    return ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 24), children: [
      const Label('Payshanba · Namangan'), const SizedBox(height: 6),
      const Text('Salom, Aziza 👋', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 30, letterSpacing: -.8)),
      const SizedBox(height: 5), const Text('Yo‘lingizni birga yengillashtiramiz.', style: TextStyle(color: muted)),
      const SizedBox(height: 22),
      Container(padding: const EdgeInsets.all(21), decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(27)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Icon(Icons.auto_awesome_rounded, color: gold, size: 18), const SizedBox(width: 7), const Text('AQLLI QATNOV REJASI', style: TextStyle(color: Color(0xFF9CD4D1), fontSize: 11, letterSpacing: 1.1, fontWeight: FontWeight.w900)), const Spacer(), const Icon(Icons.more_horiz, color: Colors.white70)]),
        const SizedBox(height: 19), const Text('Kosonsoy', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 28)),
        const Row(children: [Icon(Icons.south_rounded, color: Color(0xFF79D9CD), size: 22), SizedBox(width: 12), Text('Namangan · NamSU', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700))]),
        const SizedBox(height: 20), Row(children: [const _DarkStat(Icons.calendar_today_outlined, 'Dushanba, Chorshanba'), const SizedBox(width: 12), _DarkStat(Icons.access_time, '${s.arriveBy} gacha')]),
      ])), const SizedBox(height: 23),
      const SectionHeading('Ertangi safar'),
      Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Container(width: 45, height: 45, decoration: BoxDecoration(color: mint, borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.notifications_active_outlined, color: teal)),
          const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Ertaga borasizmi?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)), Text('NamSU · 13:00 gacha', style: TextStyle(fontSize: 13, color: muted))]))]),
        const SizedBox(height: 18),
        if (s.stage == RideStage.awaitingAnswer || s.stage == RideStage.declined) ...[
          const Text('Rejangizni tasdiqlang — sizga mos transport topamiz.', style: TextStyle(color: muted, height: 1.5)), const SizedBox(height: 15),
          Row(children: [Expanded(child: FilledButton.icon(onPressed: () => actions.answer(true), icon: const Icon(Icons.check_circle_outline), label: const Text('Ha, boraman'))), const SizedBox(width: 9), Expanded(child: OutlinedButton(onPressed: () => actions.answer(false), child: const Text('Yo‘q')))]),
          const SizedBox(height: 4), TextButton.icon(onPressed: () => actions.tab(1), icon: const Icon(Icons.schedule, size: 18), label: const Text('Vaqtni o‘zgartirish')),
        ] else ...[
          InfoPill(Icons.check_circle_outline, s.stage == RideStage.offered ? 'Transport topildi' : s.stage == RideStage.completed ? 'Safar yakunlandi' : 'Safaringiz tasdiqlangan'),
          const SizedBox(height: 15), FilledButton(onPressed: () => actions.tab(2), child: const Text('Safar tafsilotlarini ko‘rish')),
        ],
      ])), const SizedBox(height: 22), const SectionHeading('Safar xaritasi'), const RouteArt(),
      const SizedBox(height: 20), Row(children: [Expanded(child: _MiniFeature(icon: Icons.verified_user_outlined, title: 'Tekshirilgan', subtitle: 'Haydovchilar')), const SizedBox(width: 10), Expanded(child: _MiniFeature(icon: Icons.savings_outlined, title: 'Hamyonbop', subtitle: 'Birga safar'))]),
      const SizedBox(height: 16), const _DemoFootnote(),
    ]);
  }
}
class _DarkStat extends StatelessWidget {
  final IconData icon; final String text;
  const _DarkStat(this.icon, this.text);
  @override Widget build(BuildContext context) => Flexible(child: Row(children: [Icon(icon, color: const Color(0xFF8EDFD6), size: 16), const SizedBox(width: 5), Flexible(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)))]));
}
class _MiniFeature extends StatelessWidget {
  final IconData icon; final String title, subtitle;
  const _MiniFeature({required this.icon, required this.title, required this.subtitle});
  @override Widget build(BuildContext context) => Panel(padding: const EdgeInsets.all(15), child: Row(children: [Icon(icon, color: teal, size: 27), const SizedBox(width: 9), Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)), Text(subtitle, style: const TextStyle(fontSize: 10, color: muted))]))]));
}

class RiderSchedulePage extends ConsumerStatefulWidget {
  const RiderSchedulePage({super.key});
  @override ConsumerState<RiderSchedulePage> createState() => _RiderSchedulePageState();
}
class _RiderSchedulePageState extends ConsumerState<RiderSchedulePage> {
  late Set<int> days; late String pickup, direction; late TimeOfDay arrival;
  bool initialized = false;
  @override void didChangeDependencies() { super.didChangeDependencies(); if (!initialized) { final s = ref.read(demoProvider); days = {...s.days}; pickup = s.pickup; direction = s.direction; final parts = s.arriveBy.split(':'); arrival = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])); initialized = true; } }
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
    const Label('Qulay rejalashtirish'), const SizedBox(height: 6), const Text('Haftalik jadval', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 29)),
    const SizedBox(height: 6), const Text('Bir marta sozlang, har hafta avtomatik eslatamiz.', style: TextStyle(color: muted)), const SizedBox(height: 23),
    Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Qaysi kunlari borasiz?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)), const SizedBox(height: 14),
      Wrap(spacing: 7, runSpacing: 8, children: List.generate(7, (i) => FilterChip(label: Text(weekDays[i]), selected: days.contains(i), onSelected: (v) => setState(() => v ? days.add(i) : days.remove(i)), selectedColor: mint, checkmarkColor: teal, side: BorderSide(color: days.contains(i) ? teal : const Color(0xFFE3EBEB))))),
      const SizedBox(height: 19), const Text('Yetib borish vaqti', style: TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 9),
      ListTile(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), tileColor: canvas,
        leading: const Icon(Icons.schedule, color: teal), title: Text(arrival.format(context)), subtitle: const Text('NamSUga yetib borish'), trailing: const Icon(Icons.chevron_right),
        onTap: () async { final time = await showTimePicker(context: context, initialTime: arrival); if (time != null) setState(() => arrival = time); }),
      const SizedBox(height: 17), DropdownButtonFormField<String>(value: pickup, isExpanded: true,
        decoration: const InputDecoration(labelText: 'Chiqish bekati', prefixIcon: Icon(Icons.location_on_outlined)),
        items: pilotStops.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) { if (v != null) setState(() => pickup = v); }),
      const SizedBox(height: 15), DropdownButtonFormField<String>(value: direction, isExpanded: true,
        decoration: const InputDecoration(labelText: 'Yo‘nalish', prefixIcon: Icon(Icons.swap_horiz_rounded)),
        items: const [DropdownMenuItem(value: 'Kosonsoy → NamSU', child: Text('Kosonsoy → NamSU')), DropdownMenuItem(value: 'NamSU → Kosonsoy', child: Text('NamSU → Kosonsoy'))], onChanged: (v) { if (v != null) setState(() => direction = v); }),
      const SizedBox(height: 22), SizedBox(width: double.infinity, child: FilledButton.icon(
        onPressed: days.isEmpty ? null : () { ref.read(demoProvider.notifier).setSchedule(days, pickup, '${arrival.hour.toString().padLeft(2, '0')}:${arrival.minute.toString().padLeft(2, '0')}', direction); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demo jadval saqlandi'))); },
        icon: const Icon(Icons.check_rounded), label: const Text('Jadvalni saqlash'))),
    ])), const SizedBox(height: 17), const _DemoFootnote(),
  ]);
}

class RiderTripsPage extends ConsumerWidget {
  const RiderTripsPage({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(demoProvider); final actions = ref.read(demoProvider.notifier);
    return ListView(padding: const EdgeInsets.all(20), children: [
      const Label('Sizning safarlaringiz'), const SizedBox(height: 5), const Text('Mening safarlarim', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900)), const SizedBox(height: 18),
      const RouteArt(height: 165), const SizedBox(height: 17),
      if (s.stage == RideStage.awaitingAnswer || s.stage == RideStage.declined) Panel(child: Column(children: [const Icon(Icons.calendar_today_outlined, size: 44, color: teal), const SizedBox(height: 8), const Text('Hozircha faol safar yo‘q', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 7), const Text('Asosiy sahifada ertangi qatnovni tasdiqlang.', textAlign: TextAlign.center, style: TextStyle(color: muted)), const SizedBox(height: 12), FilledButton(onPressed: () => actions.tab(0), child: const Text('Bosh sahifaga'))]))
      else Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const InfoPill(Icons.route, 'NAMSU · 13:00'), const Spacer(), Text(s.stage == RideStage.offered ? 'Yangi taklif' : s.stage == RideStage.completed ? 'Yakunlandi' : 'Tasdiqlangan', style: const TextStyle(fontSize: 12, color: teal, fontWeight: FontWeight.w800))]),
        const SizedBox(height: 16), const Text('Kosonsoy → NamSU', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)), const SizedBox(height: 10),
        const _TripLine(Icons.airport_shuttle_rounded, 'Damas · oq', '01 A 123 BC'),
        const _TripLine(Icons.person_outline, 'Haydovchi', 'Sherzod · 4.9 ★'),
        const _TripLine(Icons.schedule, 'Bekatda bo‘lish', '10:40'),
        const _TripLine(Icons.people_alt_outlined, 'Yo‘lovchilar', '8 kishi'),
        const Divider(height: 26), Row(children: [const Text('Bir kishiga', style: TextStyle(color: muted)), const Spacer(), Text('${prettyMoney(s.price)} so‘m', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 23, color: teal))]),
        const SizedBox(height: 16),
        if (s.stage == RideStage.offered) ...[FilledButton(onPressed: actions.acceptRiderOffer, child: const Text('Safarni tasdiqlash')), const SizedBox(height: 8), OutlinedButton(onPressed: () => actions.answer(false), child: const Text('Rad etish'))],
        if (s.stage == RideStage.confirmed) ...[FilledButton(onPressed: actions.beginTrip, child: const Text('Safarni boshlash · demo')), const SizedBox(height: 8), OutlinedButton.icon(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DemoChatPage())), icon: const Icon(Icons.chat_bubble_outline), label: const Text('Safar chati'))],
        if (s.stage == RideStage.active) ...[FilledButton(onPressed: actions.finishTrip, child: const Text('Safarni yakunlash')), const SizedBox(height: 8), OutlinedButton.icon(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DemoChatPage())), icon: const Icon(Icons.chat_bubble_outline), label: const Text('Haydovchiga yozish'))],
        if (s.stage == RideStage.completed) ...[const Text('Safaringiz qanday o‘tdi?', style: TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 8), Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => IconButton(tooltip: '${i+1} yulduz', onPressed: () => actions.setRating(i+1), icon: Icon(i < s.rating ? Icons.star_rounded : Icons.star_outline_rounded, color: gold, size: 35)))), if (s.rating > 0) const Center(child: InfoPill(Icons.check, 'Baho demo xotirasida saqlandi'))],
      ])), const SizedBox(height: 18),
      const SectionHeading('Oldingi safarlar'), const _HistoryRow('Chorshanba · NamSU', '20 000 so‘m', '5.0 ★'), const SizedBox(height: 8), const _HistoryRow('Dushanba · NamSU', '21 000 so‘m', '4.9 ★'),
      const SizedBox(height: 16), const _DemoFootnote(),
    ]);
  }
}
class _TripLine extends StatelessWidget { final IconData icon; final String label, value; const _TripLine(this.icon, this.label, this.value);
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 9), child: Row(children: [Icon(icon, size: 21, color: teal), const SizedBox(width: 11), Expanded(child: Text(label, style: const TextStyle(color: muted, fontSize: 13))), Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13))])); }
class _HistoryRow extends StatelessWidget { final String label, price, rating; const _HistoryRow(this.label, this.price, this.rating);
  @override Widget build(BuildContext context) => Panel(padding: const EdgeInsets.all(15), child: Row(children: [const CircleAvatar(backgroundColor: mint, child: Icon(Icons.check, color: teal)), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w800)), Text(rating, style: const TextStyle(color: muted, fontSize: 12))])), Text(price, style: const TextStyle(fontWeight: FontWeight.w900))])); }

class DriverDashboard extends ConsumerWidget {
  const DriverDashboard({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(demoProvider);
    return ListView(padding: const EdgeInsets.all(20), children: [const Label('Haydovchi kabineti'), const SizedBox(height: 5), const Text('Salom, Sherzod 👋', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28)), const SizedBox(height: 19),
      Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(27)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('BU HAFTADAGI DAROMAD · DEMO', style: TextStyle(color: Color(0xFF99DAD4), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)), const SizedBox(height: 9), const Text('840 000 so‘m', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 31)), const SizedBox(height: 15), Row(children: [const _DarkStat(Icons.route, '12 ta safar'), const SizedBox(width: 15), const _DarkStat(Icons.star_rounded, '4.9 reyting')])])),
      const SizedBox(height: 24), const SectionHeading('Bugungi faoliyat'),
      Row(children: [Expanded(child: _DriverMetric('02', 'Takliflar', Icons.notifications_active_outlined)), const SizedBox(width: 10), Expanded(child: _DriverMetric('08', 'Yo‘lovchi', Icons.groups_outlined))]),
      const SizedBox(height: 22), const RouteArt(height: 160), const SizedBox(height: 19),
      Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Kosonsoy → NamSU', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)), const SizedBox(height: 7), const Text('Damas · 8 yo‘lovchi · Dushanba, 10:40', style: TextStyle(color: muted)), const SizedBox(height: 16), FilledButton(onPressed: () => ref.read(demoProvider.notifier).tab(1), child: Text(s.driverAccepted ? 'Safar tafsilotlari' : 'Takliflarni ko‘rish'))])),
      const SizedBox(height: 17), const _DemoFootnote(),
    ]);
  }
}
class _DriverMetric extends StatelessWidget { final String number, label; final IconData icon; const _DriverMetric(this.number, this.label, this.icon);
  @override Widget build(BuildContext context) => Panel(child: Row(children: [CircleAvatar(backgroundColor: mint, child: Icon(icon, color: teal)), const SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(number, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)), Text(label, style: const TextStyle(fontSize: 12, color: muted))]) ])); }

class DriverOffersPage extends ConsumerStatefulWidget {
  const DriverOffersPage({super.key});
  @override ConsumerState<DriverOffersPage> createState() => _DriverOffersPageState();
}
class _DriverOffersPageState extends ConsumerState<DriverOffersPage> {
  late final DateTime expiresAt;
  Timer? ticker;
  @override void initState() { super.initState(); expiresAt = DateTime.now().add(const Duration(minutes: 4, seconds: 59)); ticker = Timer.periodic(const Duration(seconds: 1), (_) { if (mounted) setState(() {}); }); }
  @override void dispose() { ticker?.cancel(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final s = ref.watch(demoProvider); final remaining = expiresAt.difference(DateTime.now()).inSeconds;
    final countdown = remaining > 0 ? '${(remaining ~/ 60).toString().padLeft(2,'0')}:${(remaining % 60).toString().padLeft(2,'0')}' : '00:00';
    return ListView(padding: const EdgeInsets.all(20), children: [const Label('Yangi buyurtmalar'), const SizedBox(height: 5), const Text('Safar takliflari', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 29)), const SizedBox(height: 20),
      Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const InfoPill(Icons.notifications_active_outlined, 'YANGI TAKLIF'), const Spacer(), const Icon(Icons.timer_outlined, color: teal, size: 19), const SizedBox(width: 5), Text(countdown, style: const TextStyle(color: teal, fontWeight: FontWeight.w900, fontSize: 19))]), const SizedBox(height: 17),
        const Text('Kosonsoy → NamSU', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)), const SizedBox(height: 8), const Text('Dushanba · 10:40 da boshlanadi', style: TextStyle(color: muted)), const SizedBox(height: 18),
        const Row(children: [Expanded(child: _OfferMetric('8', 'yo‘lovchi', Icons.groups_outlined)), Expanded(child: _OfferMetric('3', 'bekat', Icons.place_outlined))]), const Divider(height: 30),
        Text('${prettyMoney(s.price * 8)} so‘m', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 29, color: teal)), const Text('Jami potensial tushum · demo hisob', style: TextStyle(color: muted, fontSize: 12)), const SizedBox(height: 16),
        if (s.driverAccepted) ...[const InfoPill(Icons.check_circle_outline, 'TAKLIF QABUL QILINGAN'), const SizedBox(height: 15), FilledButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DemoPickupPage())), child: const Text('Yo‘lovchilarni ko‘rish'))]
        else if (s.driverDeclined) const InfoPill(Icons.cancel_outlined, 'TAKLIF RAD ETILDI')
        else if (remaining > 0) Row(children: [Expanded(child: FilledButton(onPressed: () => ref.read(demoProvider.notifier).driverDecision(true), child: const Text('Qabul qilish'))), const SizedBox(width: 10), Expanded(child: OutlinedButton(onPressed: () => ref.read(demoProvider.notifier).driverDecision(false), child: const Text('Rad etish')))])
        else const Text('Taklif muddati tugadi. Demo rejimini qayta boshlang.', style: TextStyle(color: muted)),
      ])), const SizedBox(height: 17), const SectionHeading('Bekatlar ketma-ketligi'), const _PickupPreview(), const SizedBox(height: 17), const _DemoFootnote(),
    ]);
  }
}
class _OfferMetric extends StatelessWidget { final String value, label; final IconData icon; const _OfferMetric(this.value,this.label,this.icon);
  @override Widget build(BuildContext context) => Row(children: [Icon(icon, color: teal), const SizedBox(width: 8), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)), Text(label, style: const TextStyle(color: muted, fontSize: 12))])]); }
class _PickupPreview extends StatelessWidget {
  const _PickupPreview();
  @override Widget build(BuildContext context) => Panel(child: const Column(children: [
    _PickupRow('01','Kosonsoy markazi','10:40 · 3 yo‘lovchi'), Divider(height: 22),
    _PickupRow('02','Kosonsoy bozori','10:50 · 3 yo‘lovchi'), Divider(height: 22),
    _PickupRow('03','Kosonsoy janub','11:00 · 2 yo‘lovchi'),
  ]));
}
class _PickupRow extends StatelessWidget { final String number, name, caption; const _PickupRow(this.number,this.name,this.caption);
  @override Widget build(BuildContext context) => Row(children: [CircleAvatar(radius: 20, backgroundColor: mint, child: Text(number, style: const TextStyle(color: teal, fontWeight: FontWeight.w900, fontSize: 12))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(caption, style: const TextStyle(color: muted, fontSize: 12))])), const Icon(Icons.check_circle_outline, color: teal, size: 19)]); }
class DemoPickupPage extends StatelessWidget {
  const DemoPickupPage({super.key});
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Safar tafsilotlari')), body: ListView(padding: const EdgeInsets.all(20), children: [const DemoBadge(), const SizedBox(height: 12), const RouteArt(), const SizedBox(height: 18), const SectionHeading('Olib ketish tartibi'), const _PickupPreview(), const SizedBox(height: 16), FilledButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DemoChatPage())), icon: const Icon(Icons.chat_bubble_outline), label: const Text('Safar chati · demo'))]));
}
class DriverPricesPage extends ConsumerStatefulWidget {
  const DriverPricesPage({super.key});
  @override ConsumerState<DriverPricesPage> createState() => _DriverPricesPageState();
}
class _DriverPricesPageState extends ConsumerState<DriverPricesPage> {
  late final TextEditingController price;
  @override void initState() { super.initState(); price = TextEditingController(text: '${ref.read(demoProvider).price}'); }
  @override void dispose() { price.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final s = ref.watch(demoProvider);
    return ListView(padding: const EdgeInsets.all(20), children: [const Label('Haydovchi sozlamalari'), const SizedBox(height: 5), const Text('Narx jadvali', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900)), const SizedBox(height: 7), const Text('Guruh kattaligiga qarab narxlarni boshqaring.', style: TextStyle(color: muted)), const SizedBox(height: 21),
      Panel(child: Column(children: [const _PriceRow('1–3 yo‘lovchi', '30 000 so‘m'), const Divider(height: 25), const _PriceRow('4–7 yo‘lovchi', '25 000 so‘m'), const Divider(height: 25), _PriceRow('8 yo‘lovchi', '${prettyMoney(s.price)} so‘m')])),
      const SizedBox(height: 19), Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const SectionHeading('8 kishilik guruh narxi'), TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Bir yo‘lovchiga (so‘m)', prefixIcon: Icon(Icons.payments_outlined))), const SizedBox(height: 15), SizedBox(width: double.infinity, child: FilledButton(onPressed: () { final amount = int.tryParse(price.text); if (amount != null && amount >= 1000 && amount <= 500000) { ref.read(demoProvider.notifier).updatePrice(amount); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demo narx yangilandi'))); } else { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('1000–500000 oralig‘ida narx kiriting'))); } }, child: const Text('Narxni saqlash')))])), const SizedBox(height: 18), const _DemoFootnote(),
    ]);
  }
}
class _PriceRow extends StatelessWidget { final String label, price; const _PriceRow(this.label,this.price);
  @override Widget build(BuildContext context) => Row(children: [const Icon(Icons.sell_outlined, color: teal), const SizedBox(width: 12), Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))), Text(price, style: const TextStyle(fontWeight: FontWeight.w900))]); }

class DemoProfilePage extends ConsumerWidget {
  const DemoProfilePage({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(demoProvider); final driver = s.role == DemoRole.driver;
    return ListView(padding: const EdgeInsets.all(20), children: [const Label('Demo kabinet'), const SizedBox(height: 5), const Text('Profil va sozlamalar', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900)), const SizedBox(height: 20),
      Panel(child: Column(children: [CircleAvatar(radius: 34, backgroundColor: mint, child: Icon(driver ? Icons.drive_eta : Icons.school_outlined, color: teal, size: 33)), const SizedBox(height: 12), Text(driver ? 'Sherzod' : 'Aziza', style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)), Text(driver ? 'Tasdiqlangan haydovchi · Namoyish' : 'Talaba · Namoyish', style: const TextStyle(color: muted)), const SizedBox(height: 14), const InfoPill(Icons.verified_outlined, 'SHAXSIY MA’LUMOTLAR KO‘RSATILMAYDI') ])),
      const SizedBox(height: 20), const SectionHeading('Rolni almashtirish'),
      Panel(child: Column(children: [ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.school_outlined, color: teal), title: const Text('Yo‘lovchi interfeysi'), subtitle: const Text('Jadval, safar, baholash'), trailing: driver ? const Icon(Icons.chevron_right) : const Icon(Icons.check_circle, color: teal), onTap: () => ref.read(demoProvider.notifier).switchRole(DemoRole.rider)), const Divider(), ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.drive_eta_outlined, color: teal), title: const Text('Haydovchi interfeysi'), subtitle: const Text('Takliflar, narxlar, bekatlar'), trailing: driver ? const Icon(Icons.check_circle, color: teal) : const Icon(Icons.chevron_right), onTap: () => ref.read(demoProvider.notifier).switchRole(DemoRole.driver))])),
      const SizedBox(height: 20), OutlinedButton.icon(onPressed: () { ref.read(demoProvider.notifier).reset(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demo ma’lumotlari tiklandi'))); }, icon: const Icon(Icons.restart_alt), label: const Text('Demo holatini tiklash')), const SizedBox(height: 15), const _DemoFootnote(),
    ]);
  }
}
class DemoChatPage extends ConsumerStatefulWidget {
  const DemoChatPage({super.key});
  @override ConsumerState<DemoChatPage> createState() => _DemoChatPageState();
}
class _DemoChatPageState extends ConsumerState<DemoChatPage> {
  final input = TextEditingController(); String? error;
  // Fixed example time window relative to launch, for a usable offline chat walkthrough.
  late final DateTime tripStart, tripEnd;
  @override void initState() { super.initState(); tripStart = DateTime.now().add(const Duration(minutes: 15)); tripEnd = tripStart.add(const Duration(hours: 1)); }
  @override void dispose() { input.dispose(); super.dispose(); }
  void submit() {
    final result = ref.read(demoProvider.notifier).send(input.text, DateTime.now(), tripStart, tripEnd);
    setState(() => error = result);
    if (result == null) input.clear();
  }
  @override Widget build(BuildContext context) {
    final messages = ref.watch(demoProvider).messages;
    final allowed = ChatPolicy.withinWindow(DateTime.now(), tripStart, tripEnd);
    return Scaffold(appBar: AppBar(title: const Text('Safar chati'), actions: const [DemoBadge(), SizedBox(width: 12)]), body: SafeArea(child: Column(children: [
      Container(width: double.infinity, padding: const EdgeInsets.all(12), color: mint, child: const Text('Faqat demo xabarlar. Telefon raqami va @username taqiqlanadi.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: teal, fontWeight: FontWeight.w700))),
      Expanded(child: messages.isEmpty ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.chat_bubble_outline, color: teal, size: 56), SizedBox(height: 12), Text('Xavfsiz suhbat', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)), SizedBox(height: 6), Text('Xabarlar faqat ushbu demo xotirasida.', style: TextStyle(color: muted))])) : ListView.builder(padding: const EdgeInsets.all(20), itemCount: messages.length, itemBuilder: (context,i) { final m = messages[i]; return Align(alignment: Alignment.centerRight, child: Padding(padding: const EdgeInsets.only(bottom: 9), child: Container(constraints: const BoxConstraints(maxWidth: 300), padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: mint, borderRadius: BorderRadius.circular(19)), child: Text(m.body)))); })),
      if (error != null) Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: Text(error!, style: const TextStyle(color: Colors.red))),
      Padding(padding: const EdgeInsets.all(14), child: Row(children: [Expanded(child: TextField(controller: input, enabled: allowed, maxLength: 400, decoration: const InputDecoration(hintText: 'Xabar yozing...', counterText: ''))), const SizedBox(width: 9), IconButton.filled(onPressed: allowed ? submit : null, icon: const Icon(Icons.send_rounded))])),
    ])));
  }
}
class _DemoFootnote extends StatelessWidget {
  const _DemoFootnote();
  @override Widget build(BuildContext context) => const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.info_outline, color: muted, size: 16), SizedBox(width: 7), Expanded(child: Text('Bu interaktiv namoyish. Hech qanday haqiqiy bron, to‘lov yoki xabar serverga yuborilmaydi.', style: TextStyle(color: muted, fontSize: 11, height: 1.5)))]);
}
