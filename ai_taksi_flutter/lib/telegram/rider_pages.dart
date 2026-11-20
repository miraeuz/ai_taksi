import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tg_theme.dart';
import 'tg_widgets.dart';
import 'mock_data.dart';
import 'demo_state.dart';
import 'more_pages.dart';

class RiderDashboard extends ConsumerWidget {
  const RiderDashboard({super.key});
  @override Widget build(BuildContext context,WidgetRef ref){
    final s=ref.watch(demoSessionProvider),ctrl=ref.read(demoSessionProvider.notifier);
    return TgPagePadding(children:[
      Row(children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('Assalomu alaykum, ${s.displayName} 👋',style:TextStyle(fontWeight:FontWeight.w700,
          fontSize:21,color:context.primaryInk,letterSpacing:-.5)),
        const SizedBox(height:4),Text('Bugungi safaringizni birga rejalaymiz',
          style:TextStyle(color:context.secondaryInk,fontSize:13)),
      ])),const TgDemoLabel()]),
      const SizedBox(height:15),const _SunsetBanner(),
      const TgSectionTitle('Sizning yo‘nalishingiz'),
      TgSurface(child:Column(children:[
        TgRow(icon:Icons.my_location_outlined,title:placeName(s.originId),
          subtitle:'Qayerdan',onTap:()async{
            final value=await tgPicker<DemoPlace>(context,title:'Jo‘nash manzili',
              values:origins,label:(p)=>p.name,subtitle:(p)=>p.subtitle);
            if(value!=null)ctrl.setOrigin(value.id);
          }),
        TgRow(icon:Icons.location_on_outlined,title:placeName(s.destinationId),
          subtitle:'Qayerga · tanlash uchun bosing',onTap:()=>ctrl.setTab(1),divider:false),
        const SizedBox(height:11),
        Row(children:[Expanded(child:_InfoCapsule(icon:Icons.access_time_rounded,
            label:'Yetib borish',value:s.arrivalTime)),const SizedBox(width:10),
          Expanded(child:_InfoCapsule(icon:Icons.groups_outlined,label:'Guruh',
            value:'${s.groupSize} kishi'))]),
      ])),
      const TgSectionTitle('Kundalik tasdiq'),
      _TodayCard(status:s.tripStatus,confirm:(yes)=>ctrl.confirmToday(yes),
        showTrip:()=>ctrl.setTab(2),reset:ctrl.resetJourney),
      TgSectionTitle('Yaqin safar takliflari',trailing:'Barchasi',onTap:()=>ctrl.setTab(1)),
      TgSurface(padding:const EdgeInsets.symmetric(horizontal:14,vertical:1),
        child:Column(children:[
          ...mockOffers.where((offer)=>offer.originId==s.originId||
            offer.destinationId==s.destinationId).take(4).map((o)=>TgRow(
              leading:TgAvatar(label:o.driver,icon:vehicleFor(o.vehicleId).seats>8?
                Icons.directions_bus_outlined:Icons.directions_car_outlined),
              title:placeName(o.destinationId),
              subtitle:'${o.date} · ${o.departure} · ${vehicleFor(o.vehicleId).model}',
              trailing:Column(crossAxisAlignment:CrossAxisAlignment.end,children:[
                Text('${o.price ~/ 1000} 000',style:TextStyle(color:context.accent,
                  fontWeight:FontWeight.w700,fontSize:14)),
                Text('so‘m',style:TextStyle(color:context.secondaryInk,fontSize:11)),
              ]),onTap:()=>Navigator.push(context,
                MaterialPageRoute(builder:(_)=>DemoTripDetails(offer:o))))),
        ])),
      const TgSectionTitle('Tezkor kirish'),
      Row(children:[
        Expanded(child:_QuickButton('Jadvalim',Icons.calendar_month_outlined,()=>Navigator.push(context,
          MaterialPageRoute(builder:(_)=>const RiderScheduleEditor())))),
        const SizedBox(width:10),
        Expanded(child:_QuickButton('Avtopark',Icons.directions_car_outlined,()=>Navigator.push(context,
          MaterialPageRoute(builder:(_)=>const DemoFleetPage())))),
        const SizedBox(width:10),
        Expanded(child:_QuickButton('Xavfsizlik',Icons.shield_outlined,()=>Navigator.push(context,
          MaterialPageRoute(builder:(_)=>const DemoSafetyPage())))),
      ]),
    ]);
  }
}

class _SunsetBanner extends StatelessWidget {
  const _SunsetBanner();
  @override Widget build(BuildContext context)=>ClipRRect(borderRadius:BorderRadius.circular(17),
    child:SizedBox(height:154,child:Stack(fit:StackFit.expand,children:[
      Image.asset('assets/images/vehicle_scene.webp',fit:BoxFit.cover,
        alignment:const Alignment(.2,.4)),
      const DecoratedBox(decoration:BoxDecoration(gradient:LinearGradient(
        colors:[Color(0xE9102038),Color(0x971A294B),Color(0x00142742)],
        stops:[0,.55,1]))),
      Padding(padding:const EdgeInsets.all(18),child:Column(
        crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.center,children:[
          const Text('AI TAKSI  /  2026',style:TextStyle(color:Color(0xFF9BDEFF),
            fontSize:10,letterSpacing:1.7,fontWeight:FontWeight.w800)),
          const SizedBox(height:8),
          const Text('Bir yo‘lda,\nbirga qulayroq.',style:TextStyle(color:Colors.white,
            fontSize:22,fontWeight:FontWeight.w800,height:1.15)),
          const SizedBox(height:9),
          Container(padding:const EdgeInsets.symmetric(horizontal:9,vertical:5),
            decoration:BoxDecoration(color:const Color(0xAA18314A),
              borderRadius:BorderRadius.circular(7)),
            child:const Text('Kosonsoy  •  Namangan va boshqa yo‘nalishlar',
              style:TextStyle(color:Colors.white,fontSize:10.8,fontWeight:FontWeight.w500))),
        ])),
    ])));
}

class _InfoCapsule extends StatelessWidget {
  final IconData icon;final String label,value;
  const _InfoCapsule({required this.icon,required this.label,required this.value});
  @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(10),
    decoration:BoxDecoration(color:context.softBlue,borderRadius:BorderRadius.circular(11)),
    child:Row(children:[Icon(icon,color:context.accent,size:20),const SizedBox(width:8),
      Flexible(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(label,style:TextStyle(color:context.secondaryInk,fontSize:10.5)),
        Text(value,style:TextStyle(color:context.primaryInk,fontWeight:FontWeight.w700,fontSize:13))]))]));
}
class _QuickButton extends StatelessWidget {
  final String label;final IconData icon;final VoidCallback onTap;
  const _QuickButton(this.label,this.icon,this.onTap);
  @override Widget build(BuildContext context)=>InkWell(onTap:onTap,
    borderRadius:BorderRadius.circular(14),child:TgSurface(
      padding:const EdgeInsets.symmetric(vertical:16,horizontal:5),
      child:Column(children:[Icon(icon,color:context.accent,size:24),
        const SizedBox(height:8),Text(label,textAlign:TextAlign.center,
          style:TextStyle(color:context.primaryInk,fontWeight:FontWeight.w600,fontSize:11.5))])));
}

class _TodayCard extends StatelessWidget {
  final DemoTripStatus status;final void Function(bool) confirm;
  final VoidCallback showTrip,reset;
  const _TodayCard({required this.status,required this.confirm,
    required this.showTrip,required this.reset});
  @override Widget build(BuildContext context){
    String title='Bugun yo‘lga chiqasizmi?';String subtitle='Dushanba, 23-noyabr · sinov kuni';
    if(status==DemoTripStatus.offered){title='Siz uchun taklif tayyor';subtitle='Guruh va narxni ko‘ring';}
    if(status==DemoTripStatus.confirmed){title='Safaringiz tasdiqlandi';subtitle='Oq Damas · 10:40 da uchrashamiz';}
    if(status==DemoTripStatus.active){title='Safar davom etmoqda';subtitle='Haydovchi: Sherzod · jonli demo';}
    if(status==DemoTripStatus.completed){title='Safar yakunlandi';subtitle='Haydovchini baholashingiz mumkin';}
    if(status==DemoTripStatus.declined){title='Bugun bormaysiz';subtitle='Xohlasangiz qayta tanlashingiz mumkin';}
    return TgSurface(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(children:[TgAvatar(label:'Kun',icon:Icons.event_available_outlined,size:45),
        const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(title,style:TextStyle(fontSize:16,fontWeight:FontWeight.w700,color:context.primaryInk)),
          const SizedBox(height:3),Text(subtitle,style:TextStyle(color:context.secondaryInk,fontSize:12))]))]),
      const SizedBox(height:16),
      if(status==DemoTripStatus.question)Row(children:[
        Expanded(child:FilledButton.icon(onPressed:()=>confirm(true),icon:const Icon(Icons.check_rounded),
          label:const Text('Ha, boraman'))),const SizedBox(width:9),
        Expanded(child:OutlinedButton(onPressed:()=>confirm(false),child:const Text('Yo‘q'))),
      ]) else SizedBox(width:double.infinity,child:FilledButton.icon(
        onPressed:status==DemoTripStatus.declined?reset:showTrip,
        icon:Icon(status==DemoTripStatus.declined?Icons.refresh_rounded:Icons.arrow_forward_rounded),
        label:Text(status==DemoTripStatus.declined?'Qayta tanlash':'Safarni ko‘rish'))),
    ]));
  }
}

class DestinationPage extends ConsumerStatefulWidget {
  const DestinationPage({super.key});
  @override ConsumerState<DestinationPage> createState()=>_DestinationPageState();
}
class _DestinationPageState extends ConsumerState<DestinationPage> {
  final search=TextEditingController();
  String category='Barchasi';
  @override void dispose(){search.dispose();super.dispose();}
  @override Widget build(BuildContext context){
    final s=ref.watch(demoSessionProvider),ctrl=ref.read(demoSessionProvider.notifier);
    final list=destinations.where((p)=>
      (category=='Barchasi'||category=='Saqlangan'&&s.favorites.contains(p.id)||
        p.category==category)&&
      ('${p.name} ${p.subtitle}'.toLowerCase().contains(search.text.toLowerCase()))).toList();
    return TgPagePadding(children:[
      TextField(controller:search,onChanged:(_)=>setState((){}),
        decoration:const InputDecoration(hintText:'Manzil, universitet, hudud qidirish...',
          prefixIcon:Icon(Icons.search_rounded),suffixIcon:Icon(Icons.place_outlined))),
      const SizedBox(height:13),
      SingleChildScrollView(scrollDirection:Axis.horizontal,child:Row(children:
        ['Barchasi','Universitet','Shahar','Transport','Saqlangan'].map((c)=>Padding(
          padding:const EdgeInsets.only(right:7),child:ChoiceChip(label:Text(c),
            selected:category==c,onSelected:(_)=>setState(()=>category=c)))).toList())),
      const SizedBox(height:10),
      TgSectionTitle('Manzillar',trailing:'${list.length} ta'),
      if(list.isEmpty)const TgSurface(child:TgEmptyState(icon:Icons.search_off,
        title:'Manzil topilmadi',subtitle:'Boshqa nom bilan qidirib ko‘ring.')),
      if(list.isNotEmpty)TgSurface(padding:const EdgeInsets.symmetric(horizontal:14),
        child:Column(children:list.map((p)=>TgRow(
          leading:TgAvatar(label:p.name,icon:p.category=='Universitet'?Icons.school_outlined:
            p.category=='Transport'?Icons.train_outlined:Icons.location_city_outlined,size:43),
          title:p.name,subtitle:p.subtitle,
          trailing:Row(mainAxisSize:MainAxisSize.min,children:[
            IconButton(visualDensity:VisualDensity.compact,tooltip:'Saqlash',
              onPressed:()=>ctrl.toggleFavorite(p.id),
              icon:Icon(s.favorites.contains(p.id)?Icons.bookmark_rounded:Icons.bookmark_border_rounded,
                size:21,color:s.favorites.contains(p.id)?context.accent:context.secondaryInk)),
            if(s.destinationId==p.id)Icon(Icons.check_circle,color:context.accent,size:18),
          ]),onTap:(){ctrl.setDestination(p.id);tgMessage(context,'${p.name} tanlandi');
            ctrl.setTab(0);},
        )).toList())),
      const TgSectionTitle('Boshqa jo‘nash hududlari'),
      TgSurface(padding:const EdgeInsets.symmetric(horizontal:14),
        child:Column(children:origins.map((p)=>TgRow(icon:Icons.trip_origin_rounded,
          title:p.name,subtitle:p.subtitle,
          trailing:s.originId==p.id?Icon(Icons.check_circle_rounded,color:context.accent):null,
          onTap:()=>ctrl.setOrigin(p.id))).toList())),
      const SizedBox(height:12),Text('Barcha manzillar va yo‘nalishlar demo ma’lumotlari. '
        'Real joylashuv, vaqt va band qilish tizimga ulanmagan.',
        style:TextStyle(color:context.secondaryInk,fontSize:11.5,height:1.5)),
    ]);
  }
}

class RiderTripsPage extends ConsumerWidget {
  const RiderTripsPage({super.key});
  @override Widget build(BuildContext context,WidgetRef ref){
    final s=ref.watch(demoSessionProvider),ctrl=ref.read(demoSessionProvider.notifier);
    return TgPagePadding(children:[
      const TgSectionTitle('Joriy safar'),
      TgSurface(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Row(children:[TgAvatar(label:'D',icon:Icons.local_taxi_outlined,size:48),
          const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text(placeName(s.destinationId),style:TextStyle(fontWeight:FontWeight.w700,
              fontSize:15,color:context.primaryInk)),
            const SizedBox(height:4),Text('${placeName(s.originId)} · ${s.arrivalTime} gacha',
              style:TextStyle(color:context.secondaryInk,fontSize:12))])),
          TgBadge(_statusText(s.tripStatus)),
        ]),const SizedBox(height:17),
        const Divider(height:1),const SizedBox(height:13),
        _DetailLine(Icons.directions_car_outlined,'Haydovchi','Sherzod · Damas'),
        _DetailLine(Icons.schedule_outlined,'Olib ketish','10:40 · ${s.pickup}'),
        _DetailLine(Icons.payments_outlined,'Bir kishi uchun','20 000 so‘m'),
        const SizedBox(height:13),
        if(s.tripStatus==DemoTripStatus.question)SizedBox(width:double.infinity,
          child:FilledButton(onPressed:()=>ctrl.confirmToday(true),child:const Text('Bugun boraman'))),
        if(s.tripStatus==DemoTripStatus.offered)...[
          Row(children:[Expanded(child:FilledButton(onPressed:ctrl.confirmTrip,
            child:const Text('Tasdiqlash'))),const SizedBox(width:9),
            Expanded(child:OutlinedButton(onPressed:ctrl.declineTrip,child:const Text('Rad etish')))]),
        ],
        if(s.tripStatus==DemoTripStatus.confirmed)SizedBox(width:double.infinity,
          child:FilledButton(onPressed:ctrl.startTrip,child:const Text('Safarni boshlash · demo'))),
        if(s.tripStatus==DemoTripStatus.active)SizedBox(width:double.infinity,
          child:FilledButton(onPressed:ctrl.finishTrip,child:const Text('Safarni yakunlash · demo'))),
        if(s.tripStatus==DemoTripStatus.completed)...[
          Text(s.rating>0?'Rahmat! Baho: ${s.rating} / 5':'Safarni baholang',
            style:TextStyle(color:context.primaryInk,fontWeight:FontWeight.w700)),
          Row(mainAxisAlignment:MainAxisAlignment.center,children:List.generate(5,(i)=>IconButton(
            icon:Icon(i<s.rating?Icons.star_rounded:Icons.star_border_rounded,
              color:const Color(0xFFFFB345),size:34),onPressed:()=>ctrl.rateTrip(i+1)))),
          TextButton(onPressed:ctrl.resetJourney,child:const Text('Yangi demo safar')),
        ],
        if(s.tripStatus==DemoTripStatus.declined)TextButton(onPressed:ctrl.resetJourney,
          child:const Text('Qayta rejalashtirish')),
        if(s.canChat)...[const SizedBox(height:8),SizedBox(width:double.infinity,
          child:OutlinedButton.icon(onPressed:()=>Navigator.push(context,
            MaterialPageRoute(builder:(_)=>const DemoTripChatPage())),
            icon:const Icon(Icons.chat_bubble_outline_rounded),label:const Text('Safar chati')))],
      ])),
      TgSectionTitle('Oldingi safarlar',trailing:'${mockHistory.length} ta'),
      TgSurface(padding:const EdgeInsets.symmetric(horizontal:14),
        child:Column(children:mockHistory.map((h)=>TgRow(
          leading:TgAvatar(label:h.driver,icon:Icons.history_rounded,size:42),
          title:h.route,subtitle:'${h.date} · ${h.vehicle} · ${h.driver}',
          trailing:Text('${h.fare ~/ 1000} 000',style:TextStyle(
            color:context.primaryInk,fontWeight:FontWeight.w700,fontSize:13)),
          onTap:()=>tgMessage(context,'Tarix ma’lumotlari · demo'))).toList())),
    ]);
  }
  String _statusText(DemoTripStatus v)=>switch(v){
    DemoTripStatus.question=>'Kutilmoqda',DemoTripStatus.offered=>'Taklif bor',
    DemoTripStatus.confirmed=>'Tasdiqlangan',DemoTripStatus.active=>'Yo‘lda',
    DemoTripStatus.completed=>'Yakunlangan',DemoTripStatus.declined=>'Bekor',
  };
}

class _DetailLine extends StatelessWidget {
  final IconData icon;final String label,value;
  const _DetailLine(this.icon,this.label,this.value);
  @override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.symmetric(vertical:7),
    child:Row(children:[Icon(icon,color:context.accent,size:20),const SizedBox(width:10),
      Expanded(child:Text(label,style:TextStyle(color:context.secondaryInk,fontSize:12.5))),
      Flexible(child:Text(value,textAlign:TextAlign.end,style:TextStyle(
        color:context.primaryInk,fontWeight:FontWeight.w600,fontSize:12.5)))]));
}

class RiderScheduleEditor extends ConsumerWidget {
  const RiderScheduleEditor({super.key});
  @override Widget build(BuildContext context,WidgetRef ref){
    final s=ref.watch(demoSessionProvider),ctrl=ref.read(demoSessionProvider.notifier);
    return Scaffold(appBar:AppBar(title:const Text('Haftalik rejam')),
      body:TgPagePadding(children:[
        TgSurface(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Text('Qaysi kunlari qatnaysiz?',style:TextStyle(fontWeight:FontWeight.w700,fontSize:16)),
          const SizedBox(height:14),Wrap(spacing:7,runSpacing:8,children:List.generate(7,(i)=>
            ChoiceChip(label:Text(weekdays[i]),selected:s.scheduleDays.contains(i),
              onSelected:(_)=>ctrl.toggleDay(i)))),
          const SizedBox(height:14),
          TgRow(icon:Icons.my_location_outlined,title:'Jo‘nash hududi',
            subtitle:placeName(s.originId),onTap:()async{
              final v=await tgPicker<DemoPlace>(context,title:'Jo‘nash hududi',
                values:origins,label:(p)=>p.name);
              if(v!=null)ctrl.setOrigin(v.id);}),
          TgRow(icon:Icons.flag_outlined,title:'Borish manzili',
            subtitle:placeName(s.destinationId),onTap:()async{
              final v=await tgPicker<DemoPlace>(context,title:'Borish manzili',
                values:destinations,label:(p)=>p.name,subtitle:(p)=>p.subtitle);
              if(v!=null)ctrl.setDestination(v.id);}),
          TgRow(icon:Icons.place_outlined,title:'Olib ketish bekati',
            subtitle:s.pickup,onTap:()async{
              final v=await tgPicker<String>(context,title:'Olib ketish',values:pickupPoints,label:(p)=>p);
              if(v!=null)ctrl.setPickup(v);}),
          TgRow(icon:Icons.schedule_outlined,title:'Yetib borish vaqti',
            subtitle:s.arrivalTime,divider:false,onTap:()async{
              final now=TimeOfDay(hour:int.parse(s.arrivalTime.split(':')[0]),
                minute:int.parse(s.arrivalTime.split(':')[1]));
              final v=await showTimePicker(context:context,initialTime:now);
              if(v!=null)ctrl.setArrival('${v.hour.toString().padLeft(2,'0')}:${v.minute.toString().padLeft(2,'0')}');}),
          const SizedBox(height:14),SizedBox(width:double.infinity,
            child:FilledButton(onPressed:(){if(s.scheduleDays.isEmpty){
              tgMessage(context,'Kamida bir kunni belgilang.');return;}
              tgMessage(context,'Jadval saqlandi · demo');Navigator.pop(context);},
              child:const Text('Rejani saqlash'))),
        ])),const SizedBox(height:15),
        Text('Jadval o‘zgarishlari faqat xotiradagi mock holatga ta’sir qiladi.',
          style:TextStyle(color:context.secondaryInk,fontSize:12)),
      ]));
  }
}

class DemoTripDetails extends ConsumerWidget {
  final MockOffer offer;
  const DemoTripDetails({super.key,required this.offer});
  @override Widget build(BuildContext context,WidgetRef ref){
    final s=ref.watch(demoSessionProvider),driver=s.role==DemoRole.driver;
    final decision=s.decisions[offer.id]??DemoOfferStatus.pending;
    return Scaffold(appBar:AppBar(title:Text('Safar ${offer.id}')),
      body:TgPagePadding(children:[
        TgSurface(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Row(children:[TgAvatar(label:offer.driver,size:54),const SizedBox(width:12),
            Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Text(offer.driver,style:TextStyle(fontWeight:FontWeight.w700,fontSize:17,
                color:context.primaryInk)),Text('${vehicleFor(offer.vehicleId).model} · ★ ${offer.rating}',
                style:TextStyle(color:context.secondaryInk,fontSize:12))])),
            const TgBadge('Tekshirilgan',icon:Icons.verified_outlined)]),
          const SizedBox(height:20),
          _DetailLine(Icons.trip_origin_rounded,'Qayerdan',placeName(offer.originId)),
          _DetailLine(Icons.location_on_outlined,'Qayerga',placeName(offer.destinationId)),
          _DetailLine(Icons.pin_outlined,'Avtomobil raqami',offer.plate),
          _DetailLine(Icons.place_outlined,'Bekat',offer.pickup),
          _DetailLine(Icons.access_time_rounded,'Jo‘nash','${offer.date} · ${offer.departure}'),
          _DetailLine(Icons.groups_outlined,'Guruh','${offer.seats} yo‘lovchi'),
          const Divider(height:22),
          Row(children:[Expanded(child:Text('Bir kishi uchun',
            style:TextStyle(color:context.secondaryInk,fontSize:13))),
            Text('${offer.price} so‘m',style:TextStyle(color:context.accent,
              fontSize:20,fontWeight:FontWeight.w800))]),
          const SizedBox(height:16),
          if(driver)Row(children:[
            Expanded(child:FilledButton(onPressed:decision!=DemoOfferStatus.pending?null:(){
              ref.read(demoSessionProvider.notifier).decideOffer(offer.id,true);
              tgMessage(context,'Taklif qabul qilindi · demo');},child:const Text('Qabul qilish'))),
            const SizedBox(width:9),Expanded(child:OutlinedButton(
              onPressed:decision!=DemoOfferStatus.pending?null:()=>ref.read(demoSessionProvider.notifier)
                .decideOffer(offer.id,false),child:const Text('Rad etish'))),
          ]) else SizedBox(width:double.infinity,child:FilledButton(
            onPressed:(){ref.read(demoSessionProvider.notifier).confirmToday(true);
              ref.read(demoSessionProvider.notifier).confirmTrip();tgMessage(context,'Safar tasdiqlandi · demo');},
            child:const Text('Safarni tanlash · demo'))),
          if(decision!=DemoOfferStatus.pending&&driver)Padding(padding:const EdgeInsets.only(top:10),
            child:TgBadge(decision==DemoOfferStatus.accepted?'Qabul qilindi':'Rad etildi')),
        ])),
        const TgSectionTitle('Safar bekatlari'),
        TgSurface(child:Column(children:List.generate(4,(i)=>TgRow(
          leading:TgAvatar(label:'${i+1}',size:38,icon:Icons.location_on_outlined),
          title:i==0?offer.pickup:i==3?placeName(offer.destinationId):
            ['','Yo‘l bo‘yi bekati · namuna','Namangan kirish · namuna'][i],
          subtitle:'${10+i}:40 · namuna',divider:i!=3,
        )))),
        const SizedBox(height:12),Text('Transport va yo‘lovchilar haqida demo ma’lumotlar. '
          'Telefon raqamlari ko‘rsatilmaydi.',
          style:TextStyle(color:context.secondaryInk,fontSize:12)),
      ]));
  }
}
