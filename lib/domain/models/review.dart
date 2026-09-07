/// Review written by a user about a business or place.
class Review {
  const Review({
    required this.id,
    required this.author,
    required this.authorMeta,
    required this.rating,
    required this.text,
    required this.timeAgo,
  });

  final String id;
  final String author;

  /// e.g. "LocalGo Pioneer · Level 3".
  final String authorMeta;
  final double rating;
  final String text;
  final String timeAgo;
}
