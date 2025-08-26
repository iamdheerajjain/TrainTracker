import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TrainCardWidget extends StatelessWidget {
  final Map<String, dynamic> trainData;
  final VoidCallback onTap;
  final VoidCallback onFavoritePressed;
  final VoidCallback onAlertPressed;
  final VoidCallback onSharePressed;

  const TrainCardWidget({
    Key? key,
    required this.trainData,
    required this.onTap,
    required this.onFavoritePressed,
    required this.onAlertPressed,
    required this.onSharePressed,
  }) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'on time':
        return AppTheme.onTimeGreen;
      case 'delayed':
        return AppTheme.moderateDelayAmber;
      case 'cancelled':
        return AppTheme.delayedRed;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String trainNumber = trainData['trainNumber'] ?? '';
    final String trainName = trainData['trainName'] ?? '';
    final String departureTime = trainData['departureTime'] ?? '';
    final String arrivalTime = trainData['arrivalTime'] ?? '';
    final String duration = trainData['duration'] ?? '';
    final String status = trainData['status'] ?? 'Unknown';
    final String delay = trainData['delay'] ?? '';
    final List<dynamic> classes = trainData['classes'] ?? [];
    final bool isFavorite = trainData['isFavorite'] ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Train Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trainNumber,
                        style: AppTheme.dataTextStyle(
                          isLight: true,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        trainName,
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onFavoritePressed,
                  child: Container(
                    padding: EdgeInsets.all(1.5.w),
                    child: CustomIconWidget(
                      iconName: isFavorite ? 'favorite' : 'favorite_border',
                      color: isFavorite
                          ? AppTheme.delayedRed
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Time and Duration Row
            Row(
              children: [
                // Departure Time
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        departureTime,
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Departure',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Duration
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.primaryColor
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          duration,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.outline,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrival Time
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        arrivalTime,
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Arrival',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Status and Classes Row
            Row(
              children: [
                // Status
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getStatusColor(status),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getStatusColor(status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        status,
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: _getStatusColor(status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (delay.isNotEmpty) ...[
                        SizedBox(width: 1.w),
                        Text(
                          '($delay)',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: _getStatusColor(status),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const Spacer(),

                // Classes
                if (classes.isNotEmpty)
                  Row(
                    children: classes.take(3).map((classInfo) {
                      final Map<String, dynamic> classData =
                          classInfo as Map<String, dynamic>;
                      final String className = classData['name'] ?? '';
                      final bool isAvailable = classData['available'] ?? false;

                      return Container(
                        margin: EdgeInsets.only(left: 1.w),
                        padding: EdgeInsets.symmetric(
                            horizontal: 1.5.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? AppTheme.onTimeGreen.withValues(alpha: 0.1)
                              : AppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isAvailable
                                ? AppTheme.onTimeGreen
                                : AppTheme.lightTheme.colorScheme.outline,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          className,
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: isAvailable
                                ? AppTheme.onTimeGreen
                                : AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                            fontSize: 9.sp,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),

            // Quick Actions (Hidden by default, shown on swipe)
            SizedBox(height: 1.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickAction(
                  icon: 'notifications',
                  label: 'Set Alert',
                  onTap: onAlertPressed,
                ),
                _buildQuickAction(
                  icon: 'share',
                  label: 'Share',
                  onTap: onSharePressed,
                ),
                _buildQuickAction(
                  icon: 'info',
                  label: 'Details',
                  onTap: onTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: AppTheme.lightTheme.primaryColor,
              size: 16,
            ),
            SizedBox(width: 1.w),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: AppTheme.lightTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
