import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TimingSelectorWidget extends StatefulWidget {
  final String title;
  final List<String> options;
  final String selectedOption;
  final ValueChanged<String> onChanged;

  const TimingSelectorWidget({
    Key? key,
    required this.title,
    required this.options,
    required this.selectedOption,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<TimingSelectorWidget> createState() => _TimingSelectorWidgetState();
}

class _TimingSelectorWidgetState extends State<TimingSelectorWidget> {
  late String _selectedOption;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.selectedOption;
  }

  void _showTimingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            widget.title,
            style: AppTheme.lightTheme.textTheme.titleMedium,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.options.map((option) {
              return RadioListTile<String>(
                title: Text(
                  option,
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
                value: option,
                groupValue: _selectedOption,
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      _selectedOption = value;
                    });
                    widget.onChanged(value);
                    Navigator.of(context).pop();
                  }
                },
                activeColor: AppTheme.lightTheme.colorScheme.primary,
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _showTimingDialog,
      borderRadius: BorderRadius.circular(2.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
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
                  SizedBox(height: 0.5.h),
                  Text(
                    _selectedOption,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 5.w,
            ),
          ],
        ),
      ),
    );
  }
}
