/// Typo-tolerant fuzzy matching for in-app search.
///
/// Matches when the query is a substring of the text, when a query word is
/// a prefix of a text word ("ele" → "electrician"), or when a query word is
/// within a small Levenshtein distance of a text word ("elecrician" →
/// "electrician", "plumer" → "plumber").
abstract final class FuzzySearch {
  static String _norm(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9 ]'), ' ');

  static int levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    var prev = List<int>.generate(b.length + 1, (i) => i);
    final curr = List<int>.generate(b.length + 1, (_) => 0);
    for (var i = 0; i < a.length; i++) {
      curr[0] = i + 1;
      for (var j = 0; j < b.length; j++) {
        final cost = a[i] == b[j] ? 0 : 1;
        var best = prev[j + 1] + 1; // deletion
        if (curr[j] + 1 < best) best = curr[j] + 1; // insertion
        if (prev[j] + cost < best) best = prev[j] + cost; // substitution
        curr[j + 1] = best;
      }
      prev = List.of(curr);
    }
    return prev[b.length];
  }

  /// True when [query] loosely matches [text]. Empty queries match
  /// everything. Every query word must match somewhere in the text.
  static bool matches(String query, String text) {
    final q = _norm(query).trim();
    if (q.isEmpty) return true;
    final t = _norm(text);
    if (t.contains(q)) return true;
    final qWords = q.split(RegExp(r'\s+'));
    final tWords = t.split(RegExp(r'\s+'));
    for (final qw in qWords) {
      if (qw.isEmpty) continue;
      var matched = false;
      for (final tw in tWords) {
        if (tw.startsWith(qw)) {
          matched = true;
          break;
        }
        if (tw.length >= 3 && qw.startsWith(tw)) {
          matched = true;
          break;
        }
        // Typo tolerance: 2 edits for words of 5+ letters, 1 for 3–4.
        final tolerance = qw.length >= 5 ? 2 : (qw.length >= 3 ? 1 : 0);
        if (tolerance > 0 &&
            (qw.length - tw.length).abs() <= tolerance &&
            levenshtein(qw, tw) <= tolerance) {
          matched = true;
          break;
        }
      }
      if (!matched) return false;
    }
    return true;
  }
}
