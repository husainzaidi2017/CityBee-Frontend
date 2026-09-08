import '../../domain/models/user_profile.dart';
import '../mock/mock_data.dart';

/// Contract for reading and persisting the user profile.
///
/// The mock keeps changes in memory; the Supabase implementation will write
/// to the `users` table without any UI changes.
abstract class ProfileRepository {
  Future<UserProfile> getProfile();
  Future<UserProfile> saveProfile(UserProfile profile);
}

class MockProfileRepository implements ProfileRepository {
  UserProfile _profile = mockProfile;

  @override
  Future<UserProfile> getProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _profile;
  }

  @override
  Future<UserProfile> saveProfile(UserProfile profile) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _profile = profile;
    return profile;
  }
}
