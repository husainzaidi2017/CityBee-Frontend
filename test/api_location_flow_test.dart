import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:localgo/core/network/api_client.dart';
import 'package:localgo/core/errors/app_exception.dart';
import 'package:localgo/data/repositories/api/api_city_repository.dart';
import 'package:localgo/data/repositories/api/api_mappers.dart';
import 'package:localgo/data/repositories/city_repository.dart';
import 'package:localgo/domain/models/business.dart';
import 'package:localgo/domain/models/citybee_location.dart';

/// Unit tests for the location architecture against a mocked API:
/// Google search → resolve (NO city creation) → CityBeeLocation model.
void main() {
  group('ApiCityRepository.searchCities', () {
    test('returns suggestions from /location/search', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/api/location/search');
        expect(request.url.queryParameters['q'], 'lucknow');
        return http.Response(
          '{"success":true,"data":['
          '{"placeId":"ChIJa7Ey","mainText":"Lucknow","secondaryText":"Uttar Pradesh, India"},'
          '{"placeId":"ChIJother","mainText":"Lucknow City","secondaryText":"Pakistan"}'
          '],"message":"Success"}',
          200,
        );
      });
      final repo = ApiCityRepository(ApiClient(client: client));
      final results = await repo.searchCities('lucknow');

      expect(results, hasLength(2));
      expect(results.first.placeId, 'ChIJa7Ey');
      expect(results.first.mainText, 'Lucknow');
      expect(results.first.secondaryText, 'Uttar Pradesh, India');
    });

    test('skips the API for short queries (< 2 chars)', () async {
      var called = false;
      final client = MockClient((_) async {
        called = true;
        return http.Response('{}', 200);
      });
      final repo = ApiCityRepository(ApiClient(client: client));
      expect(await repo.searchCities('d'), isEmpty);
      expect(called, isFalse);
    });

    test('surfaces server errors as AppException with message', () async {
      final client = MockClient((_) async => http.Response(
          '{"success":false,"message":"Location search is not available right now.","statusCode":400}',
          400));
      final repo = ApiCityRepository(ApiClient(client: client));
      await expectLater(
        repo.searchCities('delhi'),
        throwsA(isA<AppExceptionWithMessage>()
            .having((e) => e.userMessage, 'message', contains('not available'))),
      );
    });
  });

  group('ApiCityRepository.resolveLocation', () {
    test('maps /location/resolve onto CityBeeLocation (no city payload)', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/api/location/resolve');
        expect(request.url.queryParameters['placeId'], 'ChIJa7Ey');
        // The endpoint must NOT hit any city-creation route.
        return http.Response(
          '{"success":true,"data":{'
          '"placeId":"ChIJa7Ey","displayName":"Lucknow",'
          '"formattedAddress":"Lucknow, Uttar Pradesh, India",'
          '"latitude":26.8467,"longitude":80.9462,'
          '"country":"India","countryCode":"IN",'
          '"state":"Uttar Pradesh","locality":"Lucknow"'
          '},"message":"Success"}',
          200,
        );
      });
      final repo = ApiCityRepository(ApiClient(client: client));
      final location = await repo.resolveLocation('ChIJa7Ey');

      expect(location, isNotNull);
      expect(location!.displayName, 'Lucknow');
      expect(location.googlePlaceId, 'ChIJa7Ey');
      expect(location.latitude, closeTo(26.8467, 0.0001));
      expect(location.longitude, closeTo(80.9462, 0.0001));
      expect(location.state, 'Uttar Pradesh');
      expect(location.country, 'India');
      expect(location.locality, 'Lucknow');
      // Profile-patch payload carries the location, not a city reference.
      expect(location.toProfilePatch()['name'], 'Lucknow');
      expect(location.toProfilePatch()['latitude'], 26.8467);
    });
  });

  group('ApiCityRepository.reverseGeocode', () {
    test('maps /location/reverse onto CityBeeLocation', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/api/location/reverse');
        expect(request.url.queryParameters['lat'], '28.8386');
        return http.Response(
          '{"success":true,"data":{'
          '"placeId":"rev-1","displayName":"Moradabad",'
          '"latitude":28.8386,"longitude":78.7733,'
          '"country":"India","countryCode":"IN","state":"Uttar Pradesh",'
          '"locality":"Moradabad"'
          '},"message":"Success"}',
          200,
        );
      });
      final repo = ApiCityRepository(ApiClient(client: client));
      final location = await repo.reverseGeocode(28.8386, 78.7733);

      expect(location, isNotNull);
      expect(location!.displayName, 'Moradabad');
      expect(location.state, 'Uttar Pradesh');
    });
  });

  group('CityBeeLocation', () {
    test('json round-trip (persistence contract)', () {
      const location = CityBeeLocation(
        displayName: 'Sirsi',
        latitude: 14.62,
        longitude: 74.83,
        googlePlaceId: 'sirsi-1',
        country: 'India',
        countryCode: 'IN',
        state: 'Karnataka',
        locality: 'Sirsi',
      );
      final restored = CityBeeLocation.fromJson(location.toJson());
      expect(restored.displayName, 'Sirsi');
      expect(restored.latitude, 14.62);
      expect(restored.googlePlaceId, 'sirsi-1');
      expect(restored.state, 'Karnataka');
    });
  });

  group('ApiMappers.business', () {
    test('maps a full business payload with doctor extension', () {
      final business = ApiMappers.business({
        'id': 'verma-dental',
        'uuid': '7dafe8c2-0000-0000-0000-84f112f65d02',
        'name': 'Dr. Verma Dental Clinic',
        'kind': 'doctor',
        'tagline': 'Dentist',
        'description': 'Painless dentistry',
        'images': ['https://res.cloudinary.com/x.png'],
        'rating': 4.8,
        'ratingCount': 490,
        'address': 'Court Road',
        'area': 'Court Road',
        'cityName': 'Moradabad',
        'distanceKm': 1.1,
        'distanceMeters': 1100,
        'phone': '+915912400585',
        'whatsapp': '919812345678',
        'website': null,
        'openingHours': 'Mon–Sat',
        'isOpen': true,
        'isVerified': true,
        'isPureVeg': false,
        'imageBadges': ['30% OFF'],
        'featureChips': ['Walk-ins'],
        'actionButtons': ['Call', 'Route', 'Book Visit'],
        'latitude': 28.8388,
        'longitude': 78.7769,
        'doctor': {
          'name': 'Dr. Anil Verma',
          'specialization': 'Dentist',
          'qualification': 'BDS, MDS',
          'experience_years': 12,
          'consultation_fee': '₹300',
          'bio': null,
        },
        'categoryIds': ['doctors'],
      });

      expect(business, isNotNull);
      expect(business!.id, 'verma-dental');
      expect(business.kind, BusinessKind.doctor);
      expect(business.cityName, 'Moradabad');
      expect(business.distanceKm, 1.1);
      expect(business.distanceMeters, 1100);
      expect(business.consultationFee, '₹300');
    });

    test('tolerates a business without images (no crash)', () {
      final business = ApiMappers.business({
        'id': 'no-image',
        'name': 'Bare Shop',
        'kind': 'shop',
        'images': <String>[],
        'latitude': 0,
        'longitude': 0,
      });
      expect(business, isNotNull);
      expect(business!.images, isEmpty);
    });
  });

  group('CitySuggestion (mock repository parity)', () {
    test('mock search filters known cities and resolves without creating data', () async {
      final repo = MockCityRepository();
      final results = await repo.searchCities('mora');
      expect(results, hasLength(1));
      expect(results.first.mainText, 'Moradabad');

      final location = await repo.resolveLocation(results.first.placeId);
      expect(location, isNotNull);
      expect(location!.displayName, 'Moradabad');
    });
  });
}
