import 'package:flutter_test/flutter_test.dart';
import 'package:ai_taksi/studio/studio_state.dart';
import 'package:ai_taksi/studio/mock_catalog.dart';

void main() {
  test('mock catalog includes backend-compatible classes and 7 variants', () {
    expect(demoVehicles.length, 7);
    expect(demoVehicles.any((v) => v.kind == VehicleKind.yengil), isTrue);
    expect(demoVehicles.any((v) => v.kind == VehicleKind.damas), isTrue);
    expect(demoVehicles.any((v) => v.kind == VehicleKind.avtobus), isTrue);
  });
  test('group size limits suitable vehicles and recommendation', () {
    final demo = StudioController();
    demo.setGroupSize(19);
    expect(demo.snapshot.suitableVehicles.every((v) => v.seats >= 19), isTrue);
    expect(demo.snapshot.chosenVehicle.seats >= 19, isTrue);
    demo.setGroupSize(100);
    expect(demo.snapshot.groupSize, 19);
    demo.dispose();
  });
  test('favorite, preference and vehicle choice are reversible', () {
    final demo = StudioController();
    demo.toggleFavorite('byd');
    expect(demo.snapshot.favoriteVehicles.contains('byd'), isTrue);
    demo.toggleFavorite('byd');
    expect(demo.snapshot.favoriteVehicles.contains('byd'), isFalse);
    demo.updateRidePrefs(womenOnly: true, quietRide: true);
    expect(demo.snapshot.womenOnly, isTrue);
    expect(demo.snapshot.quietRide, isTrue);
    demo.setGroupSize(3);
    demo.selectVehicle('byd');
    expect(demo.snapshot.selectedVehicle, 'byd');
    demo.reset();
    expect(demo.snapshot.womenOnly, isFalse);
    demo.dispose();
  });
  test('vehicle choice respects 1–3 yengil, 4–8 damas, 9+ bus', () {
    final demo = StudioController();
    demo.selectVehicle('byd');
    expect(demo.snapshot.selectedVehicle, 'damas');
    demo.setGroupSize(3);
    expect(demo.snapshot.requiredKind, VehicleKind.yengil);
    demo.setGroupSize(8);
    expect(demo.snapshot.requiredKind, VehicleKind.damas);
    demo.setGroupSize(20);
    expect(demo.snapshot.requiredKind, VehicleKind.avtobus);
    demo.dispose();
  });
  test('pickup progress supports six stops without leaking between offers', () {
    final demo = StudioController();
    demo.markPickup(4, offerId: 105);
    expect(demo.snapshot.pickedUpStops.contains(10504), isTrue);
    demo.markPickup(0, offerId: 101);
    expect(demo.snapshot.pickedUpStops.contains(10100), isTrue);
    expect(demo.snapshot.pickedUpStops.contains(10500), isFalse);
    demo.dispose();
  });
  test('expanded offer pricing includes minibus and bus thresholds', () {
    final demo = StudioController();
    expect(demo.snapshot.priceFor(12), 18000);
    expect(demo.snapshot.priceFor(22), 15000);
    expect(demo.updatePrice(28, 16000), isNull);
    expect(demo.snapshot.priceFor(22), 16000);
    demo.dispose();
  });
}
