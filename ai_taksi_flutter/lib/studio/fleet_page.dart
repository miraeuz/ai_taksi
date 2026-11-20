import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'studio_design.dart';
import 'studio_state.dart';
import 'mock_catalog.dart';

/// A standalone vehicle discovery flow, using only fictional local fixtures.
/// Selecting a vehicle expresses a preference; it does not reserve or price a real trip.
class StudioFleetPage extends ConsumerStatefulWidget {
  const StudioFleetPage({super.key});
  @override ConsumerState<StudioFleetPage> createState() => _StudioFleetPageState();
}

class _StudioFleetPageState extends ConsumerState<StudioFleetPage> {
  String filter = 'Barchasi';
  bool favoritesOnly = false;
  final filters = const ['Barchasi', 'Yengil', 'Damas', 'Avtobus'];

  @override Widget build(BuildContext context) {
    final s = ref.watch(studioProvider);
    final ctrl = ref.read(studioProvider.notifier);
    final visible = demoVehicles.where((vehicle) =>
      (filter == 'Barchasi' || vehicle.categoryLabel == filter) &&
      (!favoritesOnly || s.favoriteVehicles.contains(vehicle.id))).toList();
    final suitable = s.suitableVehicles;
    return Scaffold(appBar: AppBar(title: const Text('Avtopark · Demo',
      style: TextStyle(fontWeight: FontWeight.w900)),
      actions: [IconButton(tooltip: 'Saralanganlar',
        onPressed: () => setState(() => favoritesOnly = !favoritesOnly),
        icon: Icon(favoritesOnly ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: auroraPurple))]),
      body: ListView(padding: const EdgeInsets.fromLTRB(18, 5, 18, 26), children: [
        Container(padding: const EdgeInsets.all(21),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(26),
            gradient: const LinearGradient(begin: Alignment.topLeft,
              end: Alignment.bottomRight, colors: [auroraNavy, Color(0xFF362081),
                Color(0xFF6252E9)])),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const StudioEyebrow('SMART FLEET · 7 TA MODEL', color: auroraCyan),
            const SizedBox(height: 8),
            const Text('Safaringizga mos\ntransportni tanlang',
              style: TextStyle(color: Colors.white, fontSize: 26, height: 1.12,
                fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            const Text('3 asosiy toifa, 7 xil namunaviy transport. Yakuniy narxni haydovchi belgilaydi.',
              style: TextStyle(color: Color(0xFFE0DEFC), fontSize: 12.5, height: 1.45)),
            const SizedBox(height: 16),
            const Row(children: [Icon(Icons.auto_awesome, color: auroraCyan, size: 18),
              SizedBox(width: 7), Expanded(child: Text('AI tavsiyasi — hozircha oddiy qoidalar asosidagi demo',
                style: TextStyle(color: auroraCyan, fontSize: 11.5, fontWeight: FontWeight.w700)))]),
          ])),
        const SizedBox(height: 18),
        StudioCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const Text('Guruhingiz nechta?',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            const Spacer(), StudioPill('${s.groupSize} kishi', icon: Icons.groups_rounded)]),
          Slider(value: s.groupSize.toDouble(), min: 1, max: 28, divisions: 27,
            label: '${s.groupSize}', onChanged: (v) => ctrl.setGroupSize(v.round())),
          Row(children: [const Icon(Icons.auto_awesome_rounded, color: auroraPurple, size: 17),
            const SizedBox(width: 7), Expanded(child: Text(suitable.isEmpty
              ? 'Bu guruh uchun demo transport yo‘q.'
              : 'Mos variant: ${suitable.first.name} · ${uzs(suitable.first.estimateFor(s.groupSize))}/kishi',
              style: const TextStyle(fontSize: 11.5, color: softGrey,
                fontWeight: FontWeight.w700)))]),
        ])),
        const SizedBox(height: 21),
        const StudioSection('Transport toifalari'),
        SingleChildScrollView(scrollDirection: Axis.horizontal,
          child: Row(children: filters.map((item) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(label: Text(item), selected: filter == item,
              selectedColor: context.isNight ? const Color(0xFF36276A) : paleMint, showCheckmark: false,
              side: BorderSide(color: filter == item ? auroraPurple : borderColor),
              onSelected: (_) => setState(() => filter = item)))).toList())),
        const SizedBox(height: 12),
        ...visible.map((vehicle) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _FleetVehicleCard(vehicle: vehicle, chosen: s.selectedVehicle == vehicle.id,
            saved: s.favoriteVehicles.contains(vehicle.id), enough: vehicle.seats >= s.groupSize && vehicle.kind == s.requiredKind,
            count: s.groupSize,
            onChoose: () => ctrl.selectVehicle(vehicle.id),
            onFavorite: () => ctrl.toggleFavorite(vehicle.id)))) ,
        if (visible.isEmpty) const StudioCard(child: Text(
          'Hozir bu toifada tanlangan transport yo‘q. Boshqa filtrni tanlang.')),
        const SizedBox(height: 12),
        const Padding(padding: EdgeInsets.only(top: 12), child: Text(
          'Offline demo: hech qanday haqiqiy buyurtma yoki narx yaratilmaydi.',
          style: TextStyle(color: softGrey, fontSize: 11.5))),
      ]));
  }
}

class _FleetVehicleCard extends StatelessWidget {
  final DemoVehicle vehicle;
  final bool chosen, saved, enough;
  final int count;
  final VoidCallback onChoose, onFavorite;
  const _FleetVehicleCard({required this.vehicle, required this.chosen,
    required this.saved, required this.enough, required this.count,
    required this.onChoose, required this.onFavorite});
  @override Widget build(BuildContext context) => StudioCard(
    padding: const EdgeInsets.all(15), child: Column(children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 92, height: 97,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(19),
            gradient: LinearGradient(colors: [vehicle.color.withValues(alpha: .16),
              vehicle.color.withValues(alpha: .055)])),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(vehicle.icon, size: 47, color: vehicle.color),
            const SizedBox(height: 4), Text(vehicle.categoryLabel.toUpperCase(),
              style: TextStyle(fontSize: 9, color: vehicle.color,
                fontWeight: FontWeight.w900))])),
        const SizedBox(width: 13),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text(vehicle.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900))),
            InkWell(onTap: onFavorite, child: Padding(padding: const EdgeInsets.all(4),
              child: Icon(saved ? Icons.favorite : Icons.favorite_border,
                color: saved ? Colors.pinkAccent : softGrey, size: 23)))]),
          Text(vehicle.model, style: const TextStyle(color: softGrey, fontSize: 11.5)),
          const SizedBox(height: 7),
          Row(children: [Icon(Icons.groups_outlined, size: 15, color: vehicle.color),
            Text(' ${vehicle.seats} o‘rin', style: const TextStyle(fontSize: 11,
              fontWeight: FontWeight.w800)), const SizedBox(width: 10),
            const Icon(Icons.star_rounded, size: 15, color: warmGold),
            Text(' ${vehicle.rating}', style: const TextStyle(fontSize: 11,
              fontWeight: FontWeight.w800))]),
          if (vehicle.electric) const Padding(padding: EdgeInsets.only(top: 5),
            child: StudioPill('ELEKTR', icon: Icons.bolt_rounded,
              foreground: Color(0xFF087E89), background: auroraCyanSoft)),
        ]))]),
      const SizedBox(height: 12), const Divider(color: borderColor, height: 1),
      const SizedBox(height: 12),
      Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Taxminiy narx · 1 kishi',
          style: TextStyle(color: softGrey, fontSize: 10.5)),
        const SizedBox(height: 3),
        Text(uzs(vehicle.estimateFor(count)), style: const TextStyle(
          color: auroraPurple, fontWeight: FontWeight.w900, fontSize: 19)),
      ])), SizedBox(width: 123, child: FilledButton(
        onPressed: enough ? onChoose : null,
        child: Text(!enough ? 'Mos emas' : chosen ? 'Tanlangan ✓' : 'Tanlash',
          style: const TextStyle(fontSize: 12))))]),
    ]));
}
