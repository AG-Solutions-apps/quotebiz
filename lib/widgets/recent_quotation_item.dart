import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/dashboard_model.dart';

class RecentQuotationItem extends StatelessWidget {
  final QuotationItem item;

  const RecentQuotationItem({
    super.key,
    required this.item,
  });

  Color _getStatusBgColor(String? status) {
    final s = status?.toLowerCase() ?? '';
    if (s.contains('approved') || s.contains('accepted')) {
      return AppColors.successBg;
    } else if (s.contains('pending')) {
      return AppColors.warningBg;
    } else if (s.contains('rejected')) {
      return AppColors.dangerBg;
    }
    return AppColors.surfaceMuted;
  }

  Color _getStatusTextColor(String? status) {
    final s = status?.toLowerCase() ?? '';
    if (s.contains('approved') || s.contains('accepted')) {
      return const Color(0xFF047857);
    } else if (s.contains('pending')) {
      return const Color(0xFFB45309);
    } else if (s.contains('rejected')) {
      return const Color(0xFFB91C1C);
    }
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final ref = item.quotationRef ?? 'QT-${item.quotationNo ?? '0'}';
    final buyer = item.buyerName ?? 'Customer';
    final date = item.quotationDate ?? '';
    final amount = item.totalAmount ?? '0.00';
    final status = item.quotationStatus ?? 'Pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Document Icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: AppColors.blue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Quotation Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ref,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '$buyer • $date',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Amount & Status Badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '₹$amount',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusBgColor(status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: _getStatusTextColor(status),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
