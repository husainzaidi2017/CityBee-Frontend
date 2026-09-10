import 'package:flutter_test/flutter_test.dart';
import 'package:localgo/domain/models/listing_submission.dart';

void main() {
  test('submission JSON maps all status fields', () {
    final s = ListingSubmission.fromJson({
      'id': 'sub-1',
      'businessName': 'Zaidi Skin & Care Clinic',
      'categorySlug': 'doctors',
      'status': 'rejected',
      'rejectionReason': 'Please add a valid street address.',
      'submittedAt': '2026-09-10T17:00:00Z',
      'cityName': 'Moradabad',
      'hasImages': true,
    });
    expect(s.businessName, 'Zaidi Skin & Care Clinic');
    expect(s.status, 'rejected');
    expect(s.rejectionReason, 'Please add a valid street address.');
    expect(s.hasImages, isTrue);
  });

  test('draft body includes only filled fields and category specifics', () {
    final draft = ListingDraft(
      categorySlug: 'doctors',
      businessName: 'Test Clinic',
      phone: '+919876543210',
      address: '12 Court Road, Moradabad',
      cityName: 'Moradabad',
      bizLat: 28.84,
      bizLng: 78.77,
      specialization: 'Dermatologist',
      experienceYears: 12,
    );
    final body = draft.toBody();
    expect(body['businessName'], 'Test Clinic');
    expect(body['categorySlug'], 'doctors');
    expect(body['bizLat'], 28.84);
    expect(body['specialization'], 'Dermatologist');
    expect(body['experienceYears'], 12);
    // Empty optional fields must NOT be sent.
    expect(body.containsKey('tagline'), isFalse);
    expect(body.containsKey('website'), isFalse);
    expect(body.containsKey('cuisine'), isFalse); // not a restaurant
  });

  test('draft category flags drive the right sections', () {
    final restaurant = ListingDraft(categorySlug: 'restaurants');
    final salon = ListingDraft(categorySlug: 'salons');
    final generic = ListingDraft(categorySlug: 'shops');
    expect(restaurant.isRestaurant, isTrue);
    expect(salon.isSalon, isTrue);
    expect(generic.isDoctor, isFalse);
    expect(generic.isRestaurant, isFalse);
    expect(generic.isHotel, isFalse);
    expect(generic.isSalon, isFalse);
  });
}
