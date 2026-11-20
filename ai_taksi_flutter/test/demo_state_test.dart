import 'package:flutter_test/flutter_test.dart';
import 'package:ai_taksi/demo/demo_state.dart';

void main() {
  test('rider flow changes without backend', () {
    final demo = DemoController();
    expect(demo.debugState.stage, RideStage.awaitingAnswer);
    demo.answer(true);
    expect(demo.debugState.stage, RideStage.offered);
    demo.acceptRiderOffer();
    demo.beginTrip();
    demo.finishTrip();
    demo.setRating(5);
    expect(demo.debugState.stage, RideStage.completed);
    expect(demo.debugState.rating, 5);
    demo.dispose();
  });
  test('driver can accept and reject demo offers', () {
    final demo = DemoController();
    demo.switchRole(DemoRole.driver);
    demo.driverDecision(false);
    expect(demo.debugState.driverDeclined, isTrue);
    demo.driverDecision(true);
    expect(demo.debugState.driverAccepted, isTrue);
    demo.dispose();
  });
  test('contact-like strings are rejected in demo chat', () {
    final demo = DemoController();
    final now = DateTime(2026, 11, 19, 12);
    final start = now.add(const Duration(minutes: 30));
    final end = start.add(const Duration(hours: 1));
    expect(demo.send('+998901234567', now, start, end), isNotNull);
    expect(demo.send('@telegramuser', now, start, end), isNotNull);
    expect(demo.send('Bekatda kutyapman', now, start, end), isNull);
    expect(demo.debugState.messages.length, 1);
    demo.dispose();
  });
}
