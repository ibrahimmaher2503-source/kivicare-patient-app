import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kivicare_patient/network/network_utils.dart';
import 'package:kivicare_patient/screens/booking/model/appointments_res_model.dart';
import 'package:kivicare_patient/screens/booking/model/booking_req.dart';
import 'package:kivicare_patient/screens/doctor/model/doctor_list_res.dart';
import 'package:kivicare_patient/screens/service/model/service_list_model.dart';
import 'package:kivicare_patient/utils/common_base.dart';

void main() {
  test('independent booking uses its own identifiers and locale-safe time', () {
    final doctor = Doctor.fromJson({
      'id': 7,
      'doctor_id': 12,
      'is_independent': true,
    });
    final service = ServiceElement.fromJson({
      'id': 3,
      'charges': 250,
      'duration_min': 30,
    });
    final request = BookingReq(
      isIndependent: true,
      doctorId: doctor.id.toString(),
      independentServiceId: service.id.toString(),
      appointmentDate: '2026-09-01',
      appointmentTime: '09:30',
    ).toIndependentJson();

    expect(doctor.isIndependent, isTrue);
    expect(service.payableAmount, 250);
    expect(service.duration, 30);
    expect('09:30'.format24HourtoAMPM, '9:30 AM');
    expect(buildHeaderTokens()[HttpHeaders.acceptHeader], 'application/json');
    final appointment = AppointmentData.fromJson({
      'booking_type': 'independent',
      'independent_service_id': 3,
      'service_name': 'استشارة مستقلة',
    });
    expect(appointment.isIndependent, isTrue);
    expect(appointment.independentServiceId, 3);
    expect(appointment.serviceName, 'استشارة مستقلة');
    expect(request, {
      'doctor_id': '7',
      'independent_service_id': '3',
      'appointment_date': '2026-09-01',
      'appointment_time': '09:30',
      'transaction_type': 'cash',
    });
  });
}
