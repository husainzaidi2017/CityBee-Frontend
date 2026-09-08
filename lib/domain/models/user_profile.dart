/// The signed-in CityBee user (mock profile until Supabase Auth is wired).
class UserProfile {
  const UserProfile({
    required this.name,
    required this.handle,
    required this.email,
    required this.phone,
    required this.levelTitle,
    required this.topPercent,
    required this.savedAmount,
    required this.bookmarkCount,
    required this.reviewsGiven,
    required this.avatarImage,
  });

  final String name;
  final String handle;
  final String email;
  final String phone;

  /// e.g. "Level 3 Pioneer".
  final String levelTitle;
  final String topPercent;
  final String savedAmount;
  final int bookmarkCount;
  final int reviewsGiven;
  final String avatarImage;

  UserProfile copyWith({
    String? name,
    String? handle,
    String? email,
    String? phone,
    String? levelTitle,
    String? topPercent,
    String? savedAmount,
    int? bookmarkCount,
    int? reviewsGiven,
    String? avatarImage,
  }) =>
      UserProfile(
        name: name ?? this.name,
        handle: handle ?? this.handle,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        levelTitle: levelTitle ?? this.levelTitle,
        topPercent: topPercent ?? this.topPercent,
        savedAmount: savedAmount ?? this.savedAmount,
        bookmarkCount: bookmarkCount ?? this.bookmarkCount,
        reviewsGiven: reviewsGiven ?? this.reviewsGiven,
        avatarImage: avatarImage ?? this.avatarImage,
      );
}
