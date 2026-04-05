import 'package:flutter/material.dart';
import 'package:kivicare_patient/models/lab_test_model.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/price_widget.dart';
import 'package:nb_utils/nb_utils.dart';

class OrderSummarySection extends StatelessWidget {
  final List<LabTest> selectedTests;
  final double totalAmount;
  final double discountAmount;
  final double finalAmount;
  final Function(int) onRemoveTest;

  const OrderSummarySection({
    Key? key,
    required this.selectedTests,
    required this.totalAmount,
    required this.discountAmount,
    required this.finalAmount,
    required this.onRemoveTest,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appStore.isDarkMode ? cardDarkColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: appStore.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Order Summary',
              style: boldTextStyle(size: 14),
            ),
          ),
          const Divider(height: 1),
          // Selected tests list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: selectedTests.length,
            itemBuilder: (context, index) {
              final test = selectedTests[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            test.name,
                            style: primaryTextStyle(size: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            test.sampleType,
                            style: secondaryTextStyle(size: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    PriceWidget(
                      price: test.defaultPrice,
                      textStyle: boldTextStyle(size: 12, color: appColorPrimary),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => onRemoveTest(test.id),
                      child: Icon(Icons.close, size: 20, color: Colors.cancelStatusColor.shade400),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 1),
          // Price breakdown
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _PriceRow(
                  label: 'Subtotal',
                  amount: totalAmount,
                  isBold: false,
                ),
                if (discountAmount > 0) ...[
                  const SizedBox(height: 8),
                  _PriceRow(
                    label: 'Discount',
                    amount: -discountAmount,
                    isBold: false,
                    color: Colors.green,
                  ),
                ],
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: _PriceRow(
                    label: 'Total Amount',
                    amount: finalAmount,
                    isBold: true,
                    color: appColorPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isBold;
  final Color? color;

  const _PriceRow({
    required this.label,
    required this.amount,
    this.isBold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: (isBold ? boldTextStyle : primaryTextStyle)(size: 12),
        ),
        PriceWidget(
          price: amount.abs(),
          textStyle: (isBold ? boldTextStyle : primaryTextStyle)(
            size: 12,
            color: color,
          ),
          prefix: amount < 0 ? '-' : '',
        ),
      ],
    );
  }
}
