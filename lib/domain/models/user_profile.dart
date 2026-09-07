/// The signed-in LocalGo user (mock profile until auth is wired up).
class UserProfile {
  const UserProfile({
    required this.name,
    required this.handle,
    required this.levelTitle,
    required this.topPercent,
    required this.savedAmount,
    required this.bookmarkCount,
    required this.reviewsGiven,
    required this.avatarImage,
  });

  final String name;
  final String handle;

  /// e.g. "Level 3 Pioneer".
  final String levelTitle;
  final String topPercent;
  final String savedAmount;
  final int bookmarkCount;
  final int reviewsGiven;
  final String avatarImage;
}
