import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

import '../utils/local_storage.dart';

abstract final class CriticalOperationType {
  static const appointment = 'appointment';
  static const pharmacyOrder = 'pharmacy_order';
  static const pharmacyPrescription = 'pharmacy_prescription';
  static const testOrder = 'test_order';
  static const icuAdmission = 'icu_admission';
  static const payment = 'payment';
  static const nurseRequest = 'nurse_request';
  static const nurseCancellation = 'nurse_cancellation';
  static const doctorVisit = 'doctor_visit';
  static const doctorVisitCancellation = 'doctor_visit_cancellation';
  static const icuCancellation = 'icu_admission_cancellation';
  static const testOrderCancellation = 'test_order_cancellation';
  static const pharmacyCancellation = 'pharmacy_cancellation';
  static const incident = 'incident';
}

/// Raised when a new payload is submitted while an earlier request of the
/// same operation scope is still unresolved. The caller must reconcile the
/// earlier request instead of creating a second one.
class PendingCriticalOperationException implements Exception {
  final String operationType;

  const PendingCriticalOperationException(this.operationType);

  @override
  String toString() =>
      'A previous $operationType request is still pending. Verify its status before retrying.';
}

/// Persists only an opaque operation key and timestamp, never request payloads
/// or patient data. An ambiguous retry reuses the same key.
abstract final class CriticalOperationStore {
  static const _storageKey = 'pending_critical_operations_v1';
  static const _uuid = Uuid();
  static final Map<String, Future<void>> _locks = {};

  static Future<String> begin(
    String type, {
    String? scope,
    String? requestFingerprint,
  }) {
    final storageSlot = _storageSlot(type, scope);
    return _withLock(storageSlot, () async {
      final operations = _readOperations();
      final existing = operations[storageSlot];
      if (existing is Map && existing['key'] is String) {
        final key = (existing['key'] as String).trim();
        if (key.isNotEmpty) {
          final existingFingerprint = existing['fingerprint'];
          if (requestFingerprint != null &&
              existingFingerprint != requestFingerprint) {
            throw PendingCriticalOperationException(type);
          }
          return key;
        }
      }

      final key = _uuid.v4();
      operations[storageSlot] = {
        'key': key,
        'created_at': DateTime.now().toUtc().toIso8601String(),
        if (requestFingerprint != null) 'fingerprint': requestFingerprint,
      };
      await localStorage.write(_storageKey, operations);
      return key;
    });
  }

  static String? pendingKey(String type, {String? scope}) {
    final value = _readOperations()[_storageSlot(type, scope)];
    if (value is! Map || value['key'] is! String) return null;
    final key = (value['key'] as String).trim();
    return key.isEmpty ? null : key;
  }

  static Future<void> complete(String type, {String? scope}) {
    final storageSlot = _storageSlot(type, scope);
    return _withLock(storageSlot, () async {
      final operations = _readOperations()..remove(storageSlot);
      if (operations.isEmpty) {
        await localStorage.remove(_storageKey);
      } else {
        await localStorage.write(_storageKey, operations);
      }
    });
  }

  static Map<String, dynamic> _readOperations() {
    final value = localStorage.read(_storageKey);
    if (value is! Map) return <String, dynamic>{};
    return Map<String, dynamic>.from(value);
  }

  static String _storageSlot(String type, String? scope) {
    final normalizedScope = scope?.trim();
    return normalizedScope == null || normalizedScope.isEmpty
        ? type
        : '$type:$normalizedScope';
  }

  static Future<T> _withLock<T>(
    String storageSlot,
    Future<T> Function() action,
  ) async {
    final previous = _locks[storageSlot];
    final gate = Completer<void>();
    _locks[storageSlot] = gate.future;
    if (previous != null) await previous;
    try {
      return await action();
    } finally {
      if (!gate.isCompleted) gate.complete();
      if (identical(_locks[storageSlot], gate.future)) {
        _locks.remove(storageSlot);
      }
    }
  }
}

Map<String, String> criticalOperationHeaders(String operationKey) => {
      'Idempotency-Key': operationKey,
      'X-Request-ID': operationKey,
    };

/// Returns a deterministic hash of a request without persisting the request
/// body. It lets the client distinguish a retry from an accidental reuse of
/// a pending key while keeping PII out of local storage.
String criticalOperationFingerprint(Object? value) {
  final normalized = _normalizeForFingerprint(value);
  return sha256.convert(utf8.encode(jsonEncode(normalized))).toString();
}

Object? _normalizeForFingerprint(Object? value) {
  if (value is Map) {
    final entries = value.entries
        .map((entry) => MapEntry(
              entry.key.toString(),
              _normalizeForFingerprint(entry.value),
            ))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return <String, dynamic>{
      for (final entry in entries) entry.key: entry.value
    };
  }
  if (value is Iterable) {
    return value.map(_normalizeForFingerprint).toList();
  }
  if (value is DateTime) return value.toUtc().toIso8601String();
  return value;
}
