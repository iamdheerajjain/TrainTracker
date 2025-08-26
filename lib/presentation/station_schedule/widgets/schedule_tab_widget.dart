import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ScheduleTabWidget extends StatelessWidget {
  final TabController tabController;
  final VoidCallback onArrivalsTab;
  final VoidCallback onDeparturesTab;

  const ScheduleTabWidget({
    Key? key,
    required this.tabController,
    required this.onArrivalsTab,
    required this.onDeparturesTab,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1,
        ),
      ),
      child: TabBar(
        controller: tabController,
        indicator: BoxDecoration(
          color: AppTheme.lightTheme.primaryColor,
          borderRadius: BorderRadius.circular(6),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: EdgeInsets.all(0.5.w),
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.lightTheme.colorScheme.onSurface,
        labelStyle: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle:
            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w400,
        ),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'train',
                    color: tabController.index == 0
                        ? Colors.white
                        : AppTheme.lightTheme.colorScheme.onSurface,
                    size: 18,
                  ),
                  SizedBox(width: 2.w),
                  const Text('Arrivals'),
                ],
              ),
            ),
          ),
          Tab(
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'departure_board',
                    color: tabController.index == 1
                        ? Colors.white
                        : AppTheme.lightTheme.colorScheme.onSurface,
                    size: 18,
                  ),
                  SizedBox(width: 2.w),
                  const Text('Departures'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
