import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../core/network/api_client.dart';
import '../../../domain/models/owner_business.dart';

/// Backend implementation of the business-owner management API.
///
/// Every call carries the Supabase JWT; the backend derives the owner from
/// the token and verifies ownership server-side.
class ApiOwnerRepository {
  ApiOwnerRepository(this._api, {http.Client? client})
    : _client = client ?? http.Client();

  final ApiClient _api;
  final http.Client _client;

  // ── status + list ─────────────────────────────────────────────────────

  Future<OwnerBusinessSummary> summary() async {
    final data = await _api.get('/me/businesses/summary');
    return data is Map<String, dynamic>
        ? OwnerBusinessSummary.fromJson(data)
        : OwnerBusinessSummary.empty;
  }

  Future<List<OwnerBusiness>> myBusinesses() async {
    final data = await _api.get('/me/businesses');
    return OwnerBusiness.fromList(data);
  }

  Future<OwnerBusinessDetails?> businessDetails(String businessId) async {
    final data = await _api.get('/me/businesses/$businessId');
    return data is Map<String, dynamic>
        ? OwnerBusinessDetails.fromJson(data)
        : null;
  }

  // ── common fields ─────────────────────────────────────────────────────

  Future<void> updateBusiness(
    String businessId, {
    String? name,
    String? tagline,
    String? description,
    String? phone,
    String? whatsapp,
    String? email,
    String? website,
    String? address,
    String? locality,
    String? postalCode,
    String? openingHours,
    double? latitude,
    double? longitude,
  }) => _api.patch(
    '/me/businesses/$businessId',
    body: {
      if (name != null) 'name': name,
      if (tagline != null) 'tagline': tagline,
      if (description != null) 'description': description,
      if (phone != null) 'phone': phone,
      if (whatsapp != null) 'whatsapp': whatsapp,
      if (email != null) 'email': email,
      if (website != null) 'website': website,
      if (address != null) 'address': address,
      if (locality != null) 'locality': locality,
      if (postalCode != null) 'postalCode': postalCode,
      if (openingHours != null) 'openingHours': openingHours,
      if (latitude != null && longitude != null) ...{
        'latitude': latitude,
        'longitude': longitude,
      },
    },
  );

  Future<void> requestBusinessUpdate(
    String businessId, {
    String? name,
    String? tagline,
    String? description,
    String? phone,
    String? whatsapp,
    String? email,
    String? website,
    String? address,
    String? locality,
    String? postalCode,
    String? openingHours,
    double? latitude,
    double? longitude,
  }) => _api.post(
    '/me/businesses/$businessId/change-request',
    body: {
      if (name != null) 'name': name,
      if (tagline != null) 'tagline': tagline,
      if (description != null) 'description': description,
      if (phone != null) 'phone': phone,
      if (whatsapp != null) 'whatsapp': whatsapp,
      if (email != null) 'email': email,
      if (website != null) 'website': website,
      if (address != null) 'address': address,
      if (locality != null) 'locality': locality,
      if (postalCode != null) 'postalCode': postalCode,
      if (openingHours != null) 'openingHours': openingHours,
      if (latitude != null && longitude != null) ...{
        'latitude': latitude,
        'longitude': longitude,
      },
    },
  );

  // ── hours ─────────────────────────────────────────────────────────────

  Future<List<BusinessHour>> getHours(String businessId) async {
    final data = await _api.get('/me/businesses/$businessId/hours');
    return ((data as List?) ?? const [])
        .map((e) => e is Map<String, dynamic> ? BusinessHour.fromJson(e) : null)
        .whereType<BusinessHour>()
        .toList();
  }

  Future<void> updateHours(String businessId, List<BusinessHour> hours) =>
      _api.put(
        '/me/businesses/$businessId/hours',
        body: {
          'hours': [
            for (final h in hours)
              {
                'dayOfWeek': h.dayOfWeek,
                'isClosed': h.isClosed,
                'openTime': h.openTime,
                'closeTime': h.closeTime,
              },
          ],
        },
      );

  // ── offers ────────────────────────────────────────────────────────────

  Future<List<OwnerOffer>> offers(String businessId) async {
    final data = await _api.get('/me/businesses/$businessId/offers');
    return OwnerOffer.fromList(data);
  }

  Future<void> createOffer(String businessId, Map<String, dynamic> body) =>
      _api.post('/me/businesses/$businessId/offers', body: body);

  Future<void> updateOffer(
    String businessId,
    String offerId,
    Map<String, dynamic> body,
  ) => _api.patch('/me/businesses/$businessId/offers/$offerId', body: body);

  Future<void> deleteOffer(String businessId, String offerId) =>
      _api.delete('/me/businesses/$businessId/offers/$offerId');

  // ── menu ──────────────────────────────────────────────────────────────

  Future<void> createMenuCategory(String businessId, String name) => _api.post(
    '/me/businesses/$businessId/menu/categories',
    body: {'name': name},
  );

  Future<void> deleteMenuCategory(String businessId, String categoryId) =>
      _api.delete('/me/businesses/$businessId/menu/categories/$categoryId');

  Future<void> createMenuItem(String businessId, Map<String, dynamic> body) =>
      _api.post('/me/businesses/$businessId/menu/items', body: body);

  Future<void> updateMenuItem(
    String businessId,
    String itemId,
    Map<String, dynamic> body,
  ) => _api.patch('/me/businesses/$businessId/menu/items/$itemId', body: body);

  Future<void> deleteMenuItem(String businessId, String itemId) =>
      _api.delete('/me/businesses/$businessId/menu/items/$itemId');

  // ── business services ─────────────────────────────────────────────────

  Future<void> createService(String businessId, Map<String, dynamic> body) =>
      _api.post('/me/businesses/$businessId/services', body: body);

  Future<void> updateService(
    String businessId,
    String serviceId,
    Map<String, dynamic> body,
  ) => _api.patch('/me/businesses/$businessId/services/$serviceId', body: body);

  Future<void> deleteService(String businessId, String serviceId) =>
      _api.delete('/me/businesses/$businessId/services/$serviceId');

  // ── type-specific ─────────────────────────────────────────────────────

  Future<void> updateDoctor(String businessId, Map<String, dynamic> body) =>
      _api.patch('/me/businesses/$businessId/doctor', body: body);

  Future<void> updateRestaurant(String businessId, Map<String, dynamic> body) =>
      _api.patch('/me/businesses/$businessId/restaurant', body: body);

  Future<void> updateHotel(String businessId, Map<String, dynamic> body) =>
      _api.patch('/me/businesses/$businessId/hotel', body: body);

  Future<void> updateAmenities(String businessId, List<String> amenities) =>
      _api.put(
        '/me/businesses/$businessId/hotel/amenities',
        body: {'amenities': amenities},
      );

  // ── images ────────────────────────────────────────────────────────────

  Future<void> setImagePrimary(String businessId, String imageId) =>
      _api.patch('/me/businesses/$businessId/images/$imageId/primary');

  Future<void> deleteImage(String imageId) =>
      _api.delete('/uploads/business-images/$imageId');

  /// Uploads one photo: file → /uploads/image (Cloudinary) → associate with
  /// the business (backend enforces ownership + the 5-image cap).
  Future<void> addPhoto(String businessId, File file) =>
      addPhotos(businessId, [file]);

  /// Uploads MULTIPLE photos in one batch. Each file goes to Cloudinary
  /// under the business folder (citybee/businesses/{id}/) and is associated
  /// individually; uploads stop gracefully when the 5-photo cap is hit.
  /// Returns how many photos were added.
  Future<int> addPhotos(String businessId, List<File> files) async {
    var added = 0;
    for (final file in files) {
      try {
        final uri = _assetUri('/uploads/image');
        final request = http.MultipartRequest('POST', uri)
          ..fields['entityType'] = 'business'
          ..fields['entityId'] = businessId
          ..files.add(await http.MultipartFile.fromPath('file', file.path));
        final token = await _api.token;
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }
        final streamed = await _client
            .send(request)
            .timeout(const Duration(seconds: 60));
        final response = await http.Response.fromStream(streamed);
        if (response.statusCode >= 400) {
          throw Exception('Upload failed (${response.statusCode})');
        }
        final body = _api.decodeBody(response.body) as Map<String, dynamic>;
        final secureUrl = body['secureUrl']?.toString() ?? '';
        final publicId = body['publicId']?.toString();
        await _api.post(
          '/uploads/associate',
          body: {
            'imageUrl': secureUrl,
            if (publicId != null) 'publicId': publicId,
            'entityId': businessId,
            'entityType': 'business',
          },
        );
        added++;
      } catch (e) {
        // Photo cap reached mid-batch — report what we have.
        if (e.toString().contains('IMAGE_LIMIT') ||
            e.toString().contains('BUSINESS_IMAGE_LIMIT')) {
          break;
        }
        if (added == 0) rethrow;
        break;
      }
    }
    return added;
  }

  Uri _assetUri(String path) {
    final base = Uri.parse(ApiClient.baseUrl);
    return base.replace(path: '${base.path}$path');
  }

  // ── reviews (read-only) ───────────────────────────────────────────────

  Future<List<OwnerReview>> reviews(String businessId) async {
    final data = await _api.get('/me/businesses/$businessId/reviews');
    final list = data is Map<String, dynamic> ? data['reviews'] : data;
    return ((list as List?) ?? const [])
        .map((e) => e is Map<String, dynamic> ? OwnerReview.fromJson(e) : null)
        .whereType<OwnerReview>()
        .toList();
  }
}
