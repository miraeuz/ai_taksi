import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'studio_design.dart';
import 'studio_state.dart';
import 'shared_pages.dart' show DemoDisclaimer;

/// Informational demo only: NO emergency request is dispatched.
class StudioSafetyPage extends ConsumerWidget {
  const StudioSafetyPage({super.key});

  void _demoDialog(BuildContext context, String title, String message) {
    showDialog<void>(context: context, builder: (ctx) => AlertDialog(
      title: Text(title), content: Text(message),
      actions: [FilledButton(onPressed: () => Navigator.pop(ctx),
        child: const Text('Tushunarli'))]));
  }

  @override Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(studioProvider);
    final ctrl = ref.read(studioProvider.notifier);
    return Scaffold(appBar: AppBar(title: const Text('Xavfsizlik markazi',
      style: TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(padding: const EdgeInsets.fromLTRB(19, 5, 19, 28), children: [
        Container(padding: const EdgeInsets.all(23),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(25),
            gradient: const LinearGradient(colors: [auroraNavy, Color(0xFF40308C)])),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.verified_user_rounded, color: auroraCyan, size: 34),
            SizedBox(height: 12), Text('Ishonchli safar — bosh ustuvorlik',
              style: TextStyle(fontWeight: FontWeight.w900,
                color: Colors.white, fontSize: 23)),
            SizedBox(height: 9), Text('Raqamlar yashiriladi. Haydovchilar admin tomonidan tekshiriladi. Bular demo interfeysdagi holatlar.',
              style: TextStyle(color: Color(0xFFD7D9F9), fontSize: 12.5, height: 1.5)),
          ])),
        const SizedBox(height: 21), const StudioSection('Safar xavfsizligi'),
        StudioCard(child: Column(children: [
          ListTile(contentPadding: EdgeInsets.zero,
            leading: const StudioIconBox(Icons.shield_outlined),
            title: const Text('Tekshirilgan haydovchi'),
            subtitle: const Text('Hujjatlar admin tomonidan tekshiriladi · demo'),
            trailing: const Icon(Icons.check_circle_rounded, color: auroraPurple)),
          const Divider(color: borderColor),
          ListTile(contentPadding: EdgeInsets.zero,
            leading: const StudioIconBox(Icons.link_rounded),
            title: const Text('Safarni ulashish'),
            subtitle: const Text('Namuna havola va vaqt chizig‘i'),
            onTap: () => _demoDialog(context, 'Safarni ulashish · demo',
              'Hozircha kuzatish havolasi yaratilmaydi va hech kimga xabar yuborilmaydi.'),
            trailing: const Icon(Icons.chevron_right)),
          const Divider(color: borderColor),
          ListTile(contentPadding: EdgeInsets.zero,
            leading: const StudioIconBox(Icons.warning_amber_rounded),
            title: const Text('SOS yordam'),
            subtitle: const Text('Faqat ogohlantirish dizayni'),
            onTap: () => _demoDialog(context, 'SOS · faqat demo',
              'Bu tugma haqiqiy SOS yubormaydi. Favqulodda holatda mahalliy tezkor xizmatga bevosita murojaat qiling.'),
            trailing: const Icon(Icons.chevron_right)),
        ])),
        const SizedBox(height: 20), const StudioSection('Safar afzalliklari'),
        StudioCard(child: Column(children: [
          SwitchListTile(contentPadding: EdgeInsets.zero,
            title: const Text('Faqat ayollar guruhi'),
            subtitle: const Text('Namuna saralash afzalligi, serverga yuborilmaydi'),
            value: s.womenOnly,
            onChanged: (v) => ctrl.updateRidePrefs(womenOnly: v)),
          const Divider(color: borderColor),
          SwitchListTile(contentPadding: EdgeInsets.zero,
            title: const Text('Tinch safar'),
            subtitle: const Text('Demo haydovchi uchun ko‘rsatma'),
            value: s.quietRide,
            onChanged: (v) => ctrl.updateRidePrefs(quietRide: v)),
        ])),
        const SizedBox(height: 20), const DemoDisclaimer(),
      ]));
}

}
