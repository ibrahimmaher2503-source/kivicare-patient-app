import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

import '../api/auth_apis.dart';
import '../configs.dart';
import '../main.dart';
import 'critical_operation.dart';
import '../utils/app_common.dart';
import '../utils/common_base.dart';

const Duration _requestTimeout = Duration(seconds: 30);
Future<void>? _sessionExpiryInFlight;

Future<void> _expireSession() async {
  final existing = _sessionExpiryInFlight;
  if (existing != null) return existing;

  final operation = () async {
    await AuthServiceApis.clearData();
    await navigateToSignedOutHome();
  }();
  _sessionExpiryInFlight = operation;
  try {
    await operation;
  } finally {
    if (identical(_sessionExpiryInFlight, operation)) {
      _sessionExpiryInFlight = null;
    }
  }
}

class NetworkRequestException implements Exception {
  final String message;

  const NetworkRequestException(this.message);

  @override
  String toString() => message;
}

class AuthenticationException extends NetworkRequestException {
  const AuthenticationException(super.message);
}

/// The client cannot know whether a mutating request reached Laravel.
/// Callers must reconcile status instead of automatically retrying.
class AmbiguousRequestOutcomeException extends NetworkRequestException {
  const AmbiguousRequestOutcomeException(super.message);
}

bool isMutatingHttpMethod(HttpMethodType method) =>
    method == HttpMethodType.POST ||
    method == HttpMethodType.PUT ||
    method == HttpMethodType.DELETE;

/// A server/proxy may have committed a mutation before returning one of these
/// transport-level failures. Callers must reconcile using the original
/// idempotency key instead of generating a new operation.
bool isAmbiguousMutatingStatus(int statusCode) =>
    statusCode == 408 || (statusCode >= 500 && statusCode <= 599);

/// Accept short user-facing messages, but never expose server implementation
/// details or markup in a toast/dialog.
String sanitizeBackendMessage(Object? value, String fallback) {
  final message = value is String ? value.trim() : '';
  if (message.isEmpty || message.length > 240) return fallback;

  final lower = message.toLowerCase();
  if (message.contains(RegExp(r'<[^>]*>')) ||
      message.contains(
          RegExp(r'&(?:lt|gt|amp|quot|#\d+);', caseSensitive: false)) ||
      lower.contains(RegExp(
          r'\b(?:exception|stack trace|traceback|sqlstate|select\s+.+\s+from|insert\s+into|update\s+[a-z_][\w.]*\s+set|delete\s+from|nosuchmethoderror|socketexception|formatexception|dioexception|fatal error|call to undefined (?:function|method)|undefined (?:variable|property|index)|class .+ not found|failed to open stream|permission denied|syntax error, unexpected)\b')) ||
      message.contains(RegExp(r'[/\\](?:var/www|home|srv|vendor)[/\\]')) ||
      lower.contains('illuminate\\')) {
    return fallback;
  }
  return message;
}

Map<String, String> buildHeaderTokens({
  Map? extraKeys,
  String? endPoint,
}) {
  /// Initialize & Handle if key is not present
  if (extraKeys == null) {
    extraKeys = {};
    extraKeys.putIfAbsent('isFlutterWave', () => false);
    extraKeys.putIfAbsent('isAirtelMoney', () => false);
  }
  // API LOCALIZATION (investigation conclusion: IMPLEMENTED).
  // Every request carries the user's currently-selected locale so the Laravel
  // backend returns localized data. `selectedLanguageCode` is the single source
  // of truth (set in settings_screen.dart, also drives the app Locale in
  // main.dart). Two headers are sent: `Accept-Language` (standard) and
  // `global-localization` (backend-specific). For payloads that ship `<base>_ar`
  // / `<base>_en` pairs, the client additionally resolves the right value via
  // pickLocalized() in utils/localized_field.dart. No further change needed.
  Map<String, String> header = {
    HttpHeaders.cacheControlHeader: 'no-cache',
    HttpHeaders.acceptHeader: 'application/json',
    'Access-Control-Allow-Headers': '*',
    'Access-Control-Allow-Origin': '*',
    'global-localization': selectedLanguageCode.value,
    HttpHeaders.acceptLanguageHeader: selectedLanguageCode.value,
  };

  header.putIfAbsent(
      HttpHeaders.contentTypeHeader, () => 'application/json; charset=utf-8');

  if (isLoggedIn.value &&
      extraKeys.containsKey('isFlutterWave') &&
      extraKeys['isFlutterWave']) {
    header.putIfAbsent(HttpHeaders.authorizationHeader,
        () => "Bearer ${extraKeys!['flutterWaveSecretKey']}");
  } else if (isLoggedIn.value &&
      extraKeys.containsKey('isAirtelMoney') &&
      extraKeys['isAirtelMoney']) {
    header.putIfAbsent(
        HttpHeaders.contentTypeHeader, () => 'application/json; charset=utf-8');
    header.putIfAbsent(HttpHeaders.authorizationHeader,
        () => 'Bearer ${extraKeys!['access_token']}');
    header.putIfAbsent('X-Country', () => '${extraKeys!['X-Country']}');
    header.putIfAbsent('X-Currency', () => '${extraKeys!['X-Currency']}');
  } else if (isLoggedIn.value) {
    header.putIfAbsent(HttpHeaders.authorizationHeader,
        () => 'Bearer ${loginUserData.value.apiToken}');
  }

  // log(jsonEncode(header));
  return header;
}

Uri buildBaseUrl(String endPoint) {
  if (!endPoint.startsWith('http')) {
    return Uri.parse('$BASE_URL$endPoint');
  } else {
    return Uri.parse(endPoint);
  }
}

String endpointWithQuery(
  String endPoint,
  Map<String, Object?> queryParameters,
) {
  final uri = buildBaseUrl(endPoint);
  final merged = <String, String>{
    ...uri.queryParameters,
    for (final entry in queryParameters.entries)
      if (entry.value != null && entry.value.toString().isNotEmpty)
        entry.key: entry.value.toString(),
  };
  return uri.replace(queryParameters: merged).toString();
}

Future<Response> buildHttpResponse(
  String endPoint, {
  HttpMethodType method = HttpMethodType.GET,
  Map? request,
  Map? extraKeys,
  Map<String, String>? header,
}) async {
  final headers =
      header ?? buildHeaderTokens(extraKeys: extraKeys, endPoint: endPoint);
  final url = buildBaseUrl(endPoint);

  try {
    late final Response response;
    if (method == HttpMethodType.POST) {
      response = await http
          .post(url, body: jsonEncode(request), headers: headers)
          .timeout(_requestTimeout);
    } else if (method == HttpMethodType.DELETE) {
      response = await delete(url, headers: headers).timeout(_requestTimeout);
    } else if (method == HttpMethodType.PUT) {
      response = await put(url, body: jsonEncode(request), headers: headers)
          .timeout(_requestTimeout);
    } else {
      response = await get(url, headers: headers).timeout(_requestTimeout);
    }

    apiPrint(
      url: url.toString(),
      endPoint: endPoint,
      statusCode: response.statusCode,
      methodtype: method.name,
    );

    if (isMutatingHttpMethod(method) &&
        isAmbiguousMutatingStatus(response.statusCode)) {
      throw AmbiguousRequestOutcomeException(
        locale.value.unknownSubmitOutcomeBanner,
      );
    }

    if (isLoggedIn.value &&
        response.statusCode == 401 &&
        !endPoint.startsWith('http')) {
      await _expireSession();
      throw AuthenticationException(locale.value.signInFailed);
    }
    return response;
  } on AuthenticationException {
    rethrow;
  } on TimeoutException {
    if (isMutatingHttpMethod(method)) {
      throw AmbiguousRequestOutcomeException(
        locale.value.requestTimedOutAfterSubmission,
      );
    }
    throw NetworkRequestException(locale.value.requestTimedOut);
  } on SocketException {
    if (isMutatingHttpMethod(method)) {
      throw AmbiguousRequestOutcomeException(
        locale.value.unknownSubmitOutcomeBanner,
      );
    }
    throw NetworkRequestException(errorInternetNotAvailable);
  } on ClientException {
    if (isMutatingHttpMethod(method)) {
      throw AmbiguousRequestOutcomeException(
        locale.value.unknownSubmitOutcomeBanner,
      );
    }
    throw NetworkRequestException(errorInternetNotAvailable);
  } on FormatException {
    throw NetworkRequestException(errorSomethingWentWrong);
  }
}

Future handleResponse(
  Response response, {
  HttpResponseType httpResponseType = HttpResponseType.JSON,
  bool? avoidTokenError,
  bool? isFlutterWave,
}) async {
  if (response.statusCode.isSuccessful()) {
    final rawBody = response.body.trim();
    if (response.statusCode == 204 || rawBody.isEmpty) {
      return <String, dynamic>{};
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(rawBody);
    } on FormatException {
      return rawBody;
    }

    if (decoded is Map) {
      final body = decoded.cast<String, dynamic>();
      if (body.containsKey('status')) {
        if (isFlutterWave.validate()) {
          if (body['status'] == 'success') return body;
          throw sanitizeBackendMessage(
            body['message'],
            locale.value.somethingWentWrong,
          );
        }
        if (body['status'] == true) return body;
        if (body['is_deleted'] == true) {
          await AuthServiceApis.clearData(isFromDeleteAcc: true);
        }
        throw sanitizeBackendMessage(
          body['message'],
          locale.value.somethingWentWrong,
        );
      }
      return body;
    }
    return decoded;
  }

  switch (response.statusCode) {
    case 400:
      throw _responseMessage(response, locale.value.badRequest);
    case 401:
      throw AuthenticationException(locale.value.signInFailed);
    case 403:
      throw _responseMessage(response, locale.value.forbidden);
    case 404:
      throw _responseMessage(response, locale.value.pageNotFound);
    case 409:
      if (_responseCode(response) == 'operation_pending') {
        throw const PendingCriticalOperationException('critical operation');
      }
      throw _responseMessage(response, locale.value.badRequest);
    case 422:
      throw _responseMessage(response, locale.value.badRequest);
    case 429:
      throw _responseMessage(response, locale.value.tooManyRequests);
    case 500:
      throw _responseMessage(response, locale.value.internalServerError);
    case 502:
      throw _responseMessage(response, locale.value.badGateway);
    case 503:
      throw _responseMessage(response, locale.value.serviceUnavailable);
    case 504:
      throw _responseMessage(response, locale.value.gatewayTimeout);
    default:
      throw _responseMessage(response, errorSomethingWentWrong);
  }
}

String _responseMessage(Response response, String fallback) {
  final raw = response.body.trim();
  if (raw.isEmpty) return fallback;
  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map && decoded['message'] is String) {
      final message = (decoded['message'] as String).trim();
      if (message.isNotEmpty) {
        return sanitizeBackendMessage(message, locale.value.somethingWentWrong);
      }
    }
  } on FormatException {
    // Non-JSON proxy/server errors use the localized fallback.
  }
  return fallback;
}

String? _responseCode(Response response) {
  final raw = response.body.trim();
  if (raw.isEmpty) return null;
  try {
    final decoded = jsonDecode(raw);
    return decoded is Map ? decoded['code']?.toString() : null;
  } on FormatException {
    return null;
  }
}

//region CommonFunctions
Future<Map<String, String>> getMultipartFields(
    {required Map<String, dynamic> val}) async {
  Map<String, String> data = {};

  val.forEach((key, value) {
    data[key] = '$value';
  });

  return data;
}

Future<MultipartRequest> getMultiPartRequest(String endPoint,
    {String? baseUrl}) async {
  String url = baseUrl ?? buildBaseUrl(endPoint).toString();
  // log(url);
  return MultipartRequest('POST', Uri.parse(url));
}

Future<void> sendMultiPartRequest(MultipartRequest multiPartRequest,
    {Function(dynamic)? onSuccess, Function(dynamic)? onError}) async {
  try {
    // MultipartRequest owns its boundary/content type. The shared JSON
    // headers are also used by normal requests, so remove that header here
    // before http builds the multipart body; otherwise Laravel sees an empty
    // request and returns its localized validation message.
    multiPartRequest.headers.remove(HttpHeaders.contentTypeHeader);
    final streamed = await multiPartRequest.send().timeout(_requestTimeout);
    final response = await http.Response.fromStream(streamed);
    apiPrint(
      url: multiPartRequest.url.toString(),
      statusCode: response.statusCode,
      methodtype: 'MultiPart',
    );
    if (response.statusCode.isSuccessful()) {
      await onSuccess?.call(response.body.trim());
      return;
    }
    if (response.statusCode == 409 &&
        _responseCode(response) == 'operation_pending') {
      throw const PendingCriticalOperationException('critical operation');
    }
    if (isAmbiguousMutatingStatus(response.statusCode)) {
      throw AmbiguousRequestOutcomeException(
        locale.value.unknownSubmitOutcomeBanner,
      );
    }
    if (response.statusCode == 401 && isLoggedIn.value) {
      await _expireSession();
      throw AuthenticationException(locale.value.signInFailed);
    }
    await onError?.call(
      _responseMessage(
        response,
        response.reasonPhrase ?? errorSomethingWentWrong,
      ),
    );
  } on TimeoutException {
    throw AmbiguousRequestOutcomeException(
      locale.value.requestTimedOutAfterSubmission,
    );
  } on SocketException {
    throw AmbiguousRequestOutcomeException(
      locale.value.unknownSubmitOutcomeBanner,
    );
  } on ClientException {
    throw AmbiguousRequestOutcomeException(
      locale.value.unknownSubmitOutcomeBanner,
    );
  } on AmbiguousRequestOutcomeException {
    rethrow;
  } on Exception catch (error) {
    await onError?.call(error);
  }
}

Future buildMultiPartResponse({
  required String endPoint,
  required Map<String, dynamic> request,
  Map<String, String>? header,
  List<File>? files,
  String? fileKey,
  bool isKeyRequireIndexing = false,
}) async {
  try {
    MultipartRequest multiPartRequest = await getMultiPartRequest(endPoint);
    multiPartRequest.headers.addAll(buildHeaderTokens());
    multiPartRequest.fields.addAll(await getMultipartFields(val: request));
    if (files != null && files.isNotEmpty) {
      final validFiles = files.where((file) => file.path.isNotEmpty).toList();
      for (var index = 0; index < validFiles.length; index++) {
        final key = validFiles.length > 1 || isKeyRequireIndexing
            ? '${fileKey}_$index'
            : '$fileKey';
        multiPartRequest.files.add(
          await MultipartFile.fromPath(key, validFiles[index].path),
        );
      }
    }

    final streamed = await multiPartRequest.send().timeout(_requestTimeout);
    final response = await Response.fromStream(streamed);

    apiPrint(
      url: multiPartRequest.url.toString(),
      headers: jsonEncode(multiPartRequest.headers),
      request: jsonEncode(multiPartRequest.fields),
      hasRequest: true,
      statusCode: response.statusCode,
      responseBody: response.body,
      methodtype: "MultiPart",
    );
    return await handleResponse(response);
  } on TimeoutException {
    throw AmbiguousRequestOutcomeException(
      locale.value.requestTimedOutAfterSubmission,
    );
  } on SocketException {
    throw AmbiguousRequestOutcomeException(
      locale.value.unknownSubmitOutcomeBanner,
    );
  } on Exception {
    rethrow;
  }
}

Future<List<MultipartFile>> getMultipartImages(
    {required List<PlatformFile> files, required String name}) async {
  List<MultipartFile> multiPartRequest = [];

  await Future.forEach<PlatformFile>(files, (element) async {
    int i = files.indexOf(element);

    multiPartRequest.add(await MultipartFile.fromPath(
        '$name[${i.toString()}]', element.path.validate()));
  });

  return multiPartRequest;
}

Future<List<MultipartFile>> getMultipartImages2(
    {required List<XFile> files, required String name}) async {
  List<MultipartFile> multiPartRequest = [];

  await Future.forEach<XFile>(files, (element) async {
    int i = files.indexOf(element);

    multiPartRequest.add(await MultipartFile.fromPath(
        '$name[${i.toString()}]', element.path.validate()));
    log('MultipartFile: $name[${i.toString()}]');
  });

  return multiPartRequest;
}

String parseStripeError(String response) {
  try {
    var body = jsonDecode(response);
    return parseHtmlString(body['error']['message']);
  } on Exception catch (e) {
    log(e);
    throw errorSomethingWentWrong;
  }
}

void apiPrint({
  String url = "",
  String endPoint = "",
  String headers = "",
  String request = "",
  int statusCode = 0,
  String responseBody = "",
  String methodtype = "",
  bool hasRequest = false,
  bool fullLog = false,
  String responseHeader = '',
}) {
  if (!kDebugMode) return;

  final parsedUrl = Uri.tryParse(url);
  if (parsedUrl != null) {
    url = parsedUrl.replace(query: null, fragment: null).toString();
  }
  // Transport diagnostics must never contain credentials, PII, medical data,
  // notification payloads, or payment responses.
  headers = '[redacted]';
  request = hasRequest ? '[redacted]' : '';
  responseBody = '[redacted]';
  responseHeader = '[redacted]';

  if (fullLog) {
    debugPrint(
        "┌───────────────────────────────────────────────────────────────────────────────────────────────────────");
    debugPrint("\u001b[93m Url: \u001B[39m $url");
    debugPrint("\u001b[93m endPoint: \u001B[39m \u001B[1m$endPoint\u001B[22m");
    debugPrint("\u001b[93m header: \u001B[39m \u001b[96m$headers\u001B[39m");
    if (hasRequest) {
      debugPrint('\u001b[93m Request: \u001B[39m \u001b[95m$request\u001B[39m');
    }
    debugPrint(statusCode.isSuccessful() ? "\u001b[32m" : "\u001b[31m");
    debugPrint(
        "\u001b[93m Response header: \u001B[39m \u001b[96m$responseHeader\u001B[39m");
    debugPrint(
        '\u001b[93m MethodType ($methodtype) | StatusCode ($statusCode)\u001B[39m');
    debugPrint('Response : ');
    debugPrint('\x1B[32m${formatJson(responseBody)}\x1B[0m');
    debugPrint("\u001B[0m");
    debugPrint(
        "└───────────────────────────────────────────────────────────────────────────────────────────────────────");
  } else {
    debugPrint(
        "┌───────────────────────────────────────────────────────────────────────────────────────────────────────");
    debugPrint("\u001b[93m Url: \u001B[39m $url");
    debugPrint("\u001b[93m endPoint: \u001B[39m \u001B[1m$endPoint\u001B[22m");
    debugPrint(
        "\u001b[93m header: \u001B[39m \u001b[96m${headers.split(',').join(',\n')}\u001B[39m");
    if (hasRequest) {
      debugPrint('\u001b[93m Request: \u001B[39m \u001b[95m$request\u001B[39m');
    }
    debugPrint(statusCode.isSuccessful() ? "\u001b[32m" : "\u001b[31m");
    debugPrint(
        '\u001b[93m MethodType ($methodtype) | statusCode: ($statusCode)\u001B[39m');
    debugPrint(
        "\u001b[93m Response header: \u001B[39m \u001b[96m$responseHeader\u001B[39m");
    debugPrint('\u001b[93m Response \u001B[39m');
    debugPrint(responseBody);
    debugPrint("\u001B[0m");
    debugPrint(
        "└───────────────────────────────────────────────────────────────────────────────────────────────────────");
  }
}

String formatJson(String jsonStr) {
  try {
    final dynamic parsedJson = jsonDecode(jsonStr);
    const formatter = JsonEncoder.withIndent('  ');
    return formatter.convert(parsedJson);
  } on Exception catch (e) {
    debugPrint("\x1b[31m formatJson error ::-> ${e.toString()} \x1b[0m");
    return jsonStr;
  }
}

Map<String, String> buildHeaderForStripe(String stripeKeyPayment) {
  Map<String, String> header = defaultHeaders();

  header.putIfAbsent(
      HttpHeaders.contentTypeHeader, () => 'application/x-www-form-urlencoded');
  header.putIfAbsent(
      HttpHeaders.authorizationHeader, () => 'Bearer $stripeKeyPayment');

  return header;
}

Map<String, String> buildHeaderForSadad({String? sadadToken}) {
  Map<String, String> header = defaultHeaders();

  header.putIfAbsent(HttpHeaders.contentTypeHeader, () => 'application/json');
  if (sadadToken != null) {
    header.putIfAbsent(HttpHeaders.authorizationHeader, () => sadadToken);
  }

  return header;
}

Map<String, String> buildHeaderForFlutterWave(String flutterWaveSecretKey) {
  Map<String, String> header = defaultHeaders();

  header.putIfAbsent(
      HttpHeaders.authorizationHeader, () => "Bearer $flutterWaveSecretKey");

  return header;
}

Map<String, String> buildHeaderForAirtelMoney(
    String accessToken, String xCountry, String xCurrency) {
  Map<String, String> header = defaultHeaders();

  header.putIfAbsent(
      HttpHeaders.contentTypeHeader, () => 'application/json; charset=utf-8');
  header.putIfAbsent(
      HttpHeaders.authorizationHeader, () => 'Bearer $accessToken');
  header.putIfAbsent('X-Country', () => xCountry);
  header.putIfAbsent('X-Currency', () => xCurrency);

  return header;
}

Map<String, String> defaultHeaders() {
  Map<String, String> header = {};

  header.putIfAbsent(HttpHeaders.cacheControlHeader, () => 'no-cache');
  header.putIfAbsent('Access-Control-Allow-Headers', () => '*');
  header.putIfAbsent('Access-Control-Allow-Origin', () => '*');

  return header;
}

Future<Map<String, dynamic>> handleSadadResponse(Response res) async {
  if (res.body.isJson()) {
    var body = jsonDecode(res.body);

    if (res.statusCode.isSuccessful()) {
      return body;
    } else {
      throw parseHtmlString(body['error']['message']);
    }
  } else {
    throw errorSomethingWentWrong;
  }
}
