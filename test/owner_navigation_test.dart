import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localgo/data/repositories/auth_repository.dart';
import 'package:localgo/domain/models/owner_business.dart';
import 'package:localgo/providers/app_providers.dart';

/// Guest auth repo: never signed in, no Supabase dependency.
class _GuestAuthRepository implements AuthRepository {
  @override
  Future<void> signInWithGoogle() async {}
  @override
  Future<void> signInWithPassword(String email, String password) async {}
  @override
  Future<void> createAccount(String name, String email, String password) async {}
  @override
  Future<void> resendOtp(String email) async {}
  @override
  Future<void> verifyOtp(String email, String otp) async {}
  @override
  Future<void> signOut() async {}
  @override
  bool get isSignedIn => false;
  @override
  String? get accessToken => null;
}

void main() {
  test('summary JSON maps correctly', () {
    final s = OwnerBusinessSummary.fromJson({
      'hasApprovedBusiness': true,
      'approvedBusinessCount': 2,
      'totalBusinessCount': 3,
    });
    expect(s.hasApprovedBusiness, isTrue);
    expect(s.approvedBusinessCount, 2);
    expect(s.totalBusinessCount, 3);
  });

  test('guests always resolve to the no-business state (Explore tab)',
      () async {
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(_GuestAuthRepository())],
    );
    addTearDown(container.dispose);
    // Not signed in → the bottom navigation must show Explore.
    expect(container.read(authStateProvider), isFalse);
    final summary = await container.read(ownerSummaryProvider.future);
    expect(summary.hasApprovedBusiness, isFalse);
    expect(summary.totalBusinessCount, 0);
  });

  test('guests have no owned businesses', () async {
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(_GuestAuthRepository())],
    );
    addTearDown(container.dispose);
    final businesses = await container.read(myBusinessesProvider.future);
    expect(businesses, isEmpty);
  });
}
