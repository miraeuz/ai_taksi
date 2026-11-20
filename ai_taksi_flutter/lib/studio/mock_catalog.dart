import 'package:flutter/material.dart';

/// Local presentation fixture. These are model options, not live inventory.
/// The production backend currently has 3 car categories: yengil, damas, avtobus.
enum VehicleKind { yengil, damas, avtobus }

class DemoVehicle {
  final String id, name, model, categoryLabel, note;
  final VehicleKind kind;
  final int seats, baseFare;
  final double rating;
  final Color color;
  final IconData icon;
  final bool electric;
  const DemoVehicle({required this.id, required this.name, required this.model,
    required this.categoryLabel, required this.kind, required this.seats,
    required this.baseFare, required this.rating, required this.color,
    required this.icon, this.note = '', this.electric = false});

  int estimateFor(int passengers) {
    final occupied = passengers.clamp(1, seats);
    final discount = (occupied / seats * 0.18).clamp(0.0, 0.18);
    return ((baseFare * (1 - discount)) / 1000).round() * 1000;
  }
}

const demoVehicles = <DemoVehicle>[
  DemoVehicle(id: 'cobalt', name: 'Yengil Standard', model: 'Chevrolet Cobalt',
    categoryLabel: 'Yengil', kind: VehicleKind.yengil, seats: 3,
    baseFare: 35000, rating: 4.8, color: Color(0xFF7D69F9),
    icon: Icons.directions_car_filled_rounded, note: 'Tez va ixcham'),
  DemoVehicle(id: 'onix', name: 'Yengil Comfort', model: 'Chevrolet Onix',
    categoryLabel: 'Yengil', kind: VehicleKind.yengil, seats: 3,
    baseFare: 41000, rating: 4.9, color: Color(0xFF448CE0),
    icon: Icons.local_taxi_rounded, note: 'Konditsioner · qulay'),
  DemoVehicle(id: 'byd', name: 'Electric', model: 'BYD e2',
    categoryLabel: 'Yengil', kind: VehicleKind.yengil, seats: 3,
    baseFare: 43000, rating: 4.9, color: Color(0xFF10BFC5),
    icon: Icons.electric_car_rounded, note: 'Elektr · ekologik', electric: true),
  DemoVehicle(id: 'damas', name: 'Damas Share', model: 'Chevrolet Damas',
    categoryLabel: 'Damas', kind: VehicleKind.damas, seats: 8,
    baseFare: 24000, rating: 4.9, color: Color(0xFF8D4AFF),
    icon: Icons.airport_shuttle_rounded, note: 'Talabalar uchun maqbul'),
  DemoVehicle(id: 'sprinter', name: 'Mini Bus', model: 'Mercedes Sprinter',
    categoryLabel: 'Avtobus', kind: VehicleKind.avtobus, seats: 14,
    baseFare: 23000, rating: 4.8, color: Color(0xFF4366E8),
    icon: Icons.airport_shuttle_rounded, note: 'Katta guruh'),
  DemoVehicle(id: 'isuzu', name: 'City Shuttle', model: 'Isuzu SAZ',
    categoryLabel: 'Avtobus', kind: VehicleKind.avtobus, seats: 22,
    baseFare: 19000, rating: 4.7, color: Color(0xFF6C54CC),
    icon: Icons.directions_bus_rounded, note: 'Keng salon'),
  DemoVehicle(id: 'yutong', name: 'Group Express', model: 'Yutong',
    categoryLabel: 'Avtobus', kind: VehicleKind.avtobus, seats: 28,
    baseFare: 17000, rating: 4.8, color: Color(0xFF203B9A),
    icon: Icons.directions_bus_filled_rounded, note: 'Eng katta guruh'),
];

DemoVehicle vehicleById(String id) => demoVehicles.firstWhere(
  (vehicle) => vehicle.id == id, orElse: () => demoVehicles[3]);

/// A handful of realistic fictional historical receipts for the demo only.
class MockTripHistory {
  final String date, route, vehicle, driver;
  final int fare;
  final double rating;
  const MockTripHistory(this.date, this.route, this.vehicle, this.driver,
      this.fare, this.rating);
}

const demoHistory = <MockTripHistory>[
  MockTripHistory('18 noy · Chorshanba', 'Kosonsoy → NamSU', 'Damas', 'Sherzod', 20000, 5.0),
  MockTripHistory('16 noy · Dushanba', 'NamSU → Kosonsoy', 'Cobalt', 'Javohir', 30000, 4.9),
  MockTripHistory('11 noy · Chorshanba', 'Kosonsoy → NamSU', 'Damas', 'Islom', 21000, 4.8),
  MockTripHistory('09 noy · Dushanba', 'Kosonsoy → Namangan', 'Sprinter', 'Dilshod', 18000, 5.0),
  MockTripHistory('04 noy · Chorshanba', 'NamSU → Kosonsoy', 'Onix', 'Komil', 35000, 4.9),
];

const demoDrivers = <String>[
  'Sherzod · Damas · 4.9 ★', 'Javohir · Cobalt · 4.8 ★',
  'Islom · Damas · 4.8 ★', 'Dilshod · Sprinter · 4.9 ★',
  'Komil · Onix · 4.9 ★', 'Oybek · Yutong · 4.7 ★',
  'Ulug‘bek · BYD · 4.9 ★', 'Alisher · Isuzu · 4.8 ★',
];
