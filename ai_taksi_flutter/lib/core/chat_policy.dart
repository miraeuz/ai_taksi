class ChatPolicy {
  static final RegExp phone = RegExp(r'(?<!\d)(?:\+?998[\s().-]*)?(?:\d[\s().-]*){9}(?!\d)');
  static final RegExp handle = RegExp(r'(?<!\w)@[a-zA-Z][a-zA-Z0-9_]{4,31}\b');
  static final RegExp telegramLink = RegExp(r'\b(?:https?://)?(?:t\.me|telegram\.me)/\S+', caseSensitive: false);
  static bool permitted(String content) => content.trim().isNotEmpty && !phone.hasMatch(content) && !handle.hasMatch(content) && !telegramLink.hasMatch(content);
  static bool withinWindow(DateTime now, DateTime plannedStart, DateTime plannedEnd) => !now.isBefore(plannedStart.subtract(const Duration(hours: 1))) && !now.isAfter(plannedEnd.add(const Duration(hours: 1)));
}
