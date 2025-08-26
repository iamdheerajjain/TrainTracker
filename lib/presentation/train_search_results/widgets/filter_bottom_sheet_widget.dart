import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final List<String> selectedFilters;
  final Function(List<String>) onFiltersChanged;

  const FilterBottomSheetWidget({
    Key? key,
    required this.selectedFilters,
    required this.onFiltersChanged,
  }) : super(key: key);

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late List<String> _tempSelectedFilters;
  String _selectedTrainType = 'all';
  RangeValues _departureTimeRange = const RangeValues(0, 24);
  double _maxDuration = 24;

  @override
  void initState() {
    super.initState();
    _tempSelectedFilters = List.from(widget.selectedFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: 1.h),
            width: 12.w,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Text(
                  'Filter & Sort',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearAllFilters,
                  child: Text(
                    'Clear All',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.lightTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
            height: 1,
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Train Type Filter
                  _buildSectionTitle('Train Type'),
                  SizedBox(height: 2.h),
                  _buildTrainTypeFilter(),

                  SizedBox(height: 4.h),

                  // Departure Time Filter
                  _buildSectionTitle('Departure Time'),
                  SizedBox(height: 2.h),
                  _buildDepartureTimeFilter(),

                  SizedBox(height: 4.h),

                  // Duration Filter
                  _buildSectionTitle('Maximum Duration'),
                  SizedBox(height: 2.h),
                  _buildDurationFilter(),

                  SizedBox(height: 4.h),

                  // Sort Options
                  _buildSectionTitle('Sort By'),
                  SizedBox(height: 2.h),
                  _buildSortOptions(),
                ],
              ),
            ),
          ),

          // Bottom Actions
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    child: Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTrainTypeFilter() {
    final List<Map<String, String>> trainTypes = [
      {'value': 'all', 'label': 'All Trains'},
      {'value': 'express', 'label': 'Express'},
      {'value': 'superfast', 'label': 'Superfast'},
      {'value': 'passenger', 'label': 'Passenger'},
      {'value': 'mail', 'label': 'Mail/Express'},
    ];

    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: trainTypes.map((type) {
        final isSelected = _selectedTrainType == type['value'];
        return GestureDetector(
          onTap: () => setState(() => _selectedTrainType = type['value']!),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.outline,
              ),
            ),
            child: Text(
              type['label']!,
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? Colors.white
                    : AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDepartureTimeFilter() {
    return Column(
      children: [
        RangeSlider(
          values: _departureTimeRange,
          min: 0,
          max: 24,
          divisions: 24,
          labels: RangeLabels(
            '${_departureTimeRange.start.round()}:00',
            '${_departureTimeRange.end.round()}:00',
          ),
          onChanged: (values) => setState(() => _departureTimeRange = values),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_departureTimeRange.start.round()}:00',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '${_departureTimeRange.end.round()}:00',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDurationFilter() {
    return Column(
      children: [
        Slider(
          value: _maxDuration,
          min: 1,
          max: 48,
          divisions: 47,
          label: '${_maxDuration.round()}h',
          onChanged: (value) => setState(() => _maxDuration = value),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '1h',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '${_maxDuration.round()}h',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '48h',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSortOptions() {
    final List<Map<String, String>> sortOptions = [
      {'value': 'departure', 'label': 'Departure Time'},
      {'value': 'duration', 'label': 'Duration'},
      {'value': 'arrival', 'label': 'Arrival Time'},
    ];

    return Column(
      children: sortOptions.map((option) {
        final isSelected = _tempSelectedFilters.contains(option['value']);
        return GestureDetector(
          onTap: () => _toggleSortOption(option['value']!),
          child: Container(
            margin: EdgeInsets.only(bottom: 1.h),
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1)
                  : AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: isSelected
                      ? 'radio_button_checked'
                      : 'radio_button_unchecked',
                  color: isSelected
                      ? AppTheme.lightTheme.primaryColor
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Text(
                  option['label']!,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? AppTheme.lightTheme.primaryColor
                        : AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _toggleSortOption(String option) {
    setState(() {
      if (_tempSelectedFilters.contains(option)) {
        _tempSelectedFilters.remove(option);
      } else {
        _tempSelectedFilters.add(option);
      }
    });
  }

  void _clearAllFilters() {
    setState(() {
      _tempSelectedFilters.clear();
      _selectedTrainType = 'all';
      _departureTimeRange = const RangeValues(0, 24);
      _maxDuration = 24;
    });
  }

  void _applyFilters() {
    widget.onFiltersChanged(_tempSelectedFilters);
    Navigator.pop(context);
  }
}
