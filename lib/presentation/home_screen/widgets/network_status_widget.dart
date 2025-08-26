import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NetworkStatusWidget extends StatelessWidget {
  final bool isOnline;
  final DateTime? lastSyncTime;

  const NetworkStatusWidget({
    Key? key,
    required this.isOnline,
    this.lastSyncTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isOnline) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      color: AppTheme.moderateDelayAmber.withValues(alpha: 0.1),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'wifi_off',
            color: AppTheme.moderateDelayAmber,
            size: 16,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              lastSyncTime != null
                  ? 'Offline - Last updated: ${_formatTime(lastSyncTime!)}'
                  : 'Offline - Using cached data',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.moderateDelayAmber,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${time.day}/${time.month} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
