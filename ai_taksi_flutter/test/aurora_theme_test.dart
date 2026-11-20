import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_taksi/studio/studio_app.dart';
import 'package:ai_taksi/studio/studio_design.dart';
import 'package:ai_taksi/studio/studio_state.dart';

void main() {
  test('light and dark palettes have their expected brightness', () {
    expect(studioTheme().brightness, Brightness.light);
    expect(studioTheme(dark: true).brightness, Brightness.dark);
    expect(studioTheme().colorScheme.primary, auroraPurple);
    expect(studioTheme(dark: true).colorScheme.secondary, auroraCyan);
  });

  testWidgets('theme toggle preserves demo trip state', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container, child: const AIStudioApp()));
    await tester.pumpAndSettle();
    expect(container.read(auroraThemeModeProvider), ThemeMode.light);
    final rideBefore = container.read(studioProvider).ride;
    await tester.tap(find.byTooltip('Tungi rejim'));
    await tester.pumpAndSettle();
    expect(container.read(auroraThemeModeProvider), ThemeMode.dark);
    expect(container.read(studioProvider).ride, rideBefore);
    await tester.tap(find.byTooltip('Yorug‘ rejim'));
    await tester.pumpAndSettle();
    expect(container.read(auroraThemeModeProvider), ThemeMode.light);
  });
}
