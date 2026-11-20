import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'studio_state.dart';
import 'studio_design.dart';
import 'studio_app.dart' show demoSnack, toggleAuroraTheme;
import 'fleet_page.dart';
import 'safety_page.dart';

class DemoDisclaimer extends StatelessWidget {
  const DemoDisclaimer({super.key});
  @override Widget build(BuildContext context) => const Row(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(Icons.science_outlined, color: softGrey, size: 16), SizedBox(width: 7),
      Expanded(child: Text('Offline demo · Hammasi namunaviy. '
        'Haqiqiy haydovchi, to‘lov yoki xabar yuborilmaydi.',
        style: TextStyle(color: softGrey, fontSize: 11.5, height: 1.45))),
    ]);
}

class StudioProfilePage extends ConsumerWidget {
  const StudioProfilePage({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(studioProvider);
    final passenger = s.role == StudioRole.passenger;
    return ListView(padding: const EdgeInsets.fromLTRB(20, 13, 20, 35), children: [
      const StudioHeadline(title: 'Profil va sozlamalar',
        subtitle: 'Demo rejimini boshqaring va rollarni sinab ko‘ring.',
        eyebrow: 'SIZNING KABINETINGIZ'),
      const SizedBox(height: 19),
      StudioCard(child: Row(children: [
        StudioIconBox(passenger ? Icons.school_rounded : Icons.local_taxi_rounded,
          size: 62, background: paleMint), const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(passenger ? 'Aziza' : 'Sherzod',
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(passenger ? 'Talaba · Yo‘lovchi' : 'Tekshirilgan haydovchi · Damas',
              style: const TextStyle(color: softGrey, fontSize: 12.5)),
            const SizedBox(height: 8), const StudioPill('NAMOYISH PROFILI',
              icon: Icons.verified_outlined)])),
      ])),
      const SizedBox(height: 22), const StudioSection('Rejimni almashtirish'),
      StudioCard(child: Column(children: [
        _RoleOption(icon: Icons.school_outlined, title: 'Yo‘lovchi',
          caption: 'Jadval, safar va baholash', selected: passenger,
          onTap: () => ref.read(studioProvider.notifier).switchRole(StudioRole.passenger)),
        const Divider(color: borderColor),
        _RoleOption(icon: Icons.drive_eta_outlined, title: 'Haydovchi',
          caption: 'Takliflar, bekatlar, tariflar', selected: !passenger,
          onTap: () => ref.read(studioProvider.notifier).switchRole(StudioRole.driver)),
      ])),
      const SizedBox(height: 20), const StudioSection('Yangi demo imkoniyatlari'),
      StudioCard(child: Column(children: [
        ListTile(contentPadding: EdgeInsets.zero,
          leading: const StudioIconBox(Icons.directions_car_rounded),
          title: const Text('Smart Avtopark'),
          subtitle: const Text('7 ta model · narx · sig‘im · taqqoslash'),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const StudioFleetPage()))),
        const Divider(color: borderColor),
        ListTile(contentPadding: EdgeInsets.zero,
          leading: const StudioIconBox(Icons.shield_outlined),
          title: const Text('Xavfsizlik markazi'),
          subtitle: const Text('Safar sozlamalari va demo SOS'),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const StudioSafetyPage()))),
      ])),
      const SizedBox(height: 21), const StudioSection('Ko‘rinish'),
      StudioCard(child: Row(children: [
        const StudioIconBox(Icons.palette_outlined), const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(context.isNight ? 'Tungi Aurora' : 'Yorug‘ Aurora',
            style: const TextStyle(fontWeight: FontWeight.w900)),
          Text('Barcha ekranlar uchun rang rejimi',
            style: TextStyle(color: context.subInk, fontSize: 11.5)),
        ])),
        Switch.adaptive(value: context.isNight,
          onChanged: (_) => toggleAuroraTheme(ref)),
      ])),
      const SizedBox(height: 21), const StudioSection('Xavfsizlik va maxfiylik'),
      const StudioCard(child: Column(children: [
        _StaticSettings(Icons.phone_disabled_outlined, 'Raqam ko‘rinmaydi',
          'Ilova ekranlarida shaxsiy raqam yo‘q'),
        Divider(color: borderColor),
        _StaticSettings(Icons.chat_bubble_outline, 'Xavfsiz chat',
          'Raqamlar va username bloklanadi · demo'),
        Divider(color: borderColor),
        _StaticSettings(Icons.wifi_off_rounded, 'Offline ishlaydi',
          'Hozircha internetga ulanmaydi'),
      ])),
      const SizedBox(height: 23),
      SizedBox(width: double.infinity, child: OutlinedButton.icon(
        onPressed: () async {
          final yes = await showDialog<bool>(context: context,
            builder: (c) => AlertDialog(title: const Text('Demoni qayta boshlash?'),
              content: const Text('Tahrirlangan jadval, tarif va xabarlar dastlabki holatiga qaytadi.'),
              actions: [TextButton(onPressed: () => Navigator.pop(c, false),
                child: const Text('Bekor qilish')),
                FilledButton(onPressed: () => Navigator.pop(c, true),
                  child: const Text('Qayta boshlash'))]));
          if (yes == true && context.mounted) {
            ref.read(studioProvider.notifier).reset();
            demoSnack(context, 'Demo dastlabki holatiga qaytdi.');
          }
        }, icon: const Icon(Icons.restart_alt_rounded), label: const Text('Demo holatini tiklash'))),
      const SizedBox(height: 19), const DemoDisclaimer(),
    ]);
  }
}

class _RoleOption extends StatelessWidget {
  final IconData icon;
  final String title, caption;
  final bool selected;
  final VoidCallback onTap;
  const _RoleOption({required this.icon, required this.title,
    required this.caption, required this.selected, required this.onTap});
  @override Widget build(BuildContext context) => InkWell(onTap: onTap,
    child: Padding(padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [StudioIconBox(icon), const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            Text(caption, style: const TextStyle(color: softGrey, fontSize: 11.5))])),
        Icon(selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
          color: selected ? emerald : softGrey),
      ])));
}

class _StaticSettings extends StatelessWidget {
  final IconData icon;
  final String title, caption;
  const _StaticSettings(this.icon, this.title, this.caption);
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(children: [Icon(icon, color: emerald, size: 20),
      const SizedBox(width: 12), Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          Text(caption, style: const TextStyle(color: softGrey, fontSize: 11.5)),
        ]))]));
}

class StudioChatPage extends ConsumerStatefulWidget {
  const StudioChatPage({super.key});
  @override ConsumerState<StudioChatPage> createState() => _StudioChatPageState();
}
class _StudioChatPageState extends ConsumerState<StudioChatPage> {
  final messageController = TextEditingController();
  @override void dispose() { messageController.dispose(); super.dispose(); }
  void send() {
    final result = ref.read(studioProvider.notifier).sendMessage(messageController.text);
    if (result == null) { messageController.clear(); FocusScope.of(context).unfocus(); }
    else demoSnack(context, result);
  }
  @override Widget build(BuildContext context) {
    final state = ref.watch(studioProvider);
    return Scaffold(appBar: AppBar(title: const Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Safar chati', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        Text('Kosonsoy → NamSU · offline demo',
          style: TextStyle(fontSize: 11, color: softGrey)),
      ])),
      body: SafeArea(child: Column(children: [
        Container(width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 5, 16, 6),
          padding: const EdgeInsets.all(12), decoration: BoxDecoration(
            color: context.isNight ? const Color(0xFF28214D) : paleMint, borderRadius: BorderRadius.circular(15)),
          child: const Row(children: [Icon(Icons.lock_outline, color: emerald, size: 18),
            SizedBox(width: 9), Expanded(child: Text(
              'Telefon raqami, @username yoki havola yuborilmaydi. '
              'Real ilovada chat faqat safardan 1 soat oldin va 1 soat keyingacha ochiladi.',
              style: TextStyle(color: softGrey, fontSize: 11.5, height: 1.4)))])),
        Expanded(child: ListView(padding: const EdgeInsets.all(18), children: [
          const Center(child: StudioPill('23 NOY · DEMO', icon: Icons.schedule)),
          const SizedBox(height: 19),
          ...state.messages.map((m) {
            final mine = m.from == 'Siz' || m.from == 'Aziza';
            return Align(alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(constraints: const BoxConstraints(maxWidth: 300),
                margin: const EdgeInsets.only(bottom: 13),
                padding: const EdgeInsets.all(13), decoration: BoxDecoration(
                  color: mine ? emerald : context.glassSurface,
                  borderRadius: BorderRadius.circular(17),
                  border: mine ? null : Border.all(color: context.glassLine)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(m.from, style: TextStyle(color: mine ? const Color(0xFFBCE9D9) : emerald,
                    fontSize: 10, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 5), Text(m.text, style: TextStyle(
                    color: mine ? Colors.white : context.surfaceInk, fontSize: 13, height: 1.45)),
                  const SizedBox(height: 5), Align(alignment: Alignment.bottomRight,
                    child: Text(m.time, style: TextStyle(fontSize: 10,
                      color: mine ? Colors.white70 : softGrey))),
                ])));
          }),
        ])),
        Padding(padding: const EdgeInsets.fromLTRB(15, 8, 15, 15),
          child: Row(children: [Expanded(child: TextField(
            controller: messageController, maxLength: 400, maxLines: 1,
            enabled: state.canChat,
            decoration: InputDecoration(counterText: '',
              hintText: state.canChat ? 'Xabar yozing...' : 'Avval safarni tasdiqlang',
              prefixIcon: const Icon(Icons.chat_bubble_outline, color: emerald)))),
            const SizedBox(width: 9),
            IconButton.filled(onPressed: state.canChat ? send : null,
              style: IconButton.styleFrom(backgroundColor: emerald,
                minimumSize: const Size(52, 52)),
              icon: const Icon(Icons.send_rounded)),
          ])),
      ])));
  }
}

void showDemoNotifications(BuildContext context, WidgetRef ref) {
  ref.read(studioProvider.notifier).readNotifications();
  showModalBottomSheet<void>(context: context, isScrollControlled: true,
    backgroundColor: Theme.of(context).bottomSheetTheme.modalBackgroundColor, showDragHandle: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
    builder: (context) => SafeArea(child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 28),
      child: Column(mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Bildirishnomalar', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 7),
          const Text('Barchasi demo uchun yaratilgan.',
            style: TextStyle(color: softGrey, fontSize: 12)),
          const SizedBox(height: 20),
          const _NotificationRow(Icons.calendar_month_outlined,
            'Jadval eslatmasi', 'Dushanba kuni NamSUga qatnovingiz bor.', '19:00'),
          const Divider(color: borderColor),
          const _NotificationRow(Icons.local_taxi_outlined,
            'Transport tayyor', 'Sizga mos Damas taklifi mavjud.', '18:30'),
          const Divider(color: borderColor),
          const _NotificationRow(Icons.shield_outlined,
            'Xavfsizlik', 'Telefon raqamlaringiz yashirilgan.', 'Kecha'),
          const SizedBox(height: 12),
        ]))));
}
class _NotificationRow extends StatelessWidget {
  final IconData icon;
  final String title, description, time;
  const _NotificationRow(this.icon, this.title, this.description, this.time);
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 11),
    child: Row(children: [StudioIconBox(icon), const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
          Text(description, style: const TextStyle(color: softGrey, fontSize: 11.5))])),
      Text(time, style: const TextStyle(color: softGrey, fontSize: 10)),
    ]));
}
