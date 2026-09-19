import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../api/icu_apis.dart';
import '../../../main.dart';
import '../components/status_chip.dart';
import '../models/admission_request_model.dart';
import '../models/icu_paginated_response.dart';
import 'admission_request_detail_screen.dart';

class AdmissionRequestListScreen extends StatefulWidget {
  const AdmissionRequestListScreen({super.key});

  @override
  State<AdmissionRequestListScreen> createState() =>
      _AdmissionRequestListScreenState();
}

class _AdmissionRequestListScreenState
    extends State<AdmissionRequestListScreen> {
  late Future<IcuPaginatedResponse<AdmissionRequest>> _requests;

  @override
  void initState() {
    super.initState();
    _requests = IcuApis.getAdmissionRequests();
  }

  Future<void> _reload() async {
    final next = IcuApis.getAdmissionRequests();
    setState(() => _requests = next);
    await next;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(locale.value.admissionDetails)),
      body: FutureBuilder<IcuPaginatedResponse<AdmissionRequest>>(
        future: _requests,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: TextButton.icon(
                onPressed: _reload,
                icon: const Icon(Icons.refresh),
                label: Text(locale.value.retry),
              ),
            );
          }

          final requests = snapshot.data!.data;
          if (requests.isEmpty) {
            return Center(child: Text(locale.value.noDataFound));
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              separatorBuilder: (_, __) => 12.height,
              itemBuilder: (context, index) {
                final request = requests[index];
                return Semantics(
                  button: true,
                  label: '${request.referenceNumber}, ${request.status.name}',
                  child: Card(
                    child: ListTile(
                      title: Text(request.referenceNumber),
                      subtitle: Text(request.hospital.name),
                      trailing: StatusChip(status: request.status),
                      onTap: () => Get.to(() =>
                          AdmissionRequestDetailScreen(requestId: request.id)),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
