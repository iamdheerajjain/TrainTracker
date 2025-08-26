import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LiveTrackingSection extends StatelessWidget {
  final List<Map<String, dynamic>> stations;
  final int currentStationIndex;
  final VoidCallback? onStationLongPress;

  const LiveTrackingSection({
    Key? key,
    required this.stations,
    required this.currentStationIndex,
    this.onStationLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'location_on',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Live Tracking',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            constraints: BoxConstraints(
              maxHeight: 50.h,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: stations.length,
              itemBuilder: (context, index) {
                final station = stations[index];
                final bool isCompleted = index < currentStationIndex;
                final bool isCurrent = index == currentStationIndex;
                final bool isUpcoming = index > currentStationIndex;

                return GestureDetector(
                  onLongPress: onStationLongPress,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    child: Row(
                      children: [
                        // Timeline indicator
                        SizedBox(
                          width: 8.w,
                          child: Column(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: _getStationColor(
                                      isCompleted, isCurrent, isUpcoming),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _getStationColor(
                                        isCompleted, isCurrent, isUpcoming),
                                    width: 2,
                                  ),
                                ),
                                child: isCurrent
                                    ? Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      )
                                    : null,
                              ),
                              if (index < stations.length - 1)
                                Container(
                                  width: 2,
                                  height: 4.h,
                                  color: isCompleted
                                      ? AppTheme.onTimeGreen
                                      : AppTheme.lightTheme.dividerColor,
                                ),
                            ],
                          ),
                        ),
                        SizedBox(width: 3.w),
                        // Station info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      station['name'] ?? '',
                                      style: AppTheme
                                          .lightTheme.textTheme.titleMedium
                                          ?.copyWith(
                                        fontWeight: isCurrent
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: isCurrent
                                            ? AppTheme.lightTheme.primaryColor
                                            : AppTheme.lightTheme.colorScheme
                                                .onSurface,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isCurrent)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 2.w, vertical: 0.5.h),
                                      decoration: BoxDecoration(
                                        color: AppTheme.lightTheme.primaryColor
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Current',
                                        style: AppTheme
                                            .lightTheme.textTheme.bodySmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color:
                                              AppTheme.lightTheme.primaryColor,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 0.5.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTimeInfo(
                                      'Scheduled',
                                      station['scheduledTime'] ?? '--:--',
                                      false,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Expanded(
                                    child: _buildTimeInfo(
                                      'Actual',
                                      station['actualTime'] ?? '--:--',
                                      true,
                                    ),
                                  ),
                                  if (station['delay'] != null &&
                                      station['delay'] != '0')
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 2.w, vertical: 0.5.h),
                                      decoration: BoxDecoration(
                                        color: AppTheme.delayedRed
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '+${station['delay']}m',
                                        style: AppTheme
                                            .lightTheme.textTheme.bodySmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.delayedRed,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              if (station['platform'] != null) ...[
                                SizedBox(height: 0.5.h),
                                Text(
                                  'Platform: ${station['platform']}',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo(String label, String time, bool isActual) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 0.2.h),
        Text(
          time,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isActual && time != '--:--'
                ? AppTheme.lightTheme.primaryColor
                : AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Color _getStationColor(bool isCompleted, bool isCurrent, bool isUpcoming) {
    if (isCompleted) {
      return AppTheme.onTimeGreen;
    } else if (isCurrent) {
      return AppTheme.lightTheme.primaryColor;
    } else {
      return AppTheme.lightTheme.dividerColor;
    }
  }
}
