import 'package:flutter_test/flutter_test.dart';
import 'package:ai_taksi/core/chat_policy.dart';
void main() {
  test('blocks Uzbekistan phone numbers', () {
    expect(ChatPolicy.permitted('Menga +998 90 123 45 67 yozing'), isFalse);
    expect(ChatPolicy.permitted('901234567 raqam'), isFalse);
  });
  test('blocks usernames and Telegram links', () {
    expect(ChatPolicy.permitted('Telegram: @username_123'), isFalse);
    expect(ChatPolicy.permitted('t.me/test_name'), isFalse);
    expect(ChatPolicy.permitted('https://example.com'), isFalse);
    expect(ChatPolicy.permitted('www.example.com'), isFalse);
  });
  test('allows normal trip text', () => expect(ChatPolicy.permitted('Bekatda kutyapman'), isTrue));
  test('opens only one hour either side', () {
    final start = DateTime(2026, 11, 23, 10);
    final end = DateTime(2026, 11, 23, 11);
    expect(ChatPolicy.withinWindow(DateTime(2026, 11, 23, 9), start, end), isTrue);
    expect(ChatPolicy.withinWindow(DateTime(2026, 11, 23, 8, 59), start, end), isFalse);
    expect(ChatPolicy.withinWindow(DateTime(2026, 11, 23, 12), start, end), isTrue);
    expect(ChatPolicy.withinWindow(DateTime(2026, 11, 23, 12, 1), start, end), isFalse);
  });
}
