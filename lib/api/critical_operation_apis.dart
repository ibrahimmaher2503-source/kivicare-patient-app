import '../network/critical_operation.dart';
import '../network/network_utils.dart';
import '../utils/api_end_points.dart';
import 'package:nb_utils/nb_utils.dart';

/// Server-side reconciliation for a mutation whose response was lost.
abstract final class CriticalOperationApis {
  static Future<Map<String, dynamic>> status({
    required String operation,
    required String operationKey,
  }) async {
    final endpoint = endpointWithQuery(APIEndPoints.idempotencyStatus, {
      'operation': operation,
    });
    final response = await buildHttpResponse(
      endpoint,
      method: HttpMethodType.GET,
      header: {
        ...buildHeaderTokens(),
        ...criticalOperationHeaders(operationKey),
      },
    );

    final data = await handleResponse(response);
    if (data is! Map) {
      throw const NetworkRequestException('Invalid operation status response.');
    }
    return data.cast<String, dynamic>();
  }
}
