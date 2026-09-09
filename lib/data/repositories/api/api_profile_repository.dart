import '../../../core/network/api_client.dart';
import '../../../domain/models/user_profile.dart';
import '../auth_repository.dart';
import '../profile_repository.dart';

/// Profile persistence through the API when signed in; guests keep the
/// demo profile (login is optional — the whole app browses as guest).
class ApiProfileRepository implements ProfileRepository {
  ApiProfileRepository(this._api, this._auth);

  final ApiClient _api;
  final AuthRepository _auth;

  @override
  Future<UserProfile> getProfile() async {
    if (!_auth.isSignedIn) return _guestProfile;
    try {
      final data = await _api.get('/users/me');
      if (data is Map<String, dynamic>) return _fromApi(data);
    } catch (_) {
      // Fall back to the guest profile rather than blocking the UI.
    }
    return _guestProfile;
  }

  @override
  Future<UserProfile> saveProfile(UserProfile profile) async {
    if (!_auth.isSignedIn) return profile;
    final data = await _api.patch('/users/me', body: {
      'name': profile.name,
      // Only send phone when the user actually typed one — never re-send
      // empty strings or stale placeholders.
      if (profile.phone.trim().isNotEmpty) 'phone': profile.phone.trim(),
      if (profile.avatarImage.startsWith('http'))
        'profileImageUrl': profile.avatarImage,
    });
    return data is Map<String, dynamic> ? _fromApi(data) : profile;
  }

  static UserProfile _fromApi(Map<String, dynamic> json) => UserProfile(
        name: json['name']?.toString() ?? 'CityBee User',
        handle: '@${(json['name'] ?? 'user').toString().toLowerCase().replaceAll(' ', '.')}',
        email: json['email']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        levelTitle: 'CityBee Explorer',
        topPercent: '',
        savedAmount: '₹0',
        bookmarkCount: (json['bookmarkCount'] as num?)?.toInt() ?? 0,
        reviewsGiven: (json['reviewsGiven'] as num?)?.toInt() ?? 0,
        avatarImage:
            json['profileImageUrl']?.toString() ?? 'https://picsum.photos/seed/citybee-avatar/200/200',
      );

  static const _guestProfile = UserProfile(
    name: 'Guest Explorer',
    handle: '@guest',
    email: '',
    phone: '',
    levelTitle: 'Browsing as guest',
    topPercent: '',
    savedAmount: '₹0',
    bookmarkCount: 0,
    reviewsGiven: 0,
    avatarImage: 'https://picsum.photos/seed/citybee-avatar/200/200',
  );
}
