class TextSanitizer {
  TextSanitizer._();

  static String sanitize(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
  }
}
