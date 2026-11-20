import 'package:flutter_test/flutter_test.dart';
import 'package:ai_taksi/studio/studio_state.dart';

void main() {
  test('rider progresses through full offline booking and rating', () {
    final demo = StudioController();
    expect(demo.snapshot.ride, RideProgress.question);
    demo.going(true);
    expect(demo.snapshot.ride, RideProgress.offered);
    demo.acceptRide();
    expect(demo.snapshot.ride, RideProgress.booked);
    demo.startRide();
    demo.finishRide();
    demo.rate(5);
    expect(demo.snapshot.rating, 5);
    demo.dispose();
  });
  test('schedule rejects empty days and saves valid edits', () {
    final demo = StudioController();
    expect(demo.saveSchedule({}, 'Kosonsoy markazi', '13:00', 'Kosonsoy → NamSU'), isNotNull);
    expect(demo.saveSchedule({1,3}, 'Kosonsoy bozori', '12:30', 'NamSU → Kosonsoy'), isNull);
    expect(demo.snapshot.scheduleDays, {1,3});
    expect(demo.snapshot.pickup, 'Kosonsoy bozori');
    demo.dispose();
  });
  test('driver offer and pricing updates are local and controlled', () {
    final demo = StudioController();
    demo.switchRole(StudioRole.driver);
    demo.decideOffer(101, true);
    demo.decideOffer(101, false);
    expect(demo.snapshot.offerDecisions[101], OfferDecision.accepted);
    expect(demo.updatePrice(8, 22000), isNull);
    expect(demo.snapshot.priceFor(8), 22000);
    expect(demo.updatePrice(8, -1), isNotNull);
    demo.markPickup(0);
    expect(demo.snapshot.pickedUpStops, {0});
    demo.dispose();
  });
  test('chat rejects usernames and phone numbers even during ride', () {
    final demo = StudioController();
    expect(demo.sendMessage('Salom'), isNotNull);
    demo.going(true); demo.acceptRide();
    final prior = demo.snapshot.messages.length;
    expect(demo.sendMessage('+998901234567'), isNotNull);
    expect(demo.sendMessage('@telegramuser'), isNotNull);
    expect(demo.sendMessage('Men bekatdaman'), isNull);
    expect(demo.snapshot.messages.length, prior + 1);
    demo.dispose();
  });
  test('switch roles preserves temporary edits, reset restores defaults', () {
    final demo = StudioController();
    demo.going(true);
    demo.switchRole(StudioRole.driver);
    demo.updatePrice(8, 24000);
    demo.switchRole(StudioRole.passenger);
    expect(demo.snapshot.ride, RideProgress.offered);
    demo.reset();
    expect(demo.snapshot.ride, RideProgress.question);
    expect(demo.snapshot.priceFor(8), 20000);
    demo.dispose();
  });
}
