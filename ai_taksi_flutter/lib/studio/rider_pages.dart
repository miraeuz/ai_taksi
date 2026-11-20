import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'studio_state.dart';
import 'studio_design.dart';
import 'studio_app.dart' show demoSnack;
import 'shared_pages.dart';
import 'fleet_page.dart';
import 'safety_page.dart';
import 'mock_catalog.dart';

class RiderHomePage extends ConsumerWidget {
  const RiderHomePage({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(studioProvider);
    final a = ref.read(studioProvider.notifier);
    return ListView(padding: const EdgeInsets.fromLTRB(20, 13, 20, 32), children: [
      const StudioHeadline(title: 'Salom, Aziza 👋',
        subtitle: 'Yaxshi kun! Navbatdagi safaringizni rejalaymiz.',
        eyebrow: 'SIZNING AQLLI QATNOVINGIZ'),
      const SizedBox(height: 21),
      AuroraJourneyHero(
        footer: '${s.scheduleDays.map((d) => weekdayLabels[d]).join(' · ')}  /  ${s.arrivalTime} gacha'),
      const SizedBox(height: 11),
      Row(children: [
        Expanded(child: _AuroraQuickFact(icon: Icons.groups_rounded,
          headline: '8 yo‘lovchi', detail: 'namuna guruh')),
        const SizedBox(width: 9),
        Expanded(child: _AuroraQuickFact(icon: Icons.payments_outlined,
          headline: '20 000 so‘m', detail: 'namuna narx')),
      ]),
      const SizedBox(height: 20),
      StudioCard(padding: const EdgeInsets.all(15), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const StudioIconBox(Icons.auto_awesome_rounded,
            color: auroraCyan, background: auroraNavy), const SizedBox(width: 10),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text('Smart Avtopark',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                Text('Yengil · Damas · Avtobus · Electric',
                  style: TextStyle(fontSize: 11, color: softGrey))])),
            const StudioPill('7 MODEL', icon: Icons.bolt_rounded)]),
          const SizedBox(height: 14),
          SizedBox(height: 106, child: ListView(scrollDirection: Axis.horizontal,
            children: demoVehicles.take(5).map((vehicle) => GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const StudioFleetPage())),
              child: Container(width: 112, margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(17),
                  color: vehicle.color.withValues(alpha: .08)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(vehicle.icon, color: vehicle.color, size: 32),
                  const SizedBox(height: 8), Text(vehicle.name,
                    textAlign: TextAlign.center, style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 10.8)),
                  Text('${vehicle.seats} o‘rin', style: const TextStyle(
                    color: softGrey, fontSize: 10)),
                ])))).toList())),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const StudioFleetPage())),
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: const Text('Barcha transportlarni solishtirish'))),
        ])),
      const SizedBox(height: 21),
      const StudioSection('Sizning keyingi safaringiz', trailing: 'Dushanba · 23 noy'),
      _ConfirmationPanel(stage: s.ride,
        onYes: () => a.going(true), onNo: () => a.going(false),
        onView: () => a.tab(2), onSchedule: () => a.tab(1)),
      const SizedBox(height: 20),
      const StudioSection('Nega AI Taksi?'),
      const Row(children: [
        Expanded(child: _Benefit(icon: Icons.verified_user_outlined,
          title: 'Tekshirilgan', caption: 'Haydovchilar')),
        SizedBox(width: 10),
        Expanded(child: _Benefit(icon: Icons.groups_outlined,
          title: 'Birga arzon', caption: 'Guruhli safar')),
      ]),
      const SizedBox(height: 11),
      const StudioCard(padding: EdgeInsets.all(15), child: Row(children: [
        StudioIconBox(Icons.shield_outlined), SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text('Raqamlar himoyalangan',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5)),
            Text('Aloqa ilova ichida · bu ekran namoyish rejimida',
              style: TextStyle(color: softGrey, fontSize: 11.5))])),
        Icon(Icons.arrow_forward_ios, size: 14, color: softGrey),
      ])),
      const SizedBox(height: 16),
      InkWell(onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const StudioSafetyPage())),
        child: const StudioCard(child: Row(children: [
          StudioIconBox(Icons.health_and_safety_outlined,
            color: auroraCyan, background: auroraNavy), SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text('Xavfsizlik markazi', style: TextStyle(
              fontWeight: FontWeight.w900)),
              Text('SOS namoyishi · afzalliklar · safarni ulashish',
                style: TextStyle(fontSize: 11, color: softGrey))])),
          Icon(Icons.chevron_right_rounded, color: auroraPurple),
        ]))),
      const SizedBox(height: 19), const DemoDisclaimer(),
    ]);
  }
}

/// Illustrative demo facts, never presented as live pricing or availability.
class _AuroraQuickFact extends StatelessWidget {
  final IconData icon;
  final String headline, detail;
  const _AuroraQuickFact({required this.icon, required this.headline,
    required this.detail});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
    decoration: BoxDecoration(color: context.glassSurface,
      border: Border.all(color: context.glassLine),
      borderRadius: BorderRadius.circular(17)),
    child: Row(children: [Icon(icon, size: 23, color: auroraPurple),
      const SizedBox(width: 9), Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(headline, style: TextStyle(fontSize: 12,
          fontWeight: FontWeight.w900, color: context.surfaceInk)),
        const SizedBox(height: 2),
        Text(detail, style: const TextStyle(fontSize: 10, color: softGrey)),
      ]))]));
}

class _Benefit extends StatelessWidget {
  final IconData icon;
  final String title, caption;
  const _Benefit({required this.icon, required this.title, required this.caption});
  @override Widget build(BuildContext context) => StudioCard(
    padding: const EdgeInsets.all(15), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        StudioIconBox(icon, size: 38), const SizedBox(height: 11),
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
        Text(caption, style: const TextStyle(fontSize: 11, color: softGrey)),
      ]));
}

class _ConfirmationPanel extends StatelessWidget {
  final RideProgress stage;
  final VoidCallback onYes, onNo, onView, onSchedule;
  const _ConfirmationPanel({required this.stage, required this.onYes,
    required this.onNo, required this.onView, required this.onSchedule});
  @override Widget build(BuildContext context) {
    final question = stage == RideProgress.question;
    final skipped = stage == RideProgress.skipped;
    final offered = stage == RideProgress.offered;
    final headline = question ? 'Safarga borasizmi?' : skipped
      ? 'Safar o‘tkazib yuborildi' : offered ? 'Sizga transport topildi!'
      : stage == RideProgress.booked ? 'Joyingiz band qilindi'
      : stage == RideProgress.riding ? 'Safar davom etmoqda' : 'Safar yakunlandi';
    return StudioCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [StudioIconBox(question ? Icons.notifications_active_outlined
        : skipped ? Icons.event_busy_outlined : Icons.check_circle_outline, size: 47),
        const SizedBox(width: 12), Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(headline, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            const SizedBox(height: 3), const Text('NamSU · 13:00 ga yetib borish',
              style: TextStyle(color: softGrey, fontSize: 12)),
          ]))]),
      const SizedBox(height: 15),
      Text(question ? 'Birgina javob — biz siz uchun mos hamroh safarni tayyorlaymiz.'
        : skipped ? 'Istasangiz demo safarni qayta boshlashingiz mumkin.'
        : 'Safar haqidagi ma’lumotlar va keyingi qadamni ko‘ring.',
        style: const TextStyle(color: softGrey, fontSize: 13, height: 1.55)),
      const SizedBox(height: 16),
      if (question) ...[
        Row(children: [Expanded(child: FilledButton.icon(
          onPressed: onYes,
          style: FilledButton.styleFrom(backgroundColor: auroraCyan,
            foregroundColor: auroraNavy),
          icon: const Icon(Icons.check_circle_outline, size: 18),
          label: const Text('Boraman'))), const SizedBox(width: 9),
          Expanded(child: OutlinedButton(onPressed: onNo, child: const Text('Bormayman')))]),
        Center(child: TextButton.icon(onPressed: onSchedule,
          icon: const Icon(Icons.edit_calendar_outlined, size: 17),
          label: const Text('Vaqtni o‘zgartirish'))),
      ] else if (skipped) SizedBox(width: double.infinity,
        child: FilledButton(onPressed: onYes, child: const Text('Yana urinib ko‘rish')))
      else ...[
        StudioPill(offered ? 'MOS SAFAR TOPILDI' : 'DEMO SAFAR',
          icon: Icons.check_circle_rounded), const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: onView,
          icon: const Icon(Icons.arrow_forward_rounded), label: const Text('Safarni ko‘rish'))),
      ],
    ]));
  }
}

class RiderSchedulePage extends ConsumerStatefulWidget {
  const RiderSchedulePage({super.key});
  @override ConsumerState<RiderSchedulePage> createState() => _RiderSchedulePageState();
}
class _RiderSchedulePageState extends ConsumerState<RiderSchedulePage> {
  late Set<int> selected;
  late String pickup, direction, arrival;
  @override void initState() {
    super.initState();
    final s = ref.read(studioProvider);
    selected = {...s.scheduleDays}; pickup = s.pickup;
    direction = s.direction; arrival = s.arrivalTime;
  }
  @override Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 13, 20, 36), children: [
      const StudioHeadline(title: 'Haftalik jadval',
        subtitle: 'Bir marta sozlang. Har safar qayta izlash shart emas.',
        eyebrow: 'SHAXSIY REJANGIZ'),
      const SizedBox(height: 22),
      StudioCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Qaysi kunlarda qatnaysiz?',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        const SizedBox(height: 13),
        Wrap(spacing: 7, runSpacing: 7, children: List.generate(7, (i) {
          final active = selected.contains(i);
          return ChoiceChip(label: Text(weekdayLabels[i]), selected: active,
            selectedColor: paleMint, backgroundColor: softBackground,
            side: BorderSide(color: active ? emerald : borderColor),
            labelStyle: TextStyle(color: active ? emerald : inkSoft,
              fontWeight: FontWeight.w800),
            onSelected: (yes) => setState(() { yes ? selected.add(i) : selected.remove(i); }));
        })),
        const SizedBox(height: 22),
        const Text('Safar yo‘nalishi', style: TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 9),
        DropdownButtonFormField<String>(initialValue: direction, isExpanded: true,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.swap_horiz, color: emerald)),
          items: const [DropdownMenuItem(value: 'Kosonsoy → NamSU',
            child: Text('Kosonsoy → NamSU')),
            DropdownMenuItem(value: 'NamSU → Kosonsoy',
              child: Text('NamSU → Kosonsoy'))],
          onChanged: (v) { if (v != null) setState(() => direction = v); }),
        const SizedBox(height: 20),
        const Text('Olib ketish bekati', style: TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 9),
        DropdownButtonFormField<String>(initialValue: pickup, isExpanded: true,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.place_outlined, color: emerald)),
          items: pilotStops.map((stop) => DropdownMenuItem(value: stop, child: Text(stop))).toList(),
          onChanged: (v) { if (v != null) setState(() => pickup = v); }),
        const SizedBox(height: 20),
        const Text('Yetib borish vaqti', style: TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 9),
        Material(color: context.glassSurface, borderRadius: BorderRadius.circular(16),
          child: InkWell(borderRadius: BorderRadius.circular(16), onTap: () async {
            final parts = arrival.split(':');
            final picked = await showTimePicker(context: context,
              initialTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
              helpText: 'Yetib borish vaqti');
            if (picked != null) {
              setState(() => arrival =
                '${picked.hour.toString().padLeft(2,'0')}:${picked.minute.toString().padLeft(2,'0')}');
            }
          }, child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
            const Icon(Icons.schedule, color: emerald), const SizedBox(width: 11),
            Expanded(child: Text('$arrival gacha',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15))),
            const Icon(Icons.keyboard_arrow_down_rounded, color: emerald),
          ])))),
        const SizedBox(height: 22),
        SizedBox(width: double.infinity, child: FilledButton.icon(
          onPressed: () {
            final error = ref.read(studioProvider.notifier)
              .saveSchedule(selected, pickup, arrival, direction);
            demoSnack(context, error ?? 'Haftalik jadval demo xotirasida saqlandi.');
          }, icon: const Icon(Icons.check_rounded), label: const Text('Jadvalni saqlash'))),
      ])),
      const SizedBox(height: 17),
      const StudioCard(color: paleMint,
        child: Row(children: [Icon(Icons.auto_awesome_outlined, color: emerald),
          SizedBox(width: 11), Expanded(child: Text(
            'Haqiqiy tizim safardan oldin eslatma yuboradi. Hozircha bu offline namoyish.',
            style: TextStyle(color: softGrey, fontSize: 12.5, height: 1.5)))])),
      const SizedBox(height: 20), const DemoDisclaimer(),
    ]);
}

class RiderTripPage extends ConsumerWidget {
  const RiderTripPage({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(studioProvider);
    final a = ref.read(studioProvider.notifier);
    final unavailable = s.ride == RideProgress.question || s.ride == RideProgress.skipped;
    return ListView(padding: const EdgeInsets.fromLTRB(20, 13, 20, 35), children: [
      const StudioHeadline(title: 'Mening safarlarim',
        subtitle: 'Taklif, haydovchi va qatnov holati — bir joyda.',
        eyebrow: 'SAFARLARIM'),
      const SizedBox(height: 19), const StudioRouteMap(height: 173),
      const SizedBox(height: 20),
      StudioCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [StudioPill(unavailable ? 'REJA KUTILMOQDA'
          : s.ride == RideProgress.offered ? 'YANGI TAKLIF'
          : s.ride == RideProgress.booked ? 'TASDIQLANGAN'
          : s.ride == RideProgress.riding ? 'YO‘LDA' : 'YAKUNLANGAN',
          icon: Icons.circle, foreground: emerald),
          const Spacer(), const Text('23 NOV',
            style: TextStyle(fontSize: 11, color: softGrey, fontWeight: FontWeight.w800))]),
        const SizedBox(height: 15),
        const Text('Kosonsoy → NamSU',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -.3)),
        const SizedBox(height: 11),
        const _RideDetailRow(Icons.directions_bus_outlined, 'Transport', 'Oq Damas'),
        const _RideDetailRow(Icons.verified_user_outlined, 'Haydovchi', 'Sherzod · 4.9 ★'),
        const _RideDetailRow(Icons.badge_outlined, 'Davlat raqami', '01 A 123 BC'),
        const _RideDetailRow(Icons.schedule_outlined, 'Bekatdagi vaqt', '10:40'),
        const _RideDetailRow(Icons.groups_outlined, 'Yo‘lovchilar', '8 kishi'),
        const Divider(height: 28, color: borderColor),
        Row(children: [const Text('Bir kishiga',
          style: TextStyle(color: softGrey, fontSize: 13)), const Spacer(),
          Text(uzs(s.riderFare), style: const TextStyle(fontSize: 23,
            fontWeight: FontWeight.w900, color: emerald))]),
        const SizedBox(height: 18),
        if (unavailable) SizedBox(width: double.infinity,
          child: FilledButton(onPressed: () => a.tab(0),
            child: const Text('Avval safarni tasdiqlang'))),
        if (s.ride == RideProgress.offered) ...[
          SizedBox(width: double.infinity, child: FilledButton.icon(
            onPressed: a.acceptRide, icon: const Icon(Icons.check_circle_outline),
            label: const Text('Joyni tasdiqlash'))),
          const SizedBox(height: 9),
          SizedBox(width: double.infinity, child: OutlinedButton(
            onPressed: a.declineRide, child: const Text('Taklifni rad etish'))),
        ],
        if (s.ride == RideProgress.booked) ...[
          const StudioPill('Joyingiz saqlandi', icon: Icons.task_alt_rounded),
          const SizedBox(height: 13),
          SizedBox(width: double.infinity, child: FilledButton(
            onPressed: a.startRide, child: const Text('Safarni boshlash · demo'))),
          const SizedBox(height: 9),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(
            onPressed: () => _openChat(context),
            icon: const Icon(Icons.chat_bubble_outline), label: const Text('Xavfsiz chat'))),
        ],
        if (s.ride == RideProgress.riding) ...[
          const StudioPill('Safar davom etmoqda', icon: Icons.navigation_outlined),
          const SizedBox(height: 13),
          SizedBox(width: double.infinity, child: FilledButton(
            onPressed: a.finishRide, child: const Text('Safarni yakunlash · demo'))),
          const SizedBox(height: 9),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(
            onPressed: () => _openChat(context),
            icon: const Icon(Icons.chat_bubble_outline), label: const Text('Haydovchi bilan chat'))),
        ],
        if (s.ride == RideProgress.completed) ...[
          const Text('Safaringiz qanday o‘tdi?',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 9),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => IconButton(
            onPressed: () => a.rate(i+1),
            icon: Icon(i < s.rating ? Icons.star_rounded : Icons.star_outline_rounded,
              color: warmGold, size: 36)))),
          if (s.rating > 0) const Center(child: StudioPill('Rahmat! Baho saqlandi',
            icon: Icons.check_circle_outline)),
        ],
      ])),
      const SizedBox(height: 20), const StudioSection('Oldingi safarlar'),
      ...demoHistory.map((trip) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: _HistoryCard(day: trip.date, price: uzs(trip.fare),
          stars: trip.rating.toStringAsFixed(1)))),
      const SizedBox(height: 19), const DemoDisclaimer(),
    ]);
  }
  void _openChat(BuildContext context) => Navigator.of(context)
    .push(MaterialPageRoute(builder: (_) => const StudioChatPage()));
}

class _RideDetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _RideDetailRow(this.icon, this.label, this.value);
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(children: [Icon(icon, size: 19, color: emerald),
      const SizedBox(width: 10), Expanded(child: Text(label,
        style: const TextStyle(color: softGrey, fontSize: 12.5))),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5))]));
}

class _HistoryCard extends StatelessWidget {
  final String day, price, stars;
  const _HistoryCard({required this.day, required this.price, required this.stars});
  @override Widget build(BuildContext context) => StudioCard(
    padding: const EdgeInsets.all(14), child: Row(children: [
      const StudioIconBox(Icons.check_circle_outline, size: 42),
      const SizedBox(width: 12), Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(day, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
          const SizedBox(height: 4), Text('NamSU · $stars ★',
            style: const TextStyle(color: softGrey, fontSize: 11.5))])),
      Text(price, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5)),
    ]));
}
