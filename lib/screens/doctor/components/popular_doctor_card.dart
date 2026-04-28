import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../doctor_detail_screen.dart';
import '../model/doctor_list_res.dart';
import '../../../components/cached_image_widget.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';

class PopularDoctorCard extends StatelessWidget {
  const PopularDoctorCard({super.key, required this.doctorElement, this.isFromClinicDetail = false});

  final Doctor doctorElement;
  final bool isFromClinicDetail;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => DoctorDetailScreen(), arguments: doctorElement);
      },
      child: Container(
        decoration: boxDecorationDefault(color: context.cardColor, borderRadius: radius(16)),
        width: Get.width / 2 - 24,
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CachedImageWidget(
                  url: doctorElement.profileImage,
                  circle: true,
                  height: 72,
                  width: 72,
                  fit: BoxFit.cover,
                ),
                10.height,

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      doctorElement.fullName,
                      style: boldTextStyle(size: 16),
                    ),
                    4.width,
                    Icon(Icons.circle, color: colorStatusOnline, size: 12),
                  ],
                ),
                4.height,
                Text(
                  doctorElement.expert,
                  style: secondaryTextStyle(size: 12),
                ),
                10.height,

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...List.generate(5, (index) {
                      double rating = doctorElement.averageRating.toDouble();
                      if (index < rating.floor()) {
                        return const Icon(Icons.star, color: ratingColorFilled, size: 20);
                      } else if (index < rating && rating - index >= 0.5) {
                        return const Icon(Icons.star_half, color: ratingColorFilled, size: 20);
                      } else {
                        return const Icon(Icons.star_border, color: ratingColorEmpty, size: 20);
                      }
                    }),
                    const SizedBox(width: 4),
                    Text(
                      '${doctorElement.totalReviews}',
                      style: primaryTextStyle(),
                    ),
                  ],
                ),

                10.height,
                Obx(() => Text(
                  '${doctorElement.totalAppointmemt} ${locale.value.patientServed}',
                  style: primaryTextStyle(color: colorPatientMetric),
                )),
              ],
            ).paddingSymmetric(horizontal: 12, vertical: 12),
          ],
        ),
      ),
    );
  }
}