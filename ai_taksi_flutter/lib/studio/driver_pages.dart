import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'studio_state.dart';
import 'studio_design.dart';
import 'studio_app.dart' show demoSnack;
import 'shared_pages.dart';
import 'fleet_page.dart';
import 'mock_catalog.dart';

class DriverHomePage extends ConsumerWidget {
  const DriverHomePage({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(studioProvider);
    return ListView(padding: const EdgeInsets.fromLTRB(20, 13, 20, 35), children: [
      const StudioHeadline(title: 'Salom, Sherzod 👋',
        subtitle: 'Bugungi qatnovlar va yangi takliflar tayyor.',
        eyebrow: 'HAYDOVCHI KABINETI'),
      const SizedBox(height: 21),
      Container(padding: const EdgeInsets.all(21),
        decoration: BoxDecoration(gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [auroraNavy, Color(0xFF32147E), auroraIndigo]),
          borderRadius: BorderRadius.circular(26)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [Icon(Icons.trending_up_rounded,
            color: warmGold, size: 17), SizedBox(width: 6),
            StudioEyebrow('BU HAFTADAGI DAROMAD · DEMO', color: auroraCyan),
            Spacer(), Icon(Icons.arrow_outward, color: Colors.white70)]),
          const SizedBox(height: 12),
          const Text('840 000 so‘m', style: TextStyle(color: Colors.white,
            fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -.9)),
          const SizedBox(height: 7),
          const Row(children: [StudioPill('+12% o‘tgan haftadan',
            icon: Icons.north_east_rounded, foreground: Color(0xFFC9FFF0),
            background: Color(0xFF352A86)), Spacer(),
            Text('12 safar', style: TextStyle(color: Colors.white70,
              fontSize: 12, fontWeight: FontWeight.w700))]),
          const SizedBox(height: 20), const _EarningsBars(),
        ])),
      const SizedBox(height: 22), const StudioSection('Bugungi ko‘rsatkichlar'),
      Row(children: [Expanded(child: StudioMetric(
        '${s.offeredCount}'.padLeft(2, '0'), 'Yangi takliflar', Icons.notifications_active_outlined)),
        const SizedBox(width: 10),
        const Expanded(child: StudioMetric('4.9', 'Haydovchi reytingi', Icons.star_outline_rounded))]),
      const SizedBox(height: 20),
      StudioSection('Sizga mos safarlar', trailing: 'Barchasi',
        onTap: () => ref.read(studioProvider.notifier).tab(1)),
      const StudioRouteMap(height: 145, dark: true), const SizedBox(height: 12),
      StudioCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [StudioPill('YANGI TAKLIF', icon: Icons.bolt_rounded),
          Spacer(), Text('23 noyabr', style: TextStyle(color: softGrey, fontSize: 12))]),
        const SizedBox(height: 12), const Text('Kosonsoy → NamSU',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 19)),
        const SizedBox(height: 5), const Text('10:40 · 8 yo‘lovchi · Damas',
          style: TextStyle(color: softGrey, fontSize: 12.5)),
        const SizedBox(height: 17),
        SizedBox(width: double.infinity, child: FilledButton.icon(
          onPressed: () => ref.read(studioProvider.notifier).tab(1),
          icon: const Icon(Icons.arrow_forward_rounded), label: const Text('Taklifni ko‘rish'))),
      ])),
      const SizedBox(height: 14),
      StudioCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [const StudioSection('Demo avtopark'),
          const Text('Yengil · Damas · Avtobus — namuna modellar bilan tanishing.',
            style: TextStyle(fontSize: 12, color: softGrey)),
          const SizedBox(height: 13),
          Row(children: [
            for (final item in demoVehicles.take(3)) Expanded(child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Column(children: [Icon(item.icon, color: item.color, size: 28),
                const SizedBox(height: 5), Text(item.categoryLabel,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800))]))),
          ]),
          const SizedBox(height: 13),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const StudioFleetPage())),
            icon: const Icon(Icons.tune_rounded), label: const Text('Modellarni ko‘rish'))),
        ])),
      const SizedBox(height: 20), const DemoDisclaimer(),
    ]);
  }
}

class _EarningsBars extends StatelessWidget {
  const _EarningsBars();
  @override Widget build(BuildContext context) => SizedBox(height: 71,
    child: Row(crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (i) {
        final heights = [25.0,44,33,58,48,68,39];
        return Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.end,
          children: [Container(height: heights[i], margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(color: i == 5 ? auroraCyan : const Color(0xFF805DDE),
              borderRadius: BorderRadius.circular(6))),
            const SizedBox(height: 5), Text(weekdayLabels[i],
              style: const TextStyle(color: Colors.white70, fontSize: 9.5))]));
      })));
}

class DriverOffersPage extends ConsumerStatefulWidget {
  const DriverOffersPage({super.key});
  @override ConsumerState<DriverOffersPage> createState() => _DriverOffersPageState();
}
class _DriverOffersPageState extends ConsumerState<DriverOffersPage> {
  late final DateTime openedAt;
  Timer? ticker;
  @override void initState() {
    super.initState(); openedAt = DateTime.now();
    ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }
  @override void dispose() { ticker?.cancel(); super.dispose(); }

  @override Widget build(BuildContext context) {
    final s = ref.watch(studioProvider);
    return ListView(padding: const EdgeInsets.fromLTRB(20, 13, 20, 35), children: [
      const StudioHeadline(title: 'Safar takliflari',
        subtitle: 'Muddat tugashidan oldin qaror qabul qiling.',
        eyebrow: 'YANGI BUYURTMALAR'),
      const SizedBox(height: 16),
      Row(children: [StudioPill('${s.offeredCount} ta faol',
        icon: Icons.notifications_active_outlined), const Spacer(),
        const Text('23 noyabr · Dushanba',
          style: TextStyle(fontSize: 11.5, color: softGrey))]),
      const SizedBox(height: 17),
      ...sampleOffers.map((offer) => Padding(
        padding: const EdgeInsets.only(bottom: 13),
        child: _DriverOfferCard(offer: offer, openedAt: openedAt))),
      const SizedBox(height: 8), const StudioSection('Yo‘lovchilarni olib ketish'),
      const StudioRouteMap(height: 152),
      const SizedBox(height: 18), const DemoDisclaimer(),
    ]);
  }
}

class _DriverOfferCard extends ConsumerWidget {
  final DemoOffer offer;
  final DateTime openedAt;
  const _DriverOfferCard({required this.offer, required this.openedAt});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(studioProvider);
    final decision = s.offerDecisions[offer.id] ?? OfferDecision.waiting;
    final expires = openedAt.add(Duration(minutes: offer.minutesToRespond));
    final remain = expires.difference(DateTime.now()).inSeconds;
    final seconds = remain < 0 ? 0 : remain;
    final timerText = '${(seconds ~/ 60).toString().padLeft(2,'0')}:${(seconds % 60).toString().padLeft(2,'0')}';
    final price = s.priceFor(offer.passengers);
    return StudioCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [StudioPill(decision == OfferDecision.accepted ? 'QABUL QILINDI'
        : decision == OfferDecision.declined ? 'RAD ETILDI' : 'YANGI TAKLIF',
        icon: decision == OfferDecision.waiting ? Icons.bolt_rounded
          : decision == OfferDecision.accepted ? Icons.check_circle_outline : Icons.cancel_outlined),
        const Spacer(), Icon(Icons.timer_outlined,
          color: seconds < 60 ? Colors.deepOrange : emerald, size: 17),
        const SizedBox(width: 4), Text(timerText,
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16,
            color: seconds < 60 ? Colors.deepOrange : emerald))]),
      const SizedBox(height: 17), Text(offer.route,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
          letterSpacing: -.4)),
      const SizedBox(height: 5), Text('${offer.pickupTime} da · ${offer.pickup}',
        style: const TextStyle(color: softGrey, fontSize: 12.5)),
      const SizedBox(height: 17),
      Row(children: [Expanded(child: _OfferFact(Icons.groups_outlined,
        '${offer.passengers}', 'Yo‘lovchi')),
        Expanded(child: _OfferFact(Icons.pin_drop_outlined,
          '${offer.stops}', 'Bekat')),
        Expanded(child: _OfferFact(Icons.airport_shuttle_outlined,
          offer.vehicle, 'Transport'))]),
      const Divider(height: 30, color: borderColor),
      const Text('Taxminiy tushum', style: TextStyle(color: softGrey, fontSize: 12)),
      const SizedBox(height: 3), Text(uzs(price * offer.passengers),
        style: const TextStyle(color: emerald,
          fontSize: 25, fontWeight: FontWeight.w900)),
      const SizedBox(height: 15),
      if (decision == OfferDecision.waiting && seconds > 0)
        Row(children: [Expanded(child: FilledButton(
          onPressed: () => ref.read(studioProvider.notifier).decideOffer(offer.id, true),
          child: const Text('Qabul qilish'))), const SizedBox(width: 9),
          Expanded(child: OutlinedButton(
            onPressed: () => ref.read(studioProvider.notifier).decideOffer(offer.id, false),
            child: const Text('Rad etish')))]),
      if (decision == OfferDecision.waiting && seconds == 0)
        const Text('Taklif muddati tugadi. Demo rejimini tiklang.',
          style: TextStyle(color: softGrey, fontSize: 12.5)),
      if (decision == OfferDecision.accepted)
        SizedBox(width: double.infinity, child: FilledButton.icon(
          onPressed: () {
            ref.read(studioProvider.notifier).selectOffer(offer.id);
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => StudioPickupPage(offer: offer)));
          }, icon: const Icon(Icons.route_outlined), label: const Text('Bekatlar ro‘yxati'))),
      if (decision == OfferDecision.declined)
        const StudioPill('Keyingi taklifni tanlang', icon: Icons.info_outline),
    ]));
  }
}
class _OfferFact extends StatelessWidget {
  final IconData icon;
  final String value, label;
  const _OfferFact(this.icon, this.value, this.label);
  @override Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: emerald, size: 19), const SizedBox(height: 6),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
      Text(label, style: const TextStyle(color: softGrey, fontSize: 11)),
    ]);
}

class DriverPricesPage extends ConsumerWidget {
  const DriverPricesPage({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(studioProvider);
    final tiers = <(int, String, String)>[
      (3, '1–3 yo‘lovchi', 'Kichik guruh'),
      (7, '4–7 yo‘lovchi', 'O‘rta guruh'),
      (8, '8 yo‘lovchi', 'To‘liq Damas'),
      (14, '9–14 yo‘lovchi', 'Mikroavtobus · demo'),
      (28, '15–28 yo‘lovchi', 'Avtobus · demo'),
    ];
    return ListView(padding: const EdgeInsets.fromLTRB(20, 13, 20, 35), children: [
      const StudioHeadline(title: 'Narx jadvali',
        subtitle: 'Narxlar sizning nazoratingizda. Guruhga mos tariflar.',
        eyebrow: 'DAROMADNI BOSHQARISH'),
      const SizedBox(height: 20),
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [auroraNavy, Color(0xFF342078), auroraIndigo]), borderRadius: BorderRadius.circular(25)),
        child: const Row(children: [StudioIconBox(Icons.tune_rounded,
          color: auroraCyan, background: Color(0xFF3A2A89)),
          SizedBox(width: 12), Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('O‘zingiz belgilaysiz',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
              SizedBox(height: 4), Text('Tariflar bitta yo‘lovchi uchun.',
                style: TextStyle(color: Colors.white70, fontSize: 12))]))])),
      const SizedBox(height: 20),
      ...tiers.map((tier) => Padding(padding: const EdgeInsets.only(bottom: 11),
        child: StudioCard(child: Row(children: [
          const StudioIconBox(Icons.payments_outlined), const SizedBox(width: 13),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tier.$2, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4), Text(tier.$3,
              style: const TextStyle(color: softGrey, fontSize: 11.5)),
            const SizedBox(height: 7), Text(uzs(s.priceBands[tier.$1]!),
              style: const TextStyle(fontSize: 17, color: emerald, fontWeight: FontWeight.w900)),
          ])),
          IconButton(onPressed: () => _editPrice(context, ref, tier.$1, tier.$2,
            s.priceBands[tier.$1]!),
            icon: const Icon(Icons.edit_outlined, color: emerald),
            tooltip: 'Narxni o‘zgartirish'),
        ])))) ,
      const SizedBox(height: 12),
      const StudioCard(color: paleMint, child: Row(children: [
        Icon(Icons.info_outline, color: emerald), SizedBox(width: 11),
        Expanded(child: Text('Demo narxlar faqat telefon xotirasida ishlaydi. '
          'Haqiqiy tariflar keyinchalik serverga ulanadi.',
          style: TextStyle(color: softGrey, fontSize: 12, height: 1.5)))])),
      const SizedBox(height: 18), const DemoDisclaimer(),
    ]);
  }
  void _editPrice(BuildContext context, WidgetRef ref, int upper, String title, int current) {
    final controller = TextEditingController(text: '$current');
    showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(
      title: Text(title), content: TextField(controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(labelText: 'Bir kishiga (so‘m)',
          prefixIcon: Icon(Icons.payments_outlined))),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext),
        child: const Text('Bekor qilish')),
        FilledButton(onPressed: () {
          final result = ref.read(studioProvider.notifier)
            .updatePrice(upper, int.tryParse(controller.text) ?? 0);
          if (result == null) Navigator.pop(dialogContext);
          demoSnack(context, result ?? 'Demo narx yangilandi.');
        }, child: const Text('Saqlash'))],
    ));
  }
}

class StudioPickupPage extends ConsumerWidget {
  final DemoOffer offer;
  const StudioPickupPage({super.key, required this.offer});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(studioProvider);
    final parts = offer.pickupTime.split(':');
    final startMinute = int.parse(parts[0]) * 60 + int.parse(parts[1]);
    final stops = List<(String, String, String)>.generate(offer.stops, (index) {
      final timeMinute = (startMinute + index * 10) % 1440;
      final time = '${(timeMinute ~/ 60).toString().padLeft(2, '0')}:${(timeMinute % 60).toString().padLeft(2, '0')}';
      final firstIndex = pilotStops.indexOf(offer.pickup);
      final name = index == 0 ? offer.pickup
          : pilotStops[((firstIndex < 0 ? 0 : firstIndex) + index) % pilotStops.length];
      final people = offer.passengers ~/ offer.stops +
          (index < offer.passengers % offer.stops ? 1 : 0);
      return (time, name, '$people yo‘lovchi');
    });
    return Scaffold(appBar: AppBar(title: const Text('Olib ketish tartibi',
      style: TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const StudioPill('QABUL QILINGAN · DEMO', icon: Icons.check_circle_outline),
        const SizedBox(height: 15), const StudioRouteMap(height: 185),
        const SizedBox(height: 18),
        Text(offer.route, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        Text('${offer.pickupTime} · ${offer.passengers} yo‘lovchi',
          style: const TextStyle(color: softGrey, fontSize: 13)),
        const SizedBox(height: 20),
        StudioCard(child: Column(children: List.generate(stops.length, (i) {
          final checked = s.pickedUpStops.contains(offer.id * 100 + i);
          return Column(children: [
            InkWell(onTap: () => ref.read(studioProvider.notifier).markPickup(i, offerId: offer.id),
              child: Padding(padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(children: [
                  StudioIconBox(checked ? Icons.check_rounded : Icons.location_on_outlined,
                    size: 42, background: checked ? paleMint : softBackground),
                  const SizedBox(width: 12), Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(stops[i].$2, style: const TextStyle(fontWeight: FontWeight.w800)),
                      Text('${stops[i].$1} · ${stops[i].$3}',
                        style: const TextStyle(color: softGrey, fontSize: 11.5)),
                    ])),
                  Icon(checked ? Icons.check_circle_rounded : Icons.circle_outlined,
                    color: checked ? emerald : softGrey),
                ]))),
            if (i != stops.length - 1) const Divider(color: borderColor),
          ]);
        }))),
        const SizedBox(height: 17),
        SizedBox(width: double.infinity, child: FilledButton.icon(
          onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const StudioChatPage())),
          icon: const Icon(Icons.chat_bubble_outline), label: const Text('Xavfsiz chat · demo'))),
        const SizedBox(height: 18), const DemoDisclaimer(),
      ]));
  }
}
