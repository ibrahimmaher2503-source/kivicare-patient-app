import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../api/critical_operation_apis.dart';
import '../main.dart';
import '../utils/colors.dart';

class OperationVerificationScreen extends StatefulWidget {
  final Widget Function()? recordsScreen;
  final String? operationType;
  final String? operationKey;

  const OperationVerificationScreen({
    super.key,
    this.recordsScreen,
    this.operationType,
    this.operationKey,
  });

  @override
  State<OperationVerificationScreen> createState() =>
      _OperationVerificationScreenState();
}

class _OperationVerificationScreenState
    extends State<OperationVerificationScreen> {
  late Future<Map<String, dynamic>?> _statusFuture;

  @override
  void initState() {
    super.initState();
    _statusFuture = _lookup();
  }

  Future<Map<String, dynamic>?> _lookup() async {
    final type = widget.operationType?.trim();
    final key = widget.operationKey?.trim();
    if (type == null || type.isEmpty || key == null || key.isEmpty) return null;

    try {
      final response = await CriticalOperationApis.status(
        operation: type,
        operationKey: key,
      );
      return response['data'] is Map
          ? (response['data'] as Map).cast<String, dynamic>()
          : null;
    } catch (_) {
      return null;
    }
  }

  void retryLookup() {
    setState(() => _statusFuture = _lookup());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(locale.value.verify)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.manage_search_rounded,
                size: 72,
                color: appColorPrimary,
              ),
              24.height,
              FutureBuilder<Map<String, dynamic>?>(
                future: _statusFuture,
                builder: (context, snapshot) {
                  final operationStatus = snapshot.data?['status']?.toString();
                  final message = switch (operationStatus) {
                    'completed' => locale.value.requestSubmittedSuccessfully,
                    'failed' => locale.value.failed,
                    'processing' => locale.value.pending,
                    _ => locale.value.unknownSubmitOutcomeBanner,
                  };
                  return Semantics(
                    liveRegion: true,
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: primaryTextStyle(size: 18),
                    ),
                  );
                },
              ),
              if (widget.operationType != null && widget.operationKey != null) ...[
                16.height,
                TextButton.icon(
                  onPressed: retryLookup,
                  icon: const Icon(Icons.refresh),
                  label: Text(locale.value.retry),
                ),
              ],
              if (widget.recordsScreen != null) ...[
                32.height,
                AppButton(
                  width: double.infinity,
                  color: appColorPrimary,
                  text: locale.value.viewAll,
                  onTap: () => Get.off(widget.recordsScreen!),
                ),
              ],
              12.height,
              TextButton(
                onPressed: Get.back,
                child: Text(locale.value.cancel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
