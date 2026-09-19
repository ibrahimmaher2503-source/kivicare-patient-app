import 'dart:async';

const _logoutRequestTimeout = Duration(seconds: 15);
const _logoutCleanupTimeout = Duration(seconds: 3);

/// Runs the UI logout boundary. Local sign-out always wins over a lost server
/// response: the server token may already have been revoked.
Future<void> runLogoutFlow({
  required Future<void> Function() sendLogout,
  required Future<void> Function() clearLocalSession,
  required Future<void> Function() navigateToSignedOutHome,
  required void Function(bool) setLoading,
  required void Function(Object error) onRemoteFailure,
  Duration requestTimeout = _logoutRequestTimeout,
  Duration cleanupTimeout = _logoutCleanupTimeout,
}) async {
  setLoading(true);
  try {
    await sendLogout().timeout(requestTimeout);
  } catch (error) {
    onRemoteFailure(error);
  } finally {
    try {
      await clearLocalSession().timeout(cleanupTimeout);
    } catch (_) {
      // Auth state is cleared synchronously before any best-effort cleanup.
    }
    setLoading(false);
    unawaited(navigateToSignedOutHome());
  }
}
