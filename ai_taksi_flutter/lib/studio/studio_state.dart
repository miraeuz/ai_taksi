import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/chat_policy.dart';
import 'mock_catalog.dart';

/// Fictional, local-only pilot data. No HTTP, location tracking or accounts.
const pilotStops = <String>[
  'Kosonsoy markazi',
  'Kosonsoy bozori',
  'Kosonsoy janub',
  'Yo‘l bo‘yi 1',
  'Yo‘l bo‘yi 2',
  'Namangan kirish',
];
const weekdayLabels = <String>['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];

enum StudioRole { passenger, driver }
enum RideProgress { question, offered, booked, riding, completed, skipped }
enum OfferDecision { waiting, accepted, declined }

class DemoOffer {
  final int id;
  final String route, pickupTime, vehicle, pickup;
  final int passengers, stops, minutesToRespond;
  const DemoOffer({required this.id, required this.route,
    required this.pickupTime, required this.vehicle, required this.pickup,
    required this.passengers, required this.stops,
    required this.minutesToRespond});
}

const sampleOffers = <DemoOffer>[
  DemoOffer(id: 101, route: 'Kosonsoy → NamSU', pickupTime: '10:40',
    vehicle: 'Damas', pickup: 'Kosonsoy markazi', passengers: 8,
    stops: 3, minutesToRespond: 5),
  DemoOffer(id: 102, route: 'Kosonsoy → Namangan', pickupTime: '16:20',
    vehicle: 'Damas', pickup: 'Kosonsoy bozori', passengers: 6,
    stops: 2, minutesToRespond: 8),
  DemoOffer(id: 103, route: 'Kosonsoy → NamSU', pickupTime: '08:15',
    vehicle: 'Sprinter', pickup: 'Kosonsoy janub', passengers: 12,
    stops: 4, minutesToRespond: 12),
  DemoOffer(id: 104, route: 'NamSU → Kosonsoy', pickupTime: '17:40',
    vehicle: 'Cobalt', pickup: 'Namangan kirish', passengers: 3,
    stops: 2, minutesToRespond: 6),
  DemoOffer(id: 105, route: 'Kosonsoy → Namangan', pickupTime: '07:10',
    vehicle: 'Avtobus', pickup: 'Kosonsoy markazi', passengers: 22,
    stops: 6, minutesToRespond: 10),
];

class DemoChatMessage {
  final String from, text, time;
  const DemoChatMessage(this.from, this.text, this.time);
}

class StudioState {
  final StudioRole role;
  final int tab;
  final RideProgress ride;
  final Set<int> scheduleDays;
  final String pickup, arrivalTime, direction;
  final int rating;
  final Map<int, int> priceBands;
  final Map<int, OfferDecision> offerDecisions;
  final Set<int> pickedUpStops;
  final List<DemoChatMessage> messages;
  final bool notificationsRead;
  final int? selectedOffer;
  final String selectedVehicle;
  final Set<String> favoriteVehicles;
  final int groupSize;
  final bool womenOnly;
  final bool quietRide;

  const StudioState({
    this.role = StudioRole.passenger, this.tab = 0,
    this.ride = RideProgress.question,
    this.scheduleDays = const {0, 2},
    this.pickup = 'Kosonsoy markazi', this.arrivalTime = '13:00',
    this.direction = 'Kosonsoy → NamSU',
    this.rating = 0,
    this.priceBands = const {3: 30000, 7: 25000, 8: 20000, 14: 18000, 28: 15000},
    this.offerDecisions = const {},
    this.pickedUpStops = const {},
    this.messages = const [
      DemoChatMessage('Sherzod', 'Assalomu alaykum! Bekatga yaqinlashyapman.', '10:31'),
      DemoChatMessage('Aziza', 'Rahmat, belgilangan joydaman.', '10:32'),
    ],
    this.notificationsRead = false,
    this.selectedOffer,
    this.selectedVehicle = 'damas',
    this.favoriteVehicles = const {'damas'},
    this.groupSize = 8,
    this.womenOnly = false,
    this.quietRide = false,
  });

  StudioState copyWith({StudioRole? role, int? tab, RideProgress? ride,
    Set<int>? scheduleDays, String? pickup, String? arrivalTime,
    String? direction, int? rating, Map<int,int>? priceBands,
    Map<int,OfferDecision>? offerDecisions, Set<int>? pickedUpStops,
    List<DemoChatMessage>? messages, bool? notificationsRead,
    int? selectedOffer, bool clearSelectedOffer = false,
    String? selectedVehicle, Set<String>? favoriteVehicles,
    int? groupSize, bool? womenOnly, bool? quietRide}) => StudioState(
    role: role ?? this.role, tab: tab ?? this.tab, ride: ride ?? this.ride,
    scheduleDays: scheduleDays ?? this.scheduleDays,
    pickup: pickup ?? this.pickup, arrivalTime: arrivalTime ?? this.arrivalTime,
    direction: direction ?? this.direction, rating: rating ?? this.rating,
    priceBands: priceBands ?? this.priceBands,
    offerDecisions: offerDecisions ?? this.offerDecisions,
    pickedUpStops: pickedUpStops ?? this.pickedUpStops,
    messages: messages ?? this.messages,
    notificationsRead: notificationsRead ?? this.notificationsRead,
    selectedOffer: clearSelectedOffer ? null : selectedOffer ?? this.selectedOffer,
    selectedVehicle: selectedVehicle ?? this.selectedVehicle,
    favoriteVehicles: favoriteVehicles ?? this.favoriteVehicles,
    groupSize: groupSize ?? this.groupSize, womenOnly: womenOnly ?? this.womenOnly,
    quietRide: quietRide ?? this.quietRide,
  );

  int get offeredCount => sampleOffers.where((o) =>
      (offerDecisions[o.id] ?? OfferDecision.waiting) == OfferDecision.waiting).length;
  int get riderFare => 20000;
  int priceFor(int passengers) => priceBands[passengers <= 3 ? 3
      : passengers <= 7 ? 7 : passengers <= 8 ? 8
      : passengers <= 14 ? 14 : 28] ?? 20000;
  DemoVehicle get chosenVehicle => vehicleById(selectedVehicle);
  VehicleKind get requiredKind => groupSize <= 3 ? VehicleKind.yengil
      : groupSize <= 8 ? VehicleKind.damas : VehicleKind.avtobus;
  List<DemoVehicle> get suitableVehicles => demoVehicles
      .where((vehicle) => vehicle.seats >= groupSize && vehicle.kind == requiredKind).toList()
        ..sort((a, b) => a.estimateFor(groupSize).compareTo(b.estimateFor(groupSize)));
  /// The clock is simulated so the demo works independently of today's date.
  DateTime get demoTripStart => DateTime(2026, 11, 23, 10, 40);
  DateTime get demoTripEnd => DateTime(2026, 11, 23, 12, 15);
  DateTime get demoNow => ride == RideProgress.completed
      ? DateTime(2026, 11, 23, 12, 45)
      : ride == RideProgress.riding
        ? DateTime(2026, 11, 23, 11, 5)
        : DateTime(2026, 11, 23, 10, 20);
  bool get canChat => (ride == RideProgress.booked ||
      ride == RideProgress.riding || ride == RideProgress.completed ||
      offerDecisions.values.contains(OfferDecision.accepted)) &&
      ChatPolicy.withinWindow(demoNow, demoTripStart, demoTripEnd);
}

class StudioController extends StateNotifier<StudioState> {
  StudioController(): super(const StudioState());
  StudioState get snapshot => state;

  void switchRole(StudioRole role) => state = state.copyWith(role: role, tab: 0);
  void tab(int index) { if (index >= 0 && index < 4) state = state.copyWith(tab: index); }
  void going(bool yes) => state = state.copyWith(ride: yes ? RideProgress.offered : RideProgress.skipped);
  void acceptRide() { if (state.ride == RideProgress.offered) state = state.copyWith(ride: RideProgress.booked); }
  void declineRide() { if (state.ride == RideProgress.offered) state = state.copyWith(ride: RideProgress.skipped); }
  void startRide() { if (state.ride == RideProgress.booked) state = state.copyWith(ride: RideProgress.riding); }
  void finishRide() { if (state.ride == RideProgress.riding) state = state.copyWith(ride: RideProgress.completed); }
  void rate(int stars) { if (state.ride == RideProgress.completed && stars >= 1 && stars <= 5) state = state.copyWith(rating: stars); }

  String? saveSchedule(Set<int> days, String pickup, String time, String direction) {
    if (days.isEmpty) return 'Kamida bitta kunni tanlang.';
    if (!pilotStops.contains(pickup)) return 'Bekatni ro‘yxatdan tanlang.';
    if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(time)) return 'Vaqtni tekshiring.';
    state = state.copyWith(scheduleDays: Set.of(days), pickup: pickup,
      arrivalTime: time, direction: direction);
    return null;
  }

  void selectOffer(int id) { if (sampleOffers.any((o) => o.id == id)) state = state.copyWith(selectedOffer: id); }
  void decideOffer(int id, bool accept) {
    if (!sampleOffers.any((o) => o.id == id)) return;
    if ((state.offerDecisions[id] ?? OfferDecision.waiting) != OfferDecision.waiting) return;
    state = state.copyWith(offerDecisions: {...state.offerDecisions,
      id: accept ? OfferDecision.accepted : OfferDecision.declined}, selectedOffer: id);
  }
  void markPickup(int index, {int? offerId}) {
    final offer = offerId == null ? null : sampleOffers.where((o) => o.id == offerId);
    final count = offer == null || offer.isEmpty ? 3 : offer.first.stops;
    if (index < 0 || index >= count) return;
    // Namespaced keys prevent two different offers sharing the same pickup state.
    final key = offerId == null ? index : offerId * 100 + index;
    final current = {...state.pickedUpStops};
    if (!current.add(key)) current.remove(key);
    state = state.copyWith(pickedUpStops: current);
  }
  String? updatePrice(int upperBound, int price) {
    if (!state.priceBands.containsKey(upperBound)) return 'Narx toifasi topilmadi.';
    if (price < 1000 || price > 500000) return 'Narx 1 000–500 000 so‘m bo‘lishi kerak.';
    state = state.copyWith(priceBands: {...state.priceBands, upperBound: price});
    return null;
  }
  void readNotifications() => state = state.copyWith(notificationsRead: true);
  void selectVehicle(String id) {
    final match = demoVehicles.where((v) => v.id == id);
    if (match.isNotEmpty && match.first.seats >= state.groupSize &&
        match.first.kind == state.requiredKind) {
      state = state.copyWith(selectedVehicle: id);
    }
  }
  void toggleFavorite(String id) {
    if (!demoVehicles.any((v) => v.id == id)) return;
    final next = {...state.favoriteVehicles};
    if (!next.add(id)) next.remove(id);
    state = state.copyWith(favoriteVehicles: next);
  }
  void setGroupSize(int size) {
    if (size < 1 || size > 28) return;
    final kind = size <= 3 ? VehicleKind.yengil : size <= 8 ? VehicleKind.damas : VehicleKind.avtobus;
    final current = vehicleById(state.selectedVehicle);
    final nextVehicle = current.seats >= size && current.kind == kind
        ? current.id
        : demoVehicles.firstWhere((v) => v.seats >= size && v.kind == kind).id;
    state = state.copyWith(groupSize: size, selectedVehicle: nextVehicle);
  }
  void updateRidePrefs({bool? womenOnly, bool? quietRide}) => state = state.copyWith(
    womenOnly: womenOnly, quietRide: quietRide); 

  /// Simulated clock is deliberately inside the trip's allowed window.
  /// In production the server MUST enforce the actual UTC trip window.
  String? sendMessage(String input) {
    if (!state.canChat) return 'Chat faqat tasdiqlangan safarda ochiladi.';
    final trimmed = input.trim();
    if (!ChatPolicy.permitted(trimmed)) return 'Telefon, @username va havola yuborish mumkin emas.';
    if (trimmed.length > 400) return 'Xabar 400 belgidan oshmasin.';
    state = state.copyWith(messages: [
      ...state.messages, DemoChatMessage('Siz', trimmed, '10:35'),
    ]);
    return null;
  }
  void reset() => state = const StudioState();
}

final studioProvider = StateNotifierProvider<StudioController, StudioState>(
    (ref) => StudioController());
