import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localgo/core/network/api_client.dart';
import 'package:localgo/data/repositories/api/api_listing_repository.dart';

void main() {
  final photo = XFile.fromData(
    Uint8List.fromList([255, 216, 255, 1, 2, 3]),
    name: 'photo.jpg',
  );
  test(
    'uploads bytes with auth and unwraps the Cloudinary API envelope',
    () async {
      final repository = ApiListingRepository(
        ApiClient(tokenProvider: () => 'test-token'),
        client: MockClient((request) async {
          expect(request.headers['Authorization'], 'Bearer test-token');
          expect(
            request.headers['content-type'],
            contains('multipart/form-data'),
          );
          expect(request.bodyBytes, containsAllInOrder([1, 2, 3]));
        expect(utf8.decode(request.bodyBytes, allowMalformed: true),
            contains('content-type: image/jpeg'));
          return http.Response(
            '{"success":true,"data":{"secureUrl":"https://res.cloudinary.com/test/image/upload/photo.jpg"}}',
            201,
          );
        }),
      );
      expect(
        await repository.uploadDraftImage(photo),
        'https://res.cloudinary.com/test/image/upload/photo.jpg',
      );
    },
  );

  test(
    'failed or incomplete uploads throw instead of losing selected photos',
    () async {
      for (final response in [
        http.Response('Unauthorized', 401),
        http.Response('{"success":true,"data":{}}', 200),
      ]) {
        final repository = ApiListingRepository(
          ApiClient(),
          client: MockClient((_) async => response),
        );
        await expectLater(repository.uploadDraftImage(photo), throwsStateError);
      }
    },
  );
}
