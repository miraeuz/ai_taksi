import 'dart:convert';

class AppUser {
  final int id;
  final String name, role;
  const AppUser({required this.id, required this.name, required this.role});
  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(id: j['id'] as int, name: (j['name'] ?? '') as String, role: (j['role'] ?? '') as String);
}
class AuthTokens {
  final String access, refresh;
  final AppUser user;
  AuthTokens.fromJson(Map<String, dynamic> j) : access = j['access_token'] as String, refresh = j['refresh_token'] as String, user = AppUser.fromJson(j['user'] as Map<String, dynamic>);
}
class Schedule {
  final int id, routeId, weekday, pickupPointId;
  final String arriveByTime, direction;
  final bool active;
  Schedule.fromJson(Map<String, dynamic> j) : id = j['id'] as int, routeId = j['route_id'] as int, weekday = j['weekday'] as int, pickupPointId = j['pickup_point_id'] as int, arriveByTime = (j['arrive_by_time'] ?? '') as String, direction = (j['direction'] ?? 'outbound') as String, active = (j['active'] ?? true) as bool;
}
class Confirmation {
  final int id, scheduleId;
  final String date, status;
  Confirmation.fromJson(Map<String, dynamic> j) : id = j['id'] as int, scheduleId = j['schedule_id'] as int, date = (j['date'] ?? '') as String, status = (j['status'] ?? '') as String;
}
class DriverPrice {
  final int id, routeId, minRiders, maxRiders;
  final double price;
  DriverPrice.fromJson(Map<String, dynamic> j) : id = j['id'] as int, routeId = j['route_id'] as int, minRiders = j['min_riders'] as int, maxRiders = j['max_riders'] as int, price = double.parse(j['price_per_person'].toString());
}
class DriverOffer {
  final int id, tripId;
  final String status;
  final DateTime? expiresAt;
  DriverOffer.fromJson(Map<String, dynamic> j) : id = j['id'] as int, tripId = j['trip_id'] as int, status = (j['status'] ?? '') as String, expiresAt = DateTime.tryParse((j['expires_at'] ?? '').toString());
}
class ChatMessage {
  final String sender, text;
  final DateTime at;
  const ChatMessage({required this.sender, required this.text, required this.at});
}

String prettyMoney(num n) => n.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ' ');
String readableError(Object error) {
  final text = error.toString();
  if (text.contains('connection') || text.contains('SocketException')) return 'Server bilan aloqa yo‘q. Internetni tekshiring.';
  return text.replaceFirst('Exception: ', '');
}
Map<String, dynamic> jsonMap(dynamic value) => Map<String, dynamic>.from(value as Map);
List<Map<String, dynamic>> jsonList(dynamic value) => (value as List).map(jsonMap).toList();
String encodeMap(Map<String, dynamic> map) => jsonEncode(map);
