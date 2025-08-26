import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class NotificationToggleWidget extends StatefulWidget {
  final String title;
  final String? subtitle;
  final bool initialValue;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  const NotificationToggleWidget({
    Key? key,
    required this.title,
    this.subtitle,
    required this.initialValue,
    required this.onChanged,
    this.showDivider = true,
  }) : super(key: key);

  @override
  State<NotificationToggleWidget> createState() =>
      _NotificationToggleWidgetState();
}

class _NotificationToggleWidgetState extends State<NotificationToggleWidget> {
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (widget.subtitle != null) ...[
                      SizedBox(height: 0.5.h),
                      Text(
                        widget.subtitle!,
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Switch(
                value: _isEnabled,
                onChanged: (value) {
                  setState(() {
                    _isEnabled = value;
                  });
                  widget.onChanged(value);
                },
                activeColor: AppTheme.lightTheme.colorScheme.primary,
                inactiveThumbColor:
                    AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                inactiveTrackColor: AppTheme
                    .lightTheme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
        if (widget.showDivider)
          Divider(
            height: 1,
            thickness: 0.5,
            color: AppTheme.lightTheme.dividerColor.withValues(alpha: 0.3),
            indent: 4.w,
            endIndent: 4.w,
          ),
      ],
    );
  }
}
