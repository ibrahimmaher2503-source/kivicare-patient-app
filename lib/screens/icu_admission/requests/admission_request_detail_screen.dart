import 'package:flutter/material.dart';

class AdmissionRequestDetailScreen extends StatelessWidget {
  final int requestId;

  const AdmissionRequestDetailScreen({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ICU Request Detail')),
      body: Center(child: Text('Detail for request ID: $requestId')),
    );
  }
}
