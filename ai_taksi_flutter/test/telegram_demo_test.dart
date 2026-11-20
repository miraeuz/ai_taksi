import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_taksi/telegram/demo_state.dart';
import 'package:ai_taksi/telegram/mock_data.dart';
import 'package:ai_taksi/telegram/tg_theme.dart';

void main() {
  test('11 destinations include the Yuksalish NamDU campus and other universities', () {
    expect(destinations.length, 11);
    expect(destinations.any((p) => p.id == 'yuksalish'), isTrue);
    expect(destinations.any((p) => p.id == 'texnika'), isTrue);
    expect(destinations.any((p) => p.id == 'ubs'), isTrue);
  });

  test('mock login changes rider and driver roles without SMS', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(demoSessionProvider).loggedIn, isFalse);
    container.read(demoSessionProvider.notifier).login('Aziza', DemoRole.rider);
    expect(container.read(demoSessionProvider).loggedIn, isTrue);
    container.read(demoSessionProvider.notifier).setRole(DemoRole.driver);
    expect(container.read(demoSessionProvider).role, DemoRole.driver);
    container.read(demoSessionProvider.notifier).logout();
    expect(container.read(demoSessionProvider).loggedIn, isFalse);
  });

  test('mock destination, group size and schedule update independently', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final ctrl = container.read(demoSessionProvider.notifier);
    ctrl.setDestination('texnika');
    ctrl.setOrigin('toraqorgon');
    ctrl.setGroupSize(12);
    ctrl.toggleDay(3);
    final state = container.read(demoSessionProvider);
    expect(state.destinationId, 'texnika');
    expect(state.originId, 'toraqorgon');
    expect(state.suggestedGroup, 'Avtobus');
    expect(state.scheduleDays.contains(3), isTrue);
  });

  test('driver offers cannot be accepted and declined twice', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final ctrl = container.read(demoSessionProvider.notifier);
    ctrl.decideOffer('A-201', true);
    ctrl.decideOffer('A-201', false);
    expect(container.read(demoSessionProvider).decisions['A-201'], DemoOfferStatus.accepted);
  });

  test('chat blocks numbers, at-mentions, and URLs in demo', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final ctrl = container.read(demoSessionProvider.notifier);
    ctrl.confirmTrip();
    expect(ctrl.sendMessage('+998 90 123 45 67'), isNotNull);
    expect(ctrl.sendMessage('@telegram_handle'), isNotNull);
    expect(ctrl.sendMessage('https://t.me/test'), isNotNull);
    expect(ctrl.sendMessage('Bekatda kutyapman'), isNull);
  });

  test('light and dark themes use distinct canvas colors', () {
    expect(tgTheme().scaffoldBackgroundColor, isNot(tgTheme(dark:true).scaffoldBackgroundColor));
  });
}
