import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TrainHeaderCard extends StatelessWidget {
  final Map<String, dynamic> trainData;

  const TrainHeaderCard({
    Key? key,
    required this.trainData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String status = trainData['status'] ?? 'Unknown';
    final String delay = trainData['delay'] ?? '0';
    final bool isDelayed = int.tryParse(delay) != null && int.parse(delay) > 0;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${trainData['number']} - ${trainData['name']}',
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.lightTheme.primaryColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              trainData['source'] ?? '',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 2.w),
                            child: CustomIconWidget(
                              iconName: 'arrow_forward',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              trainData['destination'] ?? '',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.end,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getStatusColor(status).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      _getStatusText(status, delay),
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: _getStatusColor(status),
                      ),
                    ),
                  ),
                  if (isDelayed) ...[
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: AppTheme.delayedRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '+$delay min',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.delayedRed,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Departure',
                    trainData['departureTime'] ?? '--:--',
                    trainData['departureDate'] ?? '',
                  ),
                ),
                Container(
                  width: 1,
                  height: 4.h,
                  color: AppTheme.lightTheme.dividerColor,
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Arrival',
                    trainData['arrivalTime'] ?? '--:--',
                    trainData['arrivalDate'] ?? '',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String time, String date) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Column(
        children: [
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            time,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (date.isNotEmpty) ...[
            SizedBox(height: 0.2.h),
            Text(
              date,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'running':
      case 'on time':
        return AppTheme.onTimeGreen;
      case 'delayed':
      case 'late':
        return AppTheme.moderateDelayAmber;
      case 'cancelled':
      case 'terminated':
        return AppTheme.cancelledGray;
      case 'not started':
        return AppTheme.lightTheme.primaryColor;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  String _getStatusText(String status, String delay) {
    final int delayMinutes = int.tryParse(delay) ?? 0;

    switch (status.toLowerCase()) {
      case 'running':
        return delayMinutes > 0 ? 'Running Late' : 'Running On Time';
      case 'on time':
        return 'On Time';
      case 'delayed':
      case 'late':
        return 'Delayed';
      case 'cancelled':
        return 'Cancelled';
      case 'terminated':
        return 'Terminated';
      case 'not started':
        return 'Not Started';
      default:
        return status;
    }
  }
}
