import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/chat_policy.dart';
import 'mock_data.dart';

enum DemoRole { rider, driver }
enum DemoTripStatus { question, offered, confirmed, active, completed, declined }

enum DemoOfferStatus { pending, accepted, declined }

class DemoSession {
  final bool loggedIn;
  final DemoRole role;
  final String displayName, originId, destinationId, pickup, arrivalTime;
  final bool darkMode, womenOnly, quietRide, notificationsRead;
  final int tab, groupSize, rating;
  final DemoTripStatus tripStatus;
  final Set<int> scheduleDays;
  final Set<String> favorites;
  final Map<String, DemoOfferStatus> decisions;
  final Map<int,int> prices;
  final Set<String> pickedUp;
  final List<MockMessage> messages;

  const DemoSession({this.loggedIn = false, this.role = DemoRole.rider,
    this.displayName = 'Aziza', this.originId = 'kosonsoy',
    this.destinationId = 'yuksalish', this.pickup = 'Kosonsoy markazi',
    this.arrivalTime = '13:00', this.darkMode = false, this.womenOnly = false,
    this.quietRide = false, this.notificationsRead = false,
    this.tab=0, this.groupSize=8, this.rating=0,
    this.tripStatus=DemoTripStatus.question,
    this.scheduleDays=const {0,2}, this.favorites=const {'yuksalish','namdu'},
    this.decisions=const {}, this.pickedUp=const {},
    this.prices=const {3:32000,8:20000,14:19000,22:17000,28:15000},
    this.messages=initialMessages});

  DemoSession copy({bool? loggedIn, DemoRole? role, String? displayName,
    String? originId, String? destinationId, String? pickup, String? arrivalTime,
    bool? darkMode,bool? womenOnly,bool? quietRide,bool? notificationsRead,
    int? tab,int? groupSize,int? rating,DemoTripStatus? tripStatus,
    Set<int>? scheduleDays,Set<String>? favorites,
    Map<String,DemoOfferStatus>? decisions, Map<int,int>? prices,
    Set<String>? pickedUp,List<MockMessage>? messages}) => DemoSession(
      loggedIn:loggedIn??this.loggedIn,role:role??this.role,
      displayName:displayName??this.displayName,
      originId:originId??this.originId,destinationId:destinationId??this.destinationId,
      pickup:pickup??this.pickup,arrivalTime:arrivalTime??this.arrivalTime,
      darkMode:darkMode??this.darkMode,womenOnly:womenOnly??this.womenOnly,
      quietRide:quietRide??this.quietRide,
      notificationsRead:notificationsRead??this.notificationsRead,
      tab:tab??this.tab,groupSize:groupSize??this.groupSize,
      rating:rating??this.rating,tripStatus:tripStatus??this.tripStatus,
      scheduleDays:scheduleDays??this.scheduleDays,
      favorites:favorites??this.favorites,decisions:decisions??this.decisions,
      prices:prices??this.prices,pickedUp:pickedUp??this.pickedUp,
      messages:messages??this.messages);

  int get pendingOffers => mockOffers.where((offer) =>
    (decisions[offer.id]??DemoOfferStatus.pending)==DemoOfferStatus.pending).length;
  /// The preview uses a simulated clock: no device time or location is accessed.
  DateTime get demoStart => DateTime(2026,11,23,10,40);
  DateTime get demoEnd => DateTime(2026,11,23,12,15);
  DateTime get demoClock => tripStatus==DemoTripStatus.completed
      ? DateTime(2026,11,23,12,45)
      : tripStatus==DemoTripStatus.active
        ? DateTime(2026,11,23,11,5)
        : DateTime(2026,11,23,10,25);
  bool get canChat => (tripStatus==DemoTripStatus.confirmed ||
    tripStatus==DemoTripStatus.active ||
    tripStatus==DemoTripStatus.completed ||
    decisions.values.contains(DemoOfferStatus.accepted)) &&
    ChatPolicy.withinWindow(demoClock,demoStart,demoEnd);
  String get suggestedGroup => groupSize<=3?'Yengil':groupSize<=8?'Damas':'Avtobus';
  List<MockOffer> get matchingOffers => mockOffers.where((o)=>
    o.originId==originId || o.destinationId==destinationId).toList();
}

class DemoSessionController extends StateNotifier<DemoSession> {
  DemoSessionController():super(const DemoSession());
  void login(String name, DemoRole role) {
    final n=name.trim();
    state=state.copy(loggedIn:true,role:role,displayName:n.isEmpty?role==DemoRole.rider?'Aziza':'Sherzod':n,tab:0);
  }
  void logout()=>state=state.copy(loggedIn:false,tab:0);
  void setTab(int i) {if(i>=0&&i<4) state=state.copy(tab:i);}
  void setTheme(bool v)=>state=state.copy(darkMode:v);
  void setRole(DemoRole role)=>state=state.copy(role:role,tab:0);
  void setOrigin(String id) {if(origins.any((p)=>p.id==id)) state=state.copy(originId:id);}
  void setDestination(String id) {if(destinations.any((p)=>p.id==id)) state=state.copy(destinationId:id);}
  void setPickup(String v) {if(pickupPoints.contains(v)) state=state.copy(pickup:v);}
  void setArrival(String value) => state=state.copy(arrivalTime:value);
  void setGroupSize(int v) {if(v>=1&&v<=28) state=state.copy(groupSize:v);}
  void toggleDay(int day) {if(day<0||day>6)return; final d={...state.scheduleDays};
    if(!d.add(day))d.remove(day);state=state.copy(scheduleDays:d);}
  void toggleFavorite(String id) { final d={...state.favorites};
    if(!d.add(id))d.remove(id);state=state.copy(favorites:d);}
  void confirmToday(bool yes)=>state=state.copy(tripStatus:yes?DemoTripStatus.offered:DemoTripStatus.declined);
  void confirmTrip()=>state=state.copy(tripStatus:DemoTripStatus.confirmed);
  void declineTrip()=>state=state.copy(tripStatus:DemoTripStatus.declined);
  void startTrip()=>state=state.copy(tripStatus:DemoTripStatus.active);
  void finishTrip()=>state=state.copy(tripStatus:DemoTripStatus.completed);
  void rateTrip(int v){if(v>=1&&v<=5)state=state.copy(rating:v);}
  void resetJourney()=>state=state.copy(tripStatus:DemoTripStatus.question,rating:0);
  void decideOffer(String id,bool accept){if(!mockOffers.any((o)=>o.id==id))return;
    if((state.decisions[id]??DemoOfferStatus.pending)!=DemoOfferStatus.pending)return;
    state=state.copy(decisions:{...state.decisions,id:accept?DemoOfferStatus.accepted:DemoOfferStatus.declined});}
  void togglePickup(String key){final s={...state.pickedUp};if(!s.add(key))s.remove(key);
    state=state.copy(pickedUp:s);}
  String? updatePrice(int upperBound,int value){
    if(!state.prices.containsKey(upperBound))return 'Tarif topilmadi.';
    if(value<1000||value>500000)return 'Narx 1 000–500 000 so‘m oralig‘ida bo‘lsin.';
    state=state.copy(prices:{...state.prices,upperBound:value});return null;}
  void setWomenOnly(bool v)=>state=state.copy(womenOnly:v);
  void setQuietRide(bool v)=>state=state.copy(quietRide:v);
  void readNotifications()=>state=state.copy(notificationsRead:true);
  String? sendMessage(String body){
    if(!state.canChat)return 'Chat faqat demo safar tasdiqlangach ochiladi.';
    final value=body.trim();
    if(value.isEmpty)return 'Xabarni kiriting.';
    if(value.length>400)return 'Xabar juda uzun.';
    if(!ChatPolicy.permitted(value))return 'Telefon, @username yoki havola yuborish mumkin emas.';
    state=state.copy(messages:[...state.messages,MockMessage('Siz',value,'10:35')]);return null;
  }
  void reset()=>state=const DemoSession();
}

final demoSessionProvider=StateNotifierProvider<DemoSessionController,DemoSession>((ref)=>DemoSessionController());
