import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../api/auth_apis.dart';
import '../main.dart';
import '../screens/booking/appointment_detail_screen.dart';
import '../screens/booking/model/appointments_res_model.dart';
import '../screens/auth/other/notification_screen.dart';
import '../screens/doctor_visit/detail/visit_request_detail_screen.dart';
import '../screens/icu_admission/requests/admission_request_detail_screen.dart';
import '../screens/labs_radiology/orders/test_order_detail_screen.dart';
import '../screens/nurse_request/detail/nurse_request_detail_screen.dart';
import '../screens/pharmacy/order/pharmacy_order_detail_screen.dart';
import '../screens/incident_management/incident_management_list_screen.dart';
import '../screens/Encounter/all_encounters_screen.dart';
import '../screens/booking/encounter_detail_screen.dart';
import 'app_common.dart';
import 'common_base.dart';
import 'constants.dart';

enum PushNotificationRoute {
  appointment,
  nurseRequest,
  icuAdmission,
  pharmacyOrder,
  labOrder,
  doctorVisit,
  incident,
  encounter,
  notifications,
}

class PushNotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static bool _localNotificationsInitialized = false;
  static bool _listenersRegistered = false;
  static StreamSubscription<String>? _tokenRefreshSubscription;
  static String? _pendingRefreshedToken;
  static Map<String, dynamic>? _pendingNavigationData;
  static bool _navigationFlushScheduled = false;
  static bool _authStateReady = false;

  Future<void> setupFirebaseMessaging() async {
    await _initializeLocalNotifications();
    await initFirebaseMessaging();
    await enableIOSNotifications();
    _tokenRefreshSubscription ??=
        FirebaseMessaging.instance.onTokenRefresh.listen(
      (token) {
        // Firebase can refresh before the cached session/login is restored.
        // Keep the value and flush it on the next authenticated registration.
        _pendingRefreshedToken = token;
        if (isLoggedIn.value) unawaited(registerFCMAndTopics());
      },
      onError: (Object error) {
        if (kDebugMode) debugPrint('FCM token refresh failed: $error');
      },
    );
  }

  Future<void> initFirebaseMessaging() async {
    try {
      await registerNotificationListeners();
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Notification initialization failed: $error');
      }
    }
  }

  Future<bool> requestNotificationPermission() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      final allowed =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;
      if (allowed) {
        await setupFirebaseMessaging();
        await registerFCMAndTopics();
      }
      return allowed;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Notification permission request failed: $error');
      }
      return false;
    }
  }

  Future<void> registerFCMAndTopics() async {
    if (!isLoggedIn.value) return;
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        var apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken == null) {
          await Future<void>.delayed(const Duration(seconds: 3));
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        }
        if (apnsToken == null) return;
      }
      final token =
          _pendingRefreshedToken ?? await FirebaseMessaging.instance.getToken();
      if (token != null && token.trim().isNotEmpty) {
        await AuthServiceApis.updateProfile(playerId: token);
        _pendingRefreshedToken = null;
      }
      await subScribeToTopic();
      await _flushPendingNavigation();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Notification topic registration failed: $error');
      }
    }
  }

  Future<void> subScribeToTopic() async {
    await FirebaseMessaging.instance.subscribeToTopic(appNameTopic);
    await FirebaseMessaging.instance.subscribeToTopic(
      '${FirebaseTopicConst.userWithUnderscoreKey}${loginUserData.value.id}',
    );
  }

  Future<void> unsubscribeFirebaseTopic() async {
    if (loginUserData.value.id <= 0) return;
    await FirebaseMessaging.instance.unsubscribeFromTopic(appNameTopic);
    await FirebaseMessaging.instance.unsubscribeFromTopic(
      '${FirebaseTopicConst.userWithUnderscoreKey}${loginUserData.value.id}',
    );
  }

  Future<void> removeDeviceToken() async {
    if (!isLoggedIn.value) return;
    try {
      await AuthServiceApis.updateProfile(
        playerId: '',
        includePlayerId: true,
      );
      _pendingRefreshedToken = null;
    } catch (error) {
      if (kDebugMode) debugPrint('FCM token removal failed: $error');
    }
  }

  void clearPendingNavigation() {
    _pendingNavigationData = null;
  }

  /// The messaging listener can receive a cold-start payload before Flutter
  /// has restored the cached session and completed the splash route.  Marking
  /// this boundary explicitly prevents a notification tap from opening the
  /// login screen over the splash screen or navigating with stale auth state.
  void markAuthStateReady() {
    _authStateReady = true;
    if (!isLoggedIn.value) {
      _pendingNavigationData = null;
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_flushPendingNavigation());
    });
  }

  Future<void> handleNotificationClick(
    RemoteMessage message, {
    bool isForeGround = false,
  }) async {
    if (isForeGround) {
      final title = message.notification?.title ??
          message.data['title']?.toString() ??
          locale.value.notifications;
      final body =
          message.notification?.body ?? message.data['body']?.toString() ?? '';
      await showNotification(
        currentTimeStamp(),
        title,
        body,
        message.data,
      );
      return;
    }
    _queueNavigation(normalizeNotificationData(message.data));
  }

  static Map<String, dynamic> normalizeNotificationData(
    Map<String, dynamic> messageData,
  ) {
    final normalized = <String, dynamic>{...messageData};
    final rawAdditional = messageData[FirebaseTopicConst.additionalDataKey];
    if (rawAdditional is Map) {
      rawAdditional.forEach((key, value) {
        if (key is String) normalized[key] = value;
      });
    } else if (rawAdditional is String && rawAdditional.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(rawAdditional);
        if (decoded is Map) {
          decoded.forEach((key, value) {
            if (key is String) normalized[key] = value;
          });
        }
      } on FormatException {
        // Top-level message data is still usable.
      }
    }
    return normalized;
  }

  static PushNotificationRoute classifyNotificationRoute(
    Map<String, dynamic> messageData,
  ) {
    final data = normalizeNotificationData(messageData);
    final type = (data['type'] ?? data['notification_type'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    final requestId = _parseNotificationId(
      data['request_id'] ?? data['admission_request_id'] ?? data['id'],
    );
    if (type == 'nurse_request_status_changed' && requestId > 0) {
      return PushNotificationRoute.nurseRequest;
    }
    if (type == 'icu_admission_status_changed' && requestId > 0) {
      return PushNotificationRoute.icuAdmission;
    }

    final orderId = _parseNotificationId(data['order_id'] ?? data['id']);
    if ({
          'order_update',
          'pharmacy_order_status_changed',
          'pharmacy_order_update',
        }.contains(type) &&
        orderId > 0) {
      return PushNotificationRoute.pharmacyOrder;
    }

    final testOrderId = testOrderIdFromNotification(data);
    if ({
          'test_order_status_changed',
          'test_order_update',
          'lab_order_status_changed',
          'radiology_order_status_changed',
        }.contains(type) &&
        testOrderId > 0) {
      return PushNotificationRoute.labOrder;
    }

    final visitReference = _firstNotificationString(data, const [
      'reference_number',
      'visit_reference',
      'request_reference',
    ]);
    if ({
          'doctor_visit_status_changed',
          'doctor_home_visit_status_changed',
          'home_visit_status_changed',
        }.contains(type) &&
        visitReference != null) {
      return PushNotificationRoute.doctorVisit;
    }

    if (type == NotificationConst.incidence_reply ||
        type == 'incident_status_changed') {
      return PushNotificationRoute.incident;
    }

    if ({
      'encounter_status_changed',
      'encounter_update',
      'medical_report_ready',
      'encounter_report_ready',
      'report_ready',
    }.contains(type)) {
      return PushNotificationRoute.encounter;
    }

    final appointmentId = _parseNotificationId(data[FirebaseTopicConst.idKey]);
    if ({
          NotificationConst.newAppointment,
          NotificationConst.checkoutAppointment,
          NotificationConst.rejectAppointment,
          NotificationConst.cancelAppointment,
          NotificationConst.rescheduleAppointment,
          NotificationConst.acceptAppointment,
          NotificationConst.quickAppointment,
          'appointment_status_changed',
        }.contains(type) &&
        appointmentId > 0) {
      return PushNotificationRoute.appointment;
    }
    return PushNotificationRoute.notifications;
  }

  static int _parseNotificationId(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int testOrderIdFromNotification(Map<String, dynamic> messageData) {
    final data = normalizeNotificationData(messageData);
    return _parseNotificationId(
      data['test_order_id'] ?? data['order_id'] ?? data['id'],
    );
  }

  static String? _firstNotificationString(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = data[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  void _navigateFromData(Map<String, dynamic> data) {
    final route = classifyNotificationRoute(data);
    final requestId = _parseId(
        data['request_id'] ?? data['admission_request_id'] ?? data['id']);
    if (route == PushNotificationRoute.nurseRequest) {
      Get.to(() => NurseRequestDetailScreen(requestId: requestId));
      return;
    }
    if (route == PushNotificationRoute.icuAdmission) {
      Get.to(() => AdmissionRequestDetailScreen(requestId: requestId));
      return;
    }

    final orderId = _parseId(data['order_id'] ?? data['id']);
    if (route == PushNotificationRoute.pharmacyOrder) {
      Get.to(() => PharmacyOrderDetailScreen(orderId: orderId));
      return;
    }

    final testOrderId = testOrderIdFromNotification(data);
    if (route == PushNotificationRoute.labOrder) {
      Get.to(() => TestOrderDetailScreen(orderId: testOrderId));
      return;
    }

    final visitReference = _firstNonEmptyString(data, const [
      'reference_number',
      'visit_reference',
      'request_reference',
    ]);
    if (route == PushNotificationRoute.doctorVisit) {
      Get.to(() => VisitRequestDetailScreen(referenceNumber: visitReference!));
      return;
    }

    if (route == PushNotificationRoute.incident) {
      Get.to(() => IncidentManagementListScreen());
      return;
    }

    final encounterId = _parseId(
      data['encounter_id'] ?? data['patient_encounter_id'] ?? data['id'],
    );
    if (route == PushNotificationRoute.encounter) {
      if (encounterId > 0) {
        Get.to(() => EncounterDetailScreen(), arguments: encounterId);
      } else {
        Get.to(() => AllEncountersScreen());
      }
      return;
    }

    final appointmentId = _parseId(data[FirebaseTopicConst.idKey]);
    if (route == PushNotificationRoute.appointment) {
      Get.to(
        () => AppointmentDetail(),
        arguments: AppointmentData(id: appointmentId),
      );
      return;
    }
    Get.to(() => NotificationScreen());
  }

  void _queueNavigation(Map<String, dynamic> data) {
    _pendingNavigationData = data;
    if (_navigationFlushScheduled) return;
    _navigationFlushScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigationFlushScheduled = false;
      unawaited(_flushPendingNavigation());
    });
  }

  Future<void> _flushPendingNavigation() async {
    final data = _pendingNavigationData;
    if (data == null) return;
    if (!_authStateReady) return;
    if (Get.context == null) {
      _queueNavigation(data);
      return;
    }

    final authenticated = await requireAuthenticated();
    if (!authenticated) return;
    if (!identical(data, _pendingNavigationData)) return;
    _pendingNavigationData = null;
    _navigateFromData(data);
  }

  int _parseId(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String? _firstNonEmptyString(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = data[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  Future<void> registerNotificationListeners() async {
    if (_listenersRegistered) return;
    _listenersRegistered = true;

    FirebaseMessaging.onMessage.listen(
      (message) => handleNotificationClick(message, isForeGround: true),
      onError: (Object error) {
        if (kDebugMode) debugPrint('Foreground notification error: $error');
      },
    );
    FirebaseMessaging.onMessageOpenedApp.listen(
      handleNotificationClick,
      onError: (Object error) {
        if (kDebugMode) debugPrint('Notification open error: $error');
      },
    );
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _queueNavigation(normalizeNotificationData(initialMessage.data));
    }
  }

  Future<void> _initializeLocalNotifications() async {
    if (_localNotificationsInitialized || kIsWeb) return;

    const android =
        AndroidInitializationSettings('@drawable/ic_stat_notification');
    const darwin = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    const settings = InitializationSettings(
      android: android,
      iOS: darwin,
      macOS: darwin,
    );
    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        _queueLocalNotificationPayload(response.payload);
      },
    );

    // The response callback is not delivered when Android launches a
    // terminated app from a local notification. Read that payload once after
    // plugin initialization and let the same auth/router gate handle it.
    final launchDetails =
        await _localNotifications.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true) {
      _queueLocalNotificationPayload(
          launchDetails?.notificationResponse?.payload);
    }

    const channel = AndroidNotificationChannel(
      FirebaseTopicConst.notificationChannelIdKey,
      FirebaseTopicConst.notificationChannelNameKey,
      importance: Importance.high,
      enableLights: true,
      playSound: true,
      showBadge: true,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    _localNotificationsInitialized = true;
  }

  void _queueLocalNotificationPayload(String? payload) {
    if (payload == null || payload.isEmpty) return;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map) {
        _queueNavigation(
          normalizeNotificationData(decoded.cast<String, dynamic>()),
        );
      }
    } on FormatException {
      // Ignore malformed local payloads.
    }
  }

  Future<void> showNotification(
    int id,
    String title,
    String message,
    Map<String, dynamic> data,
  ) async {
    await _initializeLocalNotifications();
    if (kIsWeb) return;

    const android = AndroidNotificationDetails(
      FirebaseTopicConst.notificationChannelIdKey,
      FirebaseTopicConst.notificationChannelNameKey,
      importance: Importance.high,
      visibility: NotificationVisibility.private,
      autoCancel: true,
      playSound: true,
      priority: Priority.high,
      icon: '@drawable/ic_stat_notification',
      channelShowBadge: true,
    );
    const darwin = DarwinNotificationDetails(
      presentSound: true,
      presentBanner: true,
      presentBadge: true,
    );
    const details = NotificationDetails(
      android: android,
      iOS: darwin,
      macOS: darwin,
    );
    await _localNotifications.show(
      id,
      title,
      message,
      details,
      payload: jsonEncode(data),
    );
  }

  Future<void> enableIOSNotifications() {
    return FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}
