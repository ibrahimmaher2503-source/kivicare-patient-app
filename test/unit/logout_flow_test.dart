import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kivicare_patient/screens/auth/profile/logout_flow.dart';

void main() {
  test('logout success clears the local session, hides loading, and navigates',
      () async {
    final events = <String>[];

    await runLogoutFlow(
      sendLogout: () async => events.add('remote'),
      clearLocalSession: () async => events.add('clear'),
      navigateToSignedOutHome: () async => events.add('navigate'),
      setLoading: (loading) => events.add('loading:$loading'),
      onRemoteFailure: (_) => events.add('failure'),
    );
    await Future<void>.delayed(Duration.zero);

    expect(events,
        ['loading:true', 'remote', 'clear', 'loading:false', 'navigate']);
  });

  test('logout failure or stuck cleanup cannot leave the loading overlay up',
      () async {
    var loading = false;
    var failures = 0;
    var navigated = false;

    await runLogoutFlow(
      sendLogout: () => Future<void>.error(TimeoutException('offline')),
      clearLocalSession: () => Completer<void>().future,
      navigateToSignedOutHome: () async => navigated = true,
      setLoading: (value) => loading = value,
      onRemoteFailure: (_) => failures++,
      cleanupTimeout: const Duration(milliseconds: 1),
    );
    await Future<void>.delayed(const Duration(milliseconds: 1));

    expect(failures, 1);
    expect(loading, isFalse);
    expect(navigated, isTrue);
  });
}
