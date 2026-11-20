import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tg_theme.dart';
import 'tg_widgets.dart';
import 'demo_state.dart';
import 'mock_data.dart';

class TelegramProfilePage extends ConsumerWidget {
  const TelegramProfilePage({super.key});
  @override Widget build(BuildContext context,WidgetRef ref){
    final s=ref.watch(demoSessionProvider),ctrl=ref.read(demoSessionProvider.notifier);
    return TgPagePadding(children:[
      TgSurface(child:Row(children:[TgAvatar(label:s.displayName,size:64),
        const SizedBox(width:14),Expanded(child:Column(
          crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text(s.displayName,style:TextStyle(color:context.primaryInk,
              fontSize:19,fontWeight:FontWeight.w700)),const SizedBox(height:6),
            Text(s.role==DemoRole.rider?'Yo‘lovchi · test hisob':'Haydovchi · test hisob',
              style:TextStyle(color:context.secondaryInk,fontSize:12.5)),
            const SizedBox(height:6),const TgDemoLabel(),
          ]))])),
      const TgSectionTitle('Sozlamalar'),
      TgSurface(padding:const EdgeInsets.symmetric(horizontal:14),child:Column(children:[
        SwitchListTile(contentPadding:EdgeInsets.zero,
          secondary:Icon(s.darkMode?Icons.dark_mode_outlined:Icons.light_mode_outlined,
            color:context.accent),title:const Text('Tungi rejim'),
          subtitle:const Text('Telegram uslubidagi mavzuni almashtirish'),
          value:s.darkMode,onChanged:ctrl.setTheme),
        const Divider(height:1),
        TgRow(icon:Icons.notifications_outlined,title:'Bildirishnomalar',
          subtitle:'Mock ogohlantirishlar',onTap:()=>Navigator.push(context,
            MaterialPageRoute(builder:(_)=>const TelegramNotificationsPage()))),
        TgRow(icon:Icons.bookmark_border_rounded,title:'Saqlangan manzillar',
          subtitle:'${s.favorites.length} ta manzil',onTap:()=>ref.read(demoSessionProvider.notifier).setTab(1)),
        TgRow(icon:Icons.shield_outlined,title:'Xavfsizlik markazi',
          subtitle:'Maxfiylik va safar xavfsizligi · demo',divider:false,
          onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const DemoSafetyPage()))),
      ])),
      const TgSectionTitle('Safar afzalliklari'),
      TgSurface(padding:const EdgeInsets.symmetric(horizontal:14),child:Column(children:[
        SwitchListTile(contentPadding:EdgeInsets.zero,
          secondary:Icon(Icons.woman_outlined,color:context.accent),
          title:const Text('Faqat ayollar guruhi'),
          subtitle:const Text('Demo tanlov, haqiqiy filtr emas'),
          value:s.womenOnly,onChanged:ctrl.setWomenOnly),
        const Divider(height:1),
        SwitchListTile(contentPadding:EdgeInsets.zero,
          secondary:Icon(Icons.volume_off_outlined,color:context.accent),
          title:const Text('Tinch safar'),
          subtitle:const Text('Namoyish uchun afzallik'),
          value:s.quietRide,onChanged:ctrl.setQuietRide),
      ])),
      const TgSectionTitle('Demo vositalari'),
      TgSurface(padding:const EdgeInsets.symmetric(horizontal:14),child:Column(children:[
        TgRow(icon:Icons.swap_horiz_rounded,title:'Rejimni almashtirish',
          subtitle:'Yo‘lovchi ↔ haydovchi (test uchun)',
          onTap:()=>showModalBottomSheet<void>(context:context,
            builder:(c)=>SafeArea(child:Column(mainAxisSize:MainAxisSize.min,children:[
              ListTile(title:const Text('Yo‘lovchi'),leading:const Icon(Icons.person_outline),
                onTap:(){ctrl.setRole(DemoRole.rider);Navigator.pop(c);}),
              ListTile(title:const Text('Haydovchi'),leading:const Icon(Icons.drive_eta_outlined),
                onTap:(){ctrl.setRole(DemoRole.driver);Navigator.pop(c);}),
              const SizedBox(height:14)])))),
        TgRow(icon:Icons.restart_alt_rounded,title:'Mock ma’lumotni tiklash',
          subtitle:'Barcha vaqtinchalik tanlovlarni qaytaradi',
          onTap:()async{final reset=await showDialog<bool>(context:context,
            builder:(c)=>AlertDialog(title:const Text('Demoni tiklash?'),
              content:const Text('Jadval, chat, safar va tarifdagi o‘zgarishlar o‘chadi.'),
              actions:[TextButton(onPressed:()=>Navigator.pop(c,false),
                child:const Text('Yo‘q')),
                FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Tiklash'))]));
            if(reset==true){ctrl.reset();if(!context.mounted)return;tgMessage(context,'Demo holati tiklandi');}}),
        TgRow(icon:Icons.logout_rounded,title:'Demo hisobdan chiqish',
          subtitle:'Istalgan vaqtda qayta kirishingiz mumkin',divider:false,
          onTap:ctrl.logout),
      ])),
      const SizedBox(height:19),Text('AI Taksi · Telegram-inspired UI prototype\n'
        'Bu platforma Telegram bilan bog‘liq emas. Barcha safarlar sinov ma’lumoti.',
        style:TextStyle(color:context.secondaryInk,fontSize:11.5,height:1.6),textAlign:TextAlign.center),
    ]);
  }
}

class TelegramNotificationsPage extends ConsumerWidget {
  const TelegramNotificationsPage({super.key});
  @override Widget build(BuildContext context,WidgetRef ref){
    final read=ref.watch(demoSessionProvider).notificationsRead;
    const notes=<({String title,String body,String time,IconData icon})>[
      (title:'Yuksalish yo‘nalishi',body:'23-noyabr uchun yangi Damas taklifi',time:'09:42',icon:Icons.directions_car_outlined),
      (title:'Safarni tasdiqlang',body:'Bugun borasizmi? Javobingizni tanlang.',time:'Kecha',icon:Icons.event_available_outlined),
      (title:'Jadval eslatmasi',body:'Dushanba · 13:00 da NamDU kampusida bo‘lish rejangiz',time:'19 noy',icon:Icons.calendar_today_outlined),
      (title:'Yangi bekatlar',body:'Davlatobod va To‘raqo‘rg‘on · faqat demo',time:'18 noy',icon:Icons.place_outlined),
      (title:'Yangi transport turlari',body:'Cobalt, Damas, Sprinter va Yutong',time:'17 noy',icon:Icons.directions_bus_outlined),
      (title:'Xavfsizlik haqida',body:'Telefon raqamlari chatga joylanmaydi.',time:'15 noy',icon:Icons.shield_outlined),
      (title:'Baholash eslatmasi',body:'Oldingi safaringizni baholashingiz mumkin.',time:'12 noy',icon:Icons.star_border_rounded),
      (title:'Demo yangilandi',body:'Yangi yorug‘ va tungi dizayn tayyor.',time:'10 noy',icon:Icons.palette_outlined),
    ];
    return Scaffold(appBar:AppBar(title:const Text('Bildirishnomalar'),actions:[
      TextButton(onPressed:()=>ref.read(demoSessionProvider.notifier).readNotifications(),
        child:const Text('O‘qildi'))]),
      body:TgPagePadding(children:[
        const TgDemoLabel(),const SizedBox(height:12),
        TgSurface(padding:const EdgeInsets.symmetric(horizontal:14),
          child:Column(children:notes.map((n)=>TgRow(
            leading:TgAvatar(label:n.title,icon:n.icon,size:43,
              color:read?const Color(0xFF8996A5):null),
            title:n.title,subtitle:'${n.body} · ${n.time}',
            trailing:read?null:Container(width:8,height:8,decoration:BoxDecoration(
              color:context.accent,shape:BoxShape.circle)),
            onTap:()=>ref.read(demoSessionProvider.notifier).readNotifications())).toList())),
      ]));
  }
}

class DemoFleetPage extends ConsumerWidget {
  const DemoFleetPage({super.key});
  @override Widget build(BuildContext context,WidgetRef ref){
    final s=ref.watch(demoSessionProvider),ctrl=ref.read(demoSessionProvider.notifier);
    return Scaffold(appBar:AppBar(title:const Text('Avtopark · demo')),
      body:TgPagePadding(children:[
        TgSurface(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text('Guruhingizda nechta kishi?',style:TextStyle(color:context.primaryInk,
            fontWeight:FontWeight.w700,fontSize:16)),const SizedBox(height:12),
          Row(children:[IconButton.filledTonal(onPressed:s.groupSize>1?
            ()=>ctrl.setGroupSize(s.groupSize-1):null,icon:const Icon(Icons.remove)),
            Expanded(child:Column(children:[Text('${s.groupSize}',style:TextStyle(
              color:context.accent,fontSize:29,fontWeight:FontWeight.w800)),
              Text(s.suggestedGroup,style:TextStyle(color:context.secondaryInk,fontSize:12))])),
            IconButton.filledTonal(onPressed:s.groupSize<28?
              ()=>ctrl.setGroupSize(s.groupSize+1):null,icon:const Icon(Icons.add))]),
          const SizedBox(height:8),Text('Mos transport: 1–3 Yengil · 4–8 Damas · 9+ Avtobus',
            style:TextStyle(color:context.secondaryInk,fontSize:11.5)),
        ])),
        const TgSectionTitle('Transport variantlari'),
        ...mockVehicles.map((v){
          final suitable=v.group==s.suggestedGroup&&v.seats>=s.groupSize;
          return Padding(padding:const EdgeInsets.only(bottom:10),
            child:TgSurface(child:Row(children:[
              TgAvatar(label:v.model,size:53,icon:v.seats>8?Icons.directions_bus_outlined:
                Icons.directions_car_outlined),const SizedBox(width:12),
              Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                Text(v.model,style:TextStyle(color:context.primaryInk,fontWeight:FontWeight.w700)),
                const SizedBox(height:4),Text('${v.group} · ${v.seats} o‘rin · ★ ${v.rating}',
                  style:TextStyle(color:context.secondaryInk,fontSize:12)),
                const SizedBox(height:5),TgBadge(suitable?'Mos variant':v.note,
                  color:suitable?TgColors.green:context.secondaryInk),
              ])),const SizedBox(width:8),Column(crossAxisAlignment:CrossAxisAlignment.end,children:[
                Text('${v.fare ~/ 1000} 000',style:TextStyle(color:context.accent,
                  fontWeight:FontWeight.w800,fontSize:15)),
                Text('so‘m / kishi',style:TextStyle(color:context.secondaryInk,fontSize:10.5)),
              ])])));
        }),
        const SizedBox(height:14),Text('Bu narxlar va o‘rinlar real mavjudlikni bildir­maydi. '
          'Backendda uchta asosiy avtomobil toifasi mavjud.',
          style:TextStyle(color:context.secondaryInk,fontSize:11.5,height:1.5)),
      ]));
  }
}

class DemoSafetyPage extends ConsumerWidget {
  const DemoSafetyPage({super.key});
  @override Widget build(BuildContext context,WidgetRef ref)=>Scaffold(
    appBar:AppBar(title:const Text('Xavfsizlik markazi')),
    body:TgPagePadding(children:[
      TgSurface(child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const TgAvatar(label:'!',size:51,icon:Icons.verified_user_outlined,
          color:TgColors.blue),const SizedBox(width:12),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Text('Xavfsizlik birinchi o‘rinda',
            style:TextStyle(fontSize:16,fontWeight:FontWeight.w700)),
          const SizedBox(height:6),Text('Haydovchilarni tekshirish, maskali aloqa va '
            'safar monitoringi konsepsiya hisoblanadi.',
            style:TextStyle(color:context.secondaryInk,fontSize:12.5,height:1.5))]))])),
      const TgSectionTitle('Himoya funksiyalari'),
      TgSurface(padding:const EdgeInsets.symmetric(horizontal:14),child:Column(children:[
        TgRow(icon:Icons.phone_disabled_outlined,title:'Telefon raqami yashirin',
          subtitle:'Chatdagi raqam va @username bloklanadi · demo'),
        TgRow(icon:Icons.verified_user_outlined,title:'Haydovchini tekshirish',
          subtitle:'Real tizimda admin tekshirishi kerak'),
        TgRow(icon:Icons.share_location_outlined,title:'Safarni ulashish',
          subtitle:'Havola yuborilmaydi · faqat ko‘rinish',
          onTap:()=>_information(context,'Safarni ulashish',
            'Bu demo haqiqiy manzil yoki kuzatuv havolasini ulashmaydi.')),
        TgRow(icon:Icons.sos_outlined,title:'SOS yordam',
          subtitle:'Haqiqiy favqulodda signal yuborilmaydi',divider:false,
          onTap:()=>_information(context,'SOS · demo',
            'Ushbu tugma yordam xizmatlariga murojaat qilmaydi. '
            'Favqulodda vaziyatda mahalliy tezkor xizmat bilan bevosita bog‘laning.')),
      ])),
    ]));
  void _information(BuildContext c,String title,String message)=>showDialog<void>(
    context:c,builder:(ctx)=>AlertDialog(title:Text(title),content:Text(message),
    actions:[FilledButton(onPressed:()=>Navigator.pop(ctx),child:const Text('Tushunarli'))]));
}

class DemoTripChatPage extends ConsumerStatefulWidget {
  const DemoTripChatPage({super.key});
  @override ConsumerState<DemoTripChatPage> createState()=>_DemoTripChatPageState();
}
class _DemoTripChatPageState extends ConsumerState<DemoTripChatPage> {
  final field = TextEditingController();
  final scroll = ScrollController();

  @override void dispose() {
    field.dispose();
    scroll.dispose();
    super.dispose();
  }

  void send() {
    final issue = ref.read(demoSessionProvider.notifier).sendMessage(field.text);
    if(issue != null) {
      tgMessage(context,issue);
      return;
    }
    field.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(scroll.hasClients) {
        scroll.animateTo(scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 230),curve: Curves.easeOut);
      }
    });
  }

  @override Widget build(BuildContext context) {
    final session = ref.watch(demoSessionProvider);
    return Scaffold(
      appBar: AppBar(title: Row(children: [
        const TgAvatar(label:'Sherzod',size:39),
        const SizedBox(width:10),
        Expanded(child: Column(crossAxisAlignment:CrossAxisAlignment.start,children: [
          Text('Safar guruhi',style: TextStyle(fontSize:16,
            fontWeight:FontWeight.w700,color:context.primaryInk)),
          Text('8 ishtirokchi · offline demo',
            style:TextStyle(fontSize:11.5,color:context.secondaryInk)),
        ])),
      ])),
      body: Column(children: [
        Container(
          color:context.softBlue,width:double.infinity,
          padding: const EdgeInsets.symmetric(horizontal:14,vertical:10),
          child:Row(children: [
            Icon(Icons.lock_outline,size:17,color:context.accent),
            const SizedBox(width:8),
            Expanded(child:Text('Raqamlar, @username va havolalar taqiqlangan. Demo chat.',
              style:TextStyle(color:context.primaryInk,fontSize:11.5))),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            controller:scroll,
            padding: const EdgeInsets.fromLTRB(13,18,13,12),
            itemCount:session.messages.length + 1,
            itemBuilder:(ctx,i) {
              if(i==0) { return Center(child:Padding(
                padding:const EdgeInsets.only(bottom:17),
                child:TgBadge('23 NOV · DEMO',color:context.secondaryInk))); }
              final message=session.messages[i-1];
              final mine=message.author=='Siz'||message.author==session.displayName||
                message.author=='Aziza';
              return _ChatBubble(message:message,mine:mine);
            },
          ),
        ),
        ColoredBox(
          color: context.pageSurface,
          child: SafeArea(
            top:false,
            child:Padding(
              padding:const EdgeInsets.fromLTRB(10,7,10,10),
              child:Row(children: [
                Expanded(child:TextField(
                  controller:field,maxLength:400,maxLines:1,
                  textInputAction:TextInputAction.send,onSubmitted:(_)=>send(),
                  decoration:InputDecoration(
                    hintText:session.canChat ? 'Xabar yozing...' : 'Chat safar tasdiqlangach ochiladi',
                    counterText:'',
                    prefixIcon:const Icon(Icons.chat_bubble_outline_rounded),
                  ),
                )),
                const SizedBox(width:8),
                IconButton.filled(
                  onPressed:session.canChat ? send : null,
                  icon:const Icon(Icons.send_rounded),
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final MockMessage message;
  final bool mine;
  const _ChatBubble({required this.message,required this.mine});
  @override Widget build(BuildContext context) {
    return Align(
      alignment:mine ? Alignment.centerRight:Alignment.centerLeft,
      child:ConstrainedBox(
        constraints:BoxConstraints(maxWidth:MediaQuery.sizeOf(context).width*.79),
        child:Container(
          margin:const EdgeInsets.only(bottom:9),
          padding:const EdgeInsets.fromLTRB(12,10,12,9),
          decoration:BoxDecoration(
            color:mine
              ? (context.isNight ? const Color(0xFF28527A) : const Color(0xFFE2FFC7))
              : context.pageSurface,
            borderRadius:BorderRadius.only(
              topLeft:const Radius.circular(14),topRight:const Radius.circular(14),
              bottomLeft:Radius.circular(mine ? 14:3),
              bottomRight:Radius.circular(mine ? 3:14),
            ),
          ),
          child:Column(crossAxisAlignment:CrossAxisAlignment.start,children: [
            if(!mine)Text(message.author,style:TextStyle(
              color:context.accent,fontSize:11.5,fontWeight:FontWeight.w700)),
            if(!mine)const SizedBox(height:4),
            Text(message.body,style:TextStyle(color:context.primaryInk,
              fontSize:13.5,height:1.4)),
            const SizedBox(height:4),
            Align(alignment:Alignment.centerRight,
              child:Text(message.time,style:TextStyle(color:context.secondaryInk,
                fontSize:10))),
          ]),
        ),
      ),
    );
  }
}
