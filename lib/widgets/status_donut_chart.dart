import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/constants/app_colors.dart';
import '../models/dashboard_model.dart';

class StatusDonutChart extends StatefulWidget {
  final List<Graph1StatusItem> statusList;

  const StatusDonutChart({
    super.key,
    required this.statusList,
  });

  @override
  State<StatusDonutChart> createState() => _StatusDonutChartState();
}

class _StatusDonutChartState extends State<StatusDonutChart> {
  int touchedIndex = -1;

  Color _getStatusColor(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('pending')) {
      return const Color(0xFFFF5376); // Vibrant Coral/Pink for Pending
    } else if (lower.contains('approved') || lower.contains('accepted')) {
      return AppColors.blue; // #2563EB for Approved/Accepted
    } else if (lower.contains('rejected')) {
      return const Color(0xFFEF4444);
    } else if (lower.contains('draft')) {
      return const Color(0xFF94A3B8);
    }
    return AppColors.cyanDark;
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.statusList.fold<int>(0, (sum, item) => sum + item.total);
    final hasData = total > 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.blueLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.pie_chart_outline_rounded,
                    color: AppColors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Quotation Status Distribution',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Breakdown of quotation statuses',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 16),

          // Donut Chart Body
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: hasData
                ? Column(
                    children: [
                      // Centered Donut with Total count in hole
                      SizedBox(
                        height: 170,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              PieChartData(
                                pieTouchData: PieTouchData(
                                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                    setState(() {
                                      if (!event.isInterestedForInteractions ||
                                          pieTouchResponse == null ||
                                          pieTouchResponse.touchedSection == null) {
                                        touchedIndex = -1;
                                        return;
                                      }
                                      touchedIndex = pieTouchResponse
                                          .touchedSection!.touchedSectionIndex;
                                    });
                                  },
                                ),
                                borderData: FlBorderData(show: false),
                                sectionsSpace: 3,
                                centerSpaceRadius: 50,
                                sections: List.generate(widget.statusList.length, (i) {
                                  final isTouched = i == touchedIndex;
                                  final radius = isTouched ? 28.0 : 22.0;
                                  final item = widget.statusList[i];
                                  final color = _getStatusColor(item.quotationStatus);

                                  return PieChartSectionData(
                                    color: color,
                                    value: item.total.toDouble(),
                                    title: '',
                                    radius: radius,
                                  );
                                }),
                              ),
                            ),
                            // Center Total text
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$total',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.navy,
                                  ),
                                ),
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Legends Grid/Wrap Below Donut
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 20,
                        runSpacing: 10,
                        children: widget.statusList.map((item) {
                          final color = _getStatusColor(item.quotationStatus);
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${item.quotationStatus} (${item.total})',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.navy,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  )
                : const SizedBox(
                    height: 120,
                    child: Center(
                      child: Text(
                        'No status data available',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
