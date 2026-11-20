import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/chat_policy.dart';

// Entirely local demonstration data. No personal data or network side effects.
const pilotStops = <String>[
  'Kosonsoy markazi', 'Kosonsoy bozori', 'Kosonsoy janub',
  'Yo‘l bo‘yi 1', 'Yo‘l bo‘yi 2', 'Namangan kirish',
];
const weekDays = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];

enum RideStage { awaitingAnswer, searching, offered, confirmed, active, completed, declined }
enum DemoRole { rider, driver }

class DemoMessage {
  final String author, body;
  final DateTime createdAt;
  const DemoMessage(this.author, this.body, this.createdAt);
}

class DemoState {
  final DemoRole role;
  final RideStage stage;
  final Set<int> days;
  final String pickup;
  final String arriveBy;
  final String direction;
  final bool driverAccepted;
  final bool driverDeclined;
  final int rating;
  final int price;
  final int activeTab;
  final List<DemoMessage> messages;
  const DemoState({
    this.role = DemoRole.rider,
    this.stage = RideStage.awaitingAnswer,
    this.days = const {0, 2},
    this.pickup = 'Kosonsoy markazi',
    this.arriveBy = '13:00',
    this.direction = 'Kosonsoy → NamSU',
    this.driverAccepted = false,
    this.driverDeclined = false,
    this.rating = 0,
    this.price = 20000,
    this.activeTab = 0,
    this.messages = const [],
  });
  DemoState copyWith({DemoRole? role, RideStage? stage, Set<int>? days,
    String? pickup, String? arriveBy, String? direction, bool? driverAccepted, bool? driverDeclined,
    int? rating, int? price, int? activeTab, List<DemoMessage>? messages}) => DemoState(
    role: role ?? this.role, stage: stage ?? this.stage, days: days ?? this.days,
    pickup: pickup ?? this.pickup, arriveBy: arriveBy ?? this.arriveBy,
    direction: direction ?? this.direction, driverAccepted: driverAccepted ?? this.driverAccepted, driverDeclined: driverDeclined ?? this.driverDeclined,
    rating: rating ?? this.rating, price: price ?? this.price, activeTab: activeTab ?? this.activeTab,
    messages: messages ?? this.messages,
  );
}

class DemoController extends StateNotifier<DemoState> {
  DemoController() : super(const DemoState());
  @override
  DemoState get debugState => state;
  void switchRole(DemoRole role) => state = state.copyWith(role: role, activeTab: 0);
  void tab(int index) => state = state.copyWith(activeTab: index);
  void answer(bool going) => state = state.copyWith(stage: going ? RideStage.offered : RideStage.declined);
  void acceptRiderOffer() => state = state.copyWith(stage: RideStage.confirmed);
  void beginTrip() => state = state.copyWith(stage: RideStage.active);
  void finishTrip() => state = state.copyWith(stage: RideStage.completed);
  void setRating(int stars) { if (stars >= 1 && stars <= 5) state = state.copyWith(rating: stars); }
  void setSchedule(Set<int> days, String pickup, String arriveBy, String direction) => state = state.copyWith(days: Set.of(days), pickup: pickup, arriveBy: arriveBy, direction: direction);
  void driverDecision(bool accepted) => state = state.copyWith(driverAccepted: accepted, driverDeclined: !accepted);
  void updatePrice(int value) { if (value >= 1000 && value <= 500000) state = state.copyWith(price: value); }
  // Demonstration chat stays in memory. Server-side filtering is mandatory for production.
  String? send(String text, DateTime now, DateTime start, DateTime end) {
    if (!ChatPolicy.withinWindow(now, start, end)) return 'Chat vaqti hali kelmagan yoki tugagan.';
    if (!ChatPolicy.permitted(text)) return 'Raqam, @username va havolalar yuborilmaydi.';
    state = state.copyWith(messages: [...state.messages, DemoMessage('Siz', text.trim(), now)]);
    return null;
  }
  void reset() => state = const DemoState();
}
final demoProvider = StateNotifierProvider<DemoController, DemoState>((ref) => DemoController());
