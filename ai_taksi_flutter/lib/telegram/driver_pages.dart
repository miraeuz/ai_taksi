import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tg_theme.dart';
import 'tg_widgets.dart';
import 'mock_data.dart';
import 'demo_state.dart';
import 'rider_pages.dart';
import 'more_pages.dart';

class DriverDashboard extends ConsumerWidget {
  const DriverDashboard({super.key});
  @override Widget build(BuildContext context,WidgetRef ref){
    final s=ref.watch(demoSessionProvider);
    return TgPagePadding(children:[
      Row(children:[TgAvatar(label:s.displayName,size:52),const SizedBox(width:12),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text('Salom, ${s.displayName}',style:TextStyle(fontSize:20,
            fontWeight:FontWeight.w700,color:context.primaryInk)),
          const SizedBox(height:3),Text('Bugungi ish kuningiz · demo',
            style:TextStyle(color:context.secondaryInk,fontSize:12.5))])),
        const TgBadge('Faol',color:TgColors.green)]),
      const SizedBox(height:18),
      Container(padding:const EdgeInsets.all(19),decoration:BoxDecoration(
        borderRadius:BorderRadius.circular(16),
        gradient:const LinearGradient(colors:[Color(0xFF238AE7),Color(0xFF4CB7EC)])),
        child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Text('Bugungi daromad · demo',style:TextStyle(color:Colors.white70,fontSize:12)),
          const SizedBox(height:8),const Text('280 000 so‘m',
            style:TextStyle(color:Colors.white,fontSize:29,fontWeight:FontWeight.w800)),
          const SizedBox(height:16),const Row(children:[
            Icon(Icons.trending_up_rounded,color:Colors.white,size:19),SizedBox(width:6),
            Text('+12% o‘tgan haftaga nisbatan',style:TextStyle(color:Colors.white,
              fontSize:12.5,fontWeight:FontWeight.w600))]),
        ])),
      const SizedBox(height:13),
      Row(children:[
        Expanded(child:_DriverStat('5','Taklif',Icons.local_taxi_outlined)),
        const SizedBox(width:10),Expanded(child:_DriverStat('3','Safar',Icons.route_outlined)),
        const SizedBox(width:10),Expanded(child:_DriverStat('4.9','Reyting',Icons.star_border_rounded)),
      ]),
      TgSectionTitle('Yangi takliflar',trailing:'Barchasi',
        onTap:()=>ref.read(demoSessionProvider.notifier).setTab(1)),
      TgSurface(padding:const EdgeInsets.symmetric(horizontal:14),
        child:Column(children:mockOffers.where((o)=>
          (s.decisions[o.id]??DemoOfferStatus.pending)==DemoOfferStatus.pending)
          .take(4).map((o)=>_CompactDriverOffer(offer:o)).toList())),
      const TgSectionTitle('Tezkor amallar'),
      TgSurface(padding:const EdgeInsets.symmetric(horizontal:14),child:Column(children:[
        TgRow(icon:Icons.payments_outlined,title:'Narxlarni boshqarish',
          subtitle:'Guruh kattaligi bo‘yicha tariflar',onTap:()=>ref.read(demoSessionProvider.notifier).setTab(2)),
        TgRow(icon:Icons.location_on_outlined,title:'Bekatlar ketma-ketligi',
          subtitle:'Qabul qilingan safarni ko‘ring',onTap:()=>Navigator.push(context,
            MaterialPageRoute(builder:(_)=>DriverPickupPage(offer:mockOffers.first))),divider:false),
      ])),
    ]);
  }
}

class _DriverStat extends StatelessWidget {
  final String amount,label;final IconData icon;
  const _DriverStat(this.amount,this.label,this.icon);
  @override Widget build(BuildContext context)=>TgSurface(padding:const EdgeInsets.all(12),
    child:Column(children:[Icon(icon,color:context.accent,size:22),
      const SizedBox(height:7),Text(amount,style:TextStyle(fontSize:20,
        fontWeight:FontWeight.w800,color:context.primaryInk)),
      const SizedBox(height:3),Text(label,style:TextStyle(color:context.secondaryInk,fontSize:11))]));
}

class _CompactDriverOffer extends StatelessWidget {
  final MockOffer offer;
  const _CompactDriverOffer({required this.offer});
  @override Widget build(BuildContext context)=>TgRow(
    leading:TgAvatar(label:offer.driver,icon:vehicleFor(offer.vehicleId).seats>8?
      Icons.directions_bus_outlined:Icons.directions_car_outlined,size:42),
    title:'${placeName(offer.originId)} → ${placeName(offer.destinationId)}',
    subtitle:'${offer.departure} · ${offer.seats} kishi · ${vehicleFor(offer.vehicleId).model}',
    trailing:Column(crossAxisAlignment:CrossAxisAlignment.end,children:[
      Text('${offer.price ~/ 1000} 000',style:TextStyle(color:context.accent,
        fontWeight:FontWeight.w700,fontSize:13)),const SizedBox(height:4),
      const Icon(Icons.chevron_right_rounded,size:16)]),
    onTap:()=>Navigator.push(context,
      MaterialPageRoute(builder:(_)=>DemoTripDetails(offer:offer))));
}

class DriverOffersPage extends ConsumerStatefulWidget {
  const DriverOffersPage({super.key});
  @override ConsumerState<DriverOffersPage> createState()=>_DriverOffersPageState();
}
class _DriverOffersPageState extends ConsumerState<DriverOffersPage> {
  String filter='Barchasi';
  @override Widget build(BuildContext context){
    final state=ref.watch(demoSessionProvider),ctrl=ref.read(demoSessionProvider.notifier);
    final list=mockOffers.where((o){
      final current=state.decisions[o.id]??DemoOfferStatus.pending;
      return filter=='Barchasi'||filter=='Yangi'&&current==DemoOfferStatus.pending||
        filter=='Qabul qilingan'&&current==DemoOfferStatus.accepted||
        filter=='Rad etilgan'&&current==DemoOfferStatus.declined;
    }).toList();
    return TgPagePadding(children:[
      SingleChildScrollView(scrollDirection:Axis.horizontal,child:Row(children:
        ['Barchasi','Yangi','Qabul qilingan','Rad etilgan'].map((f)=>Padding(
          padding:const EdgeInsets.only(right:7),child:ChoiceChip(label:Text(f),
            selected:filter==f,onSelected:(_)=>setState(()=>filter=f)))).toList())),
      const SizedBox(height:12),
      Row(children:[const TgDemoLabel(),const Spacer(),
        Text('${list.length} ta taklif',style:TextStyle(color:context.secondaryInk,fontSize:12))]),
      const SizedBox(height:13),
      if(list.isEmpty)const TgSurface(child:TgEmptyState(icon:Icons.local_taxi_outlined,
        title:'Takliflar yo‘q',subtitle:'Bu holat uchun demo taklif mavjud emas.')),
      ...list.map((o){
        final status=state.decisions[o.id]??DemoOfferStatus.pending;
        return Padding(padding:const EdgeInsets.only(bottom:11),
          child:TgSurface(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Row(children:[TgAvatar(label:o.driver,icon:Icons.directions_car_outlined,size:44),
              const SizedBox(width:11),Expanded(child:Column(
                crossAxisAlignment:CrossAxisAlignment.start,children:[
                  Text(placeName(o.destinationId),style:TextStyle(color:context.primaryInk,
                    fontWeight:FontWeight.w700,fontSize:15)),
                  const SizedBox(height:4),Text('${placeName(o.originId)} · ${o.date}',
                    style:TextStyle(color:context.secondaryInk,fontSize:12))])),
              if(status==DemoOfferStatus.pending)
                DemoCountdown(key:ValueKey(o.id),minutes:o.minutesLeft)
              else TgBadge(status==DemoOfferStatus.accepted?'Qabul qilindi':'Rad etildi',
                color:status==DemoOfferStatus.accepted?TgColors.green:const Color(0xFFE16B70)),
            ]),const SizedBox(height:15),
            Row(children:[_OfferFact(Icons.groups_outlined,'${o.seats} kishi'),
              const SizedBox(width:14),_OfferFact(Icons.schedule_rounded,o.departure),
              const Spacer(),Text('${o.price ~/ 1000} 000 so‘m',
                style:TextStyle(color:context.accent,fontWeight:FontWeight.w800,fontSize:15))]),
            const SizedBox(height:13),
            if(status==DemoOfferStatus.pending)Row(children:[
              Expanded(child:FilledButton(onPressed:(){ctrl.decideOffer(o.id,true);
                tgMessage(context,'${o.id}: qabul qilindi · demo');},
                child:const Text('Qabul qilish'))),const SizedBox(width:9),
              Expanded(child:OutlinedButton(onPressed:()=>ctrl.decideOffer(o.id,false),
                child:const Text('Rad etish'))),
            ]),
            Align(alignment:Alignment.centerRight,child:TextButton.icon(
              onPressed:()=>Navigator.push(context,MaterialPageRoute(
                builder:(_)=>DriverPickupPage(offer:o))),
              icon:const Icon(Icons.route_outlined,size:18),
              label:const Text('Bekatlarni ko‘rish'))),
          ])));
      }),
    ]);
  }
}
class _OfferFact extends StatelessWidget {
  final IconData icon;final String value;
  const _OfferFact(this.icon,this.value);
  @override Widget build(BuildContext context)=>Row(mainAxisSize:MainAxisSize.min,
    children:[Icon(icon,size:15,color:context.secondaryInk),const SizedBox(width:5),
      Text(value,style:TextStyle(color:context.secondaryInk,fontSize:12))]);
}

class DemoCountdown extends StatefulWidget {
  final int minutes;
  const DemoCountdown({super.key,required this.minutes});
  @override State<DemoCountdown> createState()=>_DemoCountdownState();
}
class _DemoCountdownState extends State<DemoCountdown> {
  late int seconds;
  Timer? timer;
  @override void initState(){super.initState();seconds=widget.minutes*60;
    timer=Timer.periodic(const Duration(seconds:1),(t){if(seconds>0&&mounted){
      setState(()=>seconds--);}else{t.cancel();}});}
  @override void dispose(){timer?.cancel();super.dispose();}
  @override Widget build(BuildContext context)=>TgBadge(
    '${(seconds ~/ 60).toString().padLeft(2,'0')}:${(seconds % 60).toString().padLeft(2,'0')}',
    icon:Icons.timer_outlined,color:seconds>30?context.accent:const Color(0xFFE46C6C));
}

class DriverPickupPage extends ConsumerWidget {
  final MockOffer offer;
  const DriverPickupPage({super.key,required this.offer});
  @override Widget build(BuildContext context,WidgetRef ref){
    final s=ref.watch(demoSessionProvider),ctrl=ref.read(demoSessionProvider.notifier);
    final stops=<String>[offer.pickup,'Yo‘l bo‘yi bekati · namuna',
      'Namangan kirish · namuna',placeName(offer.destinationId)];
    return Scaffold(appBar:AppBar(title:Text('Safar ${offer.id} · bekatlar')),
      body:TgPagePadding(children:[
        TgSurface(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text('${placeName(offer.originId)} → ${placeName(offer.destinationId)}',
            style:TextStyle(fontWeight:FontWeight.w700,color:context.primaryInk,fontSize:16)),
          const SizedBox(height:8),Text('${offer.seats} yo‘lovchi · ${offer.departure} · ${offer.plate}',
            style:TextStyle(color:context.secondaryInk,fontSize:12)),
          const SizedBox(height:12),const TgBadge('Bekatlar va vaqtlar · demo',icon:Icons.route_outlined)])),
        const TgSectionTitle('Olib ketish ketma-ketligi'),
        TgSurface(padding:const EdgeInsets.symmetric(horizontal:14),
          child:Column(children:List.generate(stops.length,(i){
            final id='${offer.id}-$i',done=s.pickedUp.contains(id);
            return TgRow(leading:TgAvatar(label:'${i+1}',size:40,
                icon:done?Icons.check_rounded:Icons.location_on_outlined,
                color:done?TgColors.green:null),
              title:stops[i],subtitle:'${offer.departure} · navbat ${i+1}',
              trailing:Checkbox(value:done,onChanged:(_)=>ctrl.togglePickup(id)),
              onTap:()=>ctrl.togglePickup(id),divider:i!=stops.length-1);
          }))),
        const SizedBox(height:12),
        OutlinedButton.icon(onPressed:()=>Navigator.push(context,
          MaterialPageRoute(builder:(_)=>const DemoTripChatPage())),
          icon:const Icon(Icons.chat_bubble_outline_rounded),label:const Text('Guruh chati · demo')),
      ]));
  }
}

class DriverTariffsPage extends ConsumerWidget {
  const DriverTariffsPage({super.key});
  @override Widget build(BuildContext context,WidgetRef ref){
    final s=ref.watch(demoSessionProvider);
    final bands=s.prices.entries.toList()..sort((a,b)=>a.key.compareTo(b.key));
    return TgPagePadding(children:[
      TgSurface(child:Row(children:[
        const TgAvatar(label:'Tarif',icon:Icons.info_outline_rounded,size:43),
        const SizedBox(width:12),Expanded(child:Text(
          'Narxlar yo‘lovchi soni bo‘yicha belgilanadi. '
          'Bular haqiqiy tarif emas, offline demo qiymatlar.',
          style:TextStyle(fontSize:12.5,color:context.secondaryInk,height:1.5)))])),
      const TgSectionTitle('Har bir yo‘lovchi uchun'),
      TgSurface(padding:const EdgeInsets.symmetric(horizontal:14),
        child:Column(children:bands.map((b)=>TgRow(
          icon:Icons.payments_outlined,title:'1–${b.key} yo‘lovchi',
          subtitle:'${b.value} so‘m / kishi',
          trailing:Row(mainAxisSize:MainAxisSize.min,children:[
            Text('${b.value ~/ 1000} 000',style:TextStyle(
              color:context.accent,fontWeight:FontWeight.w800,fontSize:14)),
            const SizedBox(width:4),Icon(Icons.edit_outlined,color:context.secondaryInk,size:17),
          ]),onTap:()=>_edit(context,ref,b.key,b.value))).toList())),
      const TgSectionTitle('Qo‘shimcha'),
      TgSurface(padding:const EdgeInsets.symmetric(horizontal:14),child:Column(children:[
        TgRow(icon:Icons.directions_car_outlined,title:'Yengil',
          subtitle:'1–3 yo‘lovchi · narx o‘zgarishi mumkin'),
        TgRow(icon:Icons.airport_shuttle_outlined,title:'Damas',
          subtitle:'4–8 yo‘lovchi · guruhli safar'),
        TgRow(icon:Icons.directions_bus_outlined,title:'Avtobus',
          subtitle:'9+ yo‘lovchi · katta guruh',divider:false),
      ])),
    ]);
  }
  void _edit(BuildContext context,WidgetRef ref,int bound,int original){
    final field=TextEditingController(text:original.toString());
    showDialog<void>(context:context,builder:(ctx)=>AlertDialog(
      title:Text('1–$bound kishi narxi'),
      content:TextField(controller:field,keyboardType:TextInputType.number,
        inputFormatters:[FilteringTextInputFormatter.digitsOnly],
        decoration:const InputDecoration(labelText:'Bir kishiga (so‘m)')),
      actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('Bekor')),
        FilledButton(onPressed:(){final price=int.tryParse(field.text)??0;
          final issue=ref.read(demoSessionProvider.notifier).updatePrice(bound,price);
          if(issue!=null){tgMessage(context,issue);return;}
          Navigator.pop(ctx);tgMessage(context,'Tarif saqlandi · demo');},
          child:const Text('Saqlash'))]));
  }
}
