import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tg_theme.dart';
import 'tg_widgets.dart';
import 'demo_state.dart';
import 'mock_data.dart';
import 'rider_pages.dart';
import 'driver_pages.dart';
import 'more_pages.dart';

class AITaksiTelegramApp extends ConsumerWidget {
  const AITaksiTelegramApp({super.key});
  @override Widget build(BuildContext context,WidgetRef ref){
    final session=ref.watch(demoSessionProvider);
    final dark=session.darkMode;
    final barColor=dark?TgColors.darkSurface:Colors.white;
    final barStyle=SystemUiOverlayStyle(
      statusBarColor:Colors.transparent,
      statusBarIconBrightness:dark?Brightness.light:Brightness.dark,
      statusBarBrightness:dark?Brightness.dark:Brightness.light,
      systemNavigationBarColor:barColor,
      systemNavigationBarDividerColor:barColor,
      systemNavigationBarIconBrightness:dark?Brightness.light:Brightness.dark,
      systemNavigationBarContrastEnforced:false);
    SystemChrome.setSystemUIOverlayStyle(barStyle);
    return AnnotatedRegion<SystemUiOverlayStyle>(value:barStyle,
      child:MaterialApp(debugShowCheckedModeBanner:false,
        title:'AI Taksi',locale:const Locale('uz'),
        supportedLocales:const [Locale('uz'),Locale('ru'),Locale('en')],
        localizationsDelegates:const [GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,GlobalWidgetsLocalizations.delegate],
        theme:tgTheme(),darkTheme:tgTheme(dark:true),
        themeMode:dark?ThemeMode.dark:ThemeMode.light,
        home:session.loggedIn?const TelegramShell():const MockLoginPage()));
  }
}

class MockLoginPage extends ConsumerStatefulWidget {
  const MockLoginPage({super.key});
  @override ConsumerState<MockLoginPage> createState()=>_MockLoginPageState();
}
class _MockLoginPageState extends ConsumerState<MockLoginPage> {
  DemoRole role=DemoRole.rider;
  final name=TextEditingController(text:'Aziza');
  final code=TextEditingController();
  bool codeShown=false;
  @override void dispose(){name.dispose();code.dispose();super.dispose();}
  void enter(){
    if(codeShown&&code.text.trim()!='123456'){
      tgMessage(context,'Demo kod: 123456');return;
    }
    ref.read(demoSessionProvider.notifier).login(name.text,role);
  }
  @override Widget build(BuildContext context){
    final night=ref.watch(demoSessionProvider).darkMode;
    return Scaffold(body:SafeArea(child:Center(child:ConstrainedBox(
      constraints:const BoxConstraints(maxWidth:480),
      child:ListView(padding:const EdgeInsets.symmetric(horizontal:25,vertical:20),children:[
        Align(alignment:Alignment.centerRight,child:IconButton(
          tooltip:'Tungi/yorug‘ mavzu',onPressed:()=>ref.read(demoSessionProvider.notifier).setTheme(!night),
          icon:Icon(night?Icons.light_mode_outlined:Icons.dark_mode_outlined))),
        const SizedBox(height:12),
        Center(child:Container(width:108,height:108,clipBehavior:Clip.antiAlias,
          decoration:BoxDecoration(borderRadius:BorderRadius.circular(28),
            boxShadow:[BoxShadow(color:context.accent.withValues(alpha:.18),blurRadius:24,offset:const Offset(0,8))]),
          child:Image.asset('assets/images/app_logo.png',fit:BoxFit.cover))),
        const SizedBox(height:24),
        Text('AI Taksi',textAlign:TextAlign.center,style:TextStyle(
          fontSize:29,fontWeight:FontWeight.w800,letterSpacing:-.7,color:context.primaryInk)),
        const SizedBox(height:8),
        Text('Bir yo‘lda — birga, yanada qulay.',textAlign:TextAlign.center,
          style:TextStyle(fontSize:14.5,color:context.secondaryInk)),
        const SizedBox(height:15),const Center(child:TgDemoLabel()),
        const SizedBox(height:24),
        TgSurface(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Text('Demo hisobingiz',style:TextStyle(fontWeight:FontWeight.w700,fontSize:17)),
          const SizedBox(height:8),Text('SMS yuborilmaydi, haqiqiy akkaunt kerak emas.',
            style:TextStyle(fontSize:12.5,color:context.secondaryInk)),
          const SizedBox(height:17),
          Row(children:[Expanded(child:_RoleTile(label:'Yo‘lovchi',icon:Icons.person_outline_rounded,
            selected:role==DemoRole.rider,onTap:(){setState((){role=DemoRole.rider;
              name.text='Aziza';codeShown=false;code.clear();});})),
            const SizedBox(width:11),
            Expanded(child:_RoleTile(label:'Haydovchi',icon:Icons.drive_eta_outlined,
              selected:role==DemoRole.driver,onTap:(){setState((){role=DemoRole.driver;
                name.text='Sherzod';codeShown=false;code.clear();});}))]),
          const SizedBox(height:18),
          TextField(controller:name,textCapitalization:TextCapitalization.words,
            decoration:const InputDecoration(labelText:'Ismingiz',prefixIcon:Icon(Icons.person_outline_rounded))),
          if(codeShown)...[
            const SizedBox(height:12),
            TextField(controller:code,keyboardType:TextInputType.number,
              maxLength:6,inputFormatters:[FilteringTextInputFormatter.digitsOnly],
              decoration:const InputDecoration(labelText:'Demo SMS kod',hintText:'123456',
                prefixIcon:Icon(Icons.lock_outline_rounded),counterText:'')),
            const SizedBox(height:5),const TgBadge('Sinov kodi: 123456',icon:Icons.verified_outlined),
          ],
          const SizedBox(height:17),
          SizedBox(width:double.infinity,child:FilledButton.icon(
            onPressed:enter,icon:const Icon(Icons.arrow_forward_rounded),
            label:Text(codeShown?'Kod orqali kirish':'Demo sifatida kirish'))),
          const SizedBox(height:7),
          Center(child:TextButton(onPressed:()=>setState(()=>codeShown=!codeShown),
            child:Text(codeShown?'Tez kirishga qaytish':'SMS kod kirishini sinab ko‘rish'))),
        ])),
        const SizedBox(height:20),
        Text('Bu test versiyasi. Haqiqiy taksi buyurtmasi, SMS yoki to‘lov yo‘q.',
          textAlign:TextAlign.center,style:TextStyle(color:context.secondaryInk,
            height:1.5,fontSize:11.8)),
      ])))));
  }
}

class _RoleTile extends StatelessWidget {
  final String label;final IconData icon;final bool selected;final VoidCallback onTap;
  const _RoleTile({required this.label,required this.icon,required this.selected,required this.onTap});
  @override Widget build(BuildContext context)=>InkWell(onTap:onTap,
    borderRadius:BorderRadius.circular(13),child:AnimatedContainer(
      duration:const Duration(milliseconds:180),padding:const EdgeInsets.symmetric(vertical:16),
      decoration:BoxDecoration(borderRadius:BorderRadius.circular(13),
        color:selected?context.softBlue:context.pageCanvas,
        border:Border.all(color:selected?context.accent:context.quietLine,width:selected?1.5:1)),
      child:Column(children:[Icon(icon,color:selected?context.accent:context.secondaryInk,size:26),
        const SizedBox(height:7),Text(label,style:TextStyle(color:selected?context.accent:
          context.primaryInk,fontWeight:FontWeight.w700,fontSize:13))])));
}

class TelegramShell extends ConsumerWidget {
  const TelegramShell({super.key});
  @override Widget build(BuildContext context,WidgetRef ref){
    final s=ref.watch(demoSessionProvider),driver=s.role==DemoRole.driver;
    final labels=driver?const ['Asosiy','Takliflar','Tariflar','Profil']:
      const ['Asosiy','Yo‘nalishlar','Safarlar','Profil'];
    final icons=driver?const <IconData>[Icons.grid_view_outlined,Icons.directions_car_outlined,
      Icons.payments_outlined,Icons.person_outline_rounded]:
      const <IconData>[Icons.home_outlined,Icons.location_on_outlined,
        Icons.confirmation_number_outlined,Icons.person_outline_rounded];
    final activeIcons=driver?const <IconData>[Icons.grid_view_rounded,Icons.directions_car_filled,
      Icons.payments_rounded,Icons.person_rounded]:
      const <IconData>[Icons.home_rounded,Icons.location_on_rounded,
        Icons.confirmation_number_rounded,Icons.person_rounded];
    final children=driver?const <Widget>[DriverDashboard(),DriverOffersPage(),
      DriverTariffsPage(),TelegramProfilePage()]:
      const <Widget>[RiderDashboard(),DestinationPage(),RiderTripsPage(),TelegramProfilePage()];
    final topName=driver?const ['Boshqaruv','Safar takliflari','Mening tariflarim','Profil']:
      const ['AI Taksi','Yo‘nalishlar','Mening safarlarim','Profil'];
    return Scaffold(
      appBar:AppBar(title:Row(children:[
        if(s.tab==0)...[ClipRRect(
          borderRadius:BorderRadius.circular(10),
          child:Image.asset('assets/images/app_logo.png',width:36,height:36,fit:BoxFit.cover)),
          const SizedBox(width:11)],
        Expanded(child:Text(topName[s.tab],maxLines:1,overflow:TextOverflow.ellipsis)),
        const SizedBox(width:4),
        const TgBadge('DEMO'),
      ]),actions:[
        if(!driver&&s.tab==0)IconButton(tooltip:'Yo‘nalishlarni qidirish',
          onPressed:()=>ref.read(demoSessionProvider.notifier).setTab(1),
          icon:const Icon(Icons.search_rounded)),
        IconButton(tooltip:'Bildirishnomalar',onPressed:()=>Navigator.push(context,
          MaterialPageRoute(builder:(_)=>const TelegramNotificationsPage())),
          icon:Badge(isLabelVisible:!s.notificationsRead,smallSize:7,
            child:const Icon(Icons.notifications_none_rounded))),
      ],bottom:PreferredSize(preferredSize:const Size.fromHeight(1),
        child:Divider(height:1,color:context.quietLine))),
      body:IndexedStack(index:s.tab,children:children),
      bottomNavigationBar: _TelegramBottomNav(
        labels: labels,
        icons: icons,
        activeIcons: activeIcons,
        selectedTab: s.tab,
        pendingOffers: driver ? s.pendingOffers : 0,
        onChange: (i) => ref.read(demoSessionProvider.notifier).setTab(i),
      ),
    );
  }
}


class _TelegramBottomNav extends StatelessWidget {
  final List<String> labels;
  final List<IconData> icons;
  final List<IconData> activeIcons;
  final int selectedTab, pendingOffers;
  final ValueChanged<int> onChange;
  const _TelegramBottomNav({
    required this.labels, required this.icons,required this.activeIcons,
    required this.selectedTab,required this.pendingOffers,required this.onChange,
  });
  @override Widget build(BuildContext context) {
    return ColoredBox(
      color: context.pageSurface,
      child: SafeArea(
        top: false,
        maintainBottomViewPadding: true,
        child: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: context.quietLine,width:.8)),
          ),
          padding: const EdgeInsets.only(top:5,bottom:4),
          child: Row(children: List.generate(labels.length,(i) {
            final selected = selectedTab == i;
            return Expanded(
              child: InkWell(
                onTap: () => onChange(i),
                child: Semantics(
                  button: true, selected: selected, label: labels[i],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical:5),
                    child: Column(mainAxisSize:MainAxisSize.min, children: [
                      Badge(
                        isLabelVisible: i == 1 && pendingOffers > 0,
                        label: Text('$pendingOffers'),
                        child: Icon(selected ? activeIcons[i] : icons[i],
                          color: selected ? context.accent : context.secondaryInk,
                          size:23),
                      ),
                      const SizedBox(height:4),
                      Text(labels[i],style: TextStyle(
                        color: selected ? context.accent : context.secondaryInk,
                        fontSize:10.5,
                        fontWeight: selected ? FontWeight.w700:FontWeight.w500,
                      )),
                    ]),
                  ),
                ),
              ),
            );
          })),
        ),
      ),
    );
  }
}
