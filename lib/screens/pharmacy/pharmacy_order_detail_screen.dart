import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../components/app_scaffold.dart';
import '../../main.dart';
import '../../utils/colors.dart';
import '../../utils/app_common.dart';
import 'pharmacy_order_detail_controller.dart';

class PharmacyOrderDetailScreen extends StatelessWidget {
  const PharmacyOrderDetailScreen({super.key});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange.shade600;
      case 'confirmed': return Colors.blue.shade600;
      case 'out_for_delivery': return Colors.purple.shade600;
      case 'delivered': return Colors.green.shade600;
      case 'cancelled': return Colors.red.shade600;
      default: return secondaryTextColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PharmacyOrderDetailController>(
      init: PharmacyOrderDetailController(),
      builder: (controller) {
        return AppScaffold(
          appBarTitle: Text(locale.value.orderDetail),
          isLoading: controller.isLoading,
          body: Obx(() {
            if (controller.isLoading.value) return const SizedBox.shrink();
            final order = controller.order.value;
            if (order == null) {
              return Center(
                child: Text(locale.value.noData,
                    style: GoogleFonts.plusJakartaSans(fontSize: 14)),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pharmacy card
                  _infoCard(children: [
                    Row(
                      children: [
                        const Icon(Icons.local_pharmacy_rounded,
                            color: appColorPrimary, size: 22),
                        10.width,
                        Expanded(
                          child: Text(
                            order.pharmacy?.name ?? '',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDarkMode.value
                                  ? Colors.white
                                  : primaryTextColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusColor(order.status)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            order.status.replaceAll('_', ' ').toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _statusColor(order.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (order.pharmacy?.phone != null) ...[
                      8.height,
                      _metaRow(locale.value.phone, order.pharmacy!.phone!),
                    ],
                    if (order.pharmacy?.address != null) ...[
                      8.height,
                      _metaRow(locale.value.address, order.pharmacy!.address!),
                    ],
                  ]),
                  16.height,

                  // Order items
                  _sectionTitle(locale.value.orderItems),
                  8.height,
                  _infoCard(
                    children: order.items
                        .map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.productName,
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Text(
                                    '× ${item.quantity}',
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: secondaryTextColor),
                                  ),
                                  16.width,
                                  Text(
                                    item.lineTotal.toStringAsFixed(2),
                                    style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: appColorPrimary),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                  16.height,

                  // Pricing summary
                  _sectionTitle(locale.value.subtotal),
                  8.height,
                  _infoCard(children: [
                    _priceRow(locale.value.subtotal, order.subtotal),
                    8.height,
                    _priceRow(locale.value.deliveryFee, order.deliveryFee),
                    const Divider(height: 20),
                    _priceRow(locale.value.total, order.total, isBold: true),
                  ]),
                  16.height,

                  // Payment + address
                  _infoCard(children: [
                    _metaRow(locale.value.cashOnDelivery,
                        order.paymentMethod.replaceAll('_', ' ')),
                    if (order.address?.addressLine1 != null) ...[
                      8.height,
                      _metaRow(locale.value.selectDeliveryAddress,
                          '${order.address!.addressLine1}${order.address!.city != null ? ', ${order.address!.city}' : ''}'),
                    ],
                  ]),
                  24.height,

                  // Cancel button — only if pending
                  if (order.status == 'pending')
                    Obx(() => SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: controller.isCancelling.value
                                ? null
                                : () => controller.cancelOrder(context),
                            style: OutlinedButton.styleFrom(
                              side:
                                  BorderSide(color: Colors.red.shade400),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(14)),
                            ),
                            child: controller.isCancelling.value
                                ? const CircularProgressIndicator(
                                    strokeWidth: 2)
                                : Text(
                                    locale.value.cancelOrder,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: Colors.red.shade400,
                                    ),
                                  ),
                          ),
                        )),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Widget _infoCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode.value ? softShadowColorDark : softShadowColor,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(text,
        style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: isDarkMode.value ? Colors.white : primaryTextColor));
  }

  Widget _metaRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: secondaryTextColor)),
        Expanded(
          child: Text(value,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color:
                      isDarkMode.value ? Colors.white70 : primaryTextColor)),
        ),
      ],
    );
  }

  Widget _priceRow(String label, double amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
                color: isBold
                    ? (isDarkMode.value ? Colors.white : primaryTextColor)
                    : secondaryTextColor)),
        Text(amount.toStringAsFixed(2),
            style: GoogleFonts.outfit(
                fontSize: isBold ? 16 : 13,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
                color: isBold ? appColorPrimary : (isDarkMode.value ? Colors.white70 : primaryTextColor))),
      ],
    );
  }
}
