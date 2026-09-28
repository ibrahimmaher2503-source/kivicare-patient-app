import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FCM player registration keeps multipart boundary for Laravel', () {
    final network = File('lib/network/network_utils.dart').readAsStringSync();
    final auth = File('lib/api/auth_apis.dart').readAsStringSync();

    expect(
      network,
      contains('multiPartRequest.headers.remove(HttpHeaders.contentTypeHeader);'),
    );
    expect(auth, contains("multiPartRequest.fields[UserKeys.playerId] = playerId.trim();"));
  });
}
