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

  Map<String, dynamic> toJson() => {
        'name': name,
        'handle': handle,
        'email': email,
        'phone': phone,
        'levelTitle': levelTitle,
        'topPercent': topPercent,
        'savedAmount': savedAmount,
        'bookmarkCount': bookmarkCount,
        'reviewsGiven': reviewsGiven,
        'avatarImage': avatarImage,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: (json['name'] ?? '') as String,
        handle: (json['handle'] ?? '@user') as String,
        email: (json['email'] ?? '') as String,
        phone: (json['phone'] ?? '') as String,
        levelTitle: (json['levelTitle'] ?? 'CityBee Explorer') as String,
        topPercent: (json['topPercent'] ?? '') as String,
        savedAmount: (json['savedAmount'] ?? '₹0') as String,
        bookmarkCount: (json['bookmarkCount'] ?? 0) as int,
        reviewsGiven: (json['reviewsGiven'] ?? 0) as int,
        avatarImage: (json['avatarImage'] ??
            'https://picsum.photos/seed/citybee-avatar/200/200') as String,
      );
}