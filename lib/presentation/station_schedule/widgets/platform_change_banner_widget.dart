import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PlatformChangeBannerWidget extends StatelessWidget {
  final String trainNumber;
  final String oldPlatform;
  final String newPlatform;
  final VoidCallback onDismiss;

  const PlatformChangeBannerWidget({
    Key? key,
    required this.trainNumber,
    required this.oldPlatform,
    required this.newPlatform,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.delayedRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.delayedRed,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.delayedRed,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: 'warning',
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Platform Changed',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    color: AppTheme.delayedRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                RichText(
                  text: TextSpan(
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                    children: [
                      TextSpan(text: '$trainNumber moved from Platform '),
                      TextSpan(
                        text: oldPlatform,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      TextSpan(text: ' to Platform '),
                      TextSpan(
                        text: newPlatform,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.delayedRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Container(
              padding: EdgeInsets.all(1.w),
              decoration: BoxDecoration(
                color: AppTheme.delayedRed.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: CustomIconWidget(
                iconName: 'close',
                color: AppTheme.delayedRed,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
