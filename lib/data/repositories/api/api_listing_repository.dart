import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_client.dart';
import '../../../domain/models/listing_submission.dart';

/// Backend implementation of the List-Your-Business flow.
class ApiListingRepository {
  ApiListingRepository(this._api, {http.Client? client})
    : _client = client ?? http.Client();

  final ApiClient _api;
  final http.Client _client;

  /// Submit the draft for admin review (owner derived from JWT server-side).
  Future<Map<String, dynamic>> submit(ListingDraft draft) async {
    final data = await _api.post('/me/business-listings', body: draft.toBody());
    return data is Map<String, dynamic> ? data : const {};
  }

  /// My submissions (all statuses) — drives the More screen section.
  Future<List<ListingSubmission>> mySubmissions() async {
    final data = await _api.get('/me/business-listings');
    return ListingSubmission.fromList(data);
  }

  /// Resubmit a rejected listing.
  Future<void> resubmit(String submissionId) =>
      _api.post('/me/business-listings/$submissionId/resubmit');

  /// Uploads a draft photo to Cloudinary (unsorted folder — the submission
  /// stores the URL; association happens at admin approval).
  Future<String> uploadDraftImage(XFile file) async {
    final bytes = await file.readAsBytes();
    final mimeType = lookupMimeType(file.name, headerBytes: bytes);
    if (mimeType == null || !mimeType.startsWith('image/')) {
      throw StateError('Photo upload requires an image file');
    }
    final uri = _assetUri('/uploads/image');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: file.name,
          contentType: MediaType.parse(mimeType),
        ),
      );
    final token = await _api.token;
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    final streamed = await _client
        .send(request)
        .timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Photo upload failed (${response.statusCode})');
    }
    final body = _api.decodeBody(response.body) as Map<String, dynamic>;
    final data = body['data'] ?? body;
    final url = data is Map ? data['secureUrl'] : null;
    if (body['success'] == false ||
        url is! String ||
        Uri.tryParse(url)?.scheme != 'https') {
      throw StateError('Photo upload did not return a secure image URL');
    }
    return url;
  }

  Uri _assetUri(String path) {
    final base = Uri.parse(ApiClient.baseUrl);
    return base.replace(path: '${base.path}$path');
  }
}
