import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/empty_schedule_widget.dart';
import './widgets/platform_change_banner_widget.dart';
import './widgets/schedule_header_widget.dart';
import './widgets/schedule_search_widget.dart';
import './widgets/schedule_tab_widget.dart';
import './widgets/time_picker_widget.dart';
import './widgets/train_schedule_card_widget.dart';

class StationSchedule extends StatefulWidget {
  const StationSchedule({Key? key}) : super(key: key);

  @override
  State<StationSchedule> createState() => _StationScheduleState();
}

class _StationScheduleState extends State<StationSchedule>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedTime = '${DateTime.now().hour.toString().padLeft(2, '0')}:00';
  bool _isRefreshing = false;
  List<String> _dismissedBanners = [];

  // Mock station data
  final Map<String, dynamic> _stationData = {
    "stationName": "New Delhi Railway Station",
    "stationCode": "NDLS",
    "currentTime": "14:25",
  };

  // Mock arrivals data
  final List<Map<String, dynamic>> _arrivalsData = [
    {
      "trainNumber": "12301",
      "trainName": "Rajdhani Express",
      "scheduledTime": "14:30",
      "platform": "1",
      "status": "On Time",
      "delay": null,
      "source": "Mumbai Central",
      "destination": "",
    },
    {
      "trainNumber": "12951",
      "trainName": "Mumbai Rajdhani",
      "scheduledTime": "14:45",
      "platform": "3",
      "status": "Delayed",
      "delay": "15 min",
      "source": "Mumbai Central",
      "destination": "",
    },
    {
      "trainNumber": "12423",
      "trainName": "Dibrugarh Rajdhani",
      "scheduledTime": "15:00",
      "platform": "2",
      "status": "Platform Changed",
      "delay": null,
      "source": "Dibrugarh",
      "destination": "",
    },
    {
      "trainNumber": "12615",
      "trainName": "Grand Trunk Express",
      "scheduledTime": "15:15",
      "platform": "4",
      "status": "On Time",
      "delay": null,
      "source": "Chennai Central",
      "destination": "",
    },
    {
      "trainNumber": "12009",
      "trainName": "Shatabdi Express",
      "scheduledTime": "15:30",
      "platform": "6",
      "status": "Cancelled",
      "delay": null,
      "source": "Kalka",
      "destination": "",
    },
  ];

  // Mock departures data
  final List<Map<String, dynamic>> _departuresData = [
    {
      "trainNumber": "12302",
      "trainName": "Rajdhani Express",
      "scheduledTime": "16:00",
      "platform": "1",
      "status": "On Time",
      "delay": null,
      "source": "",
      "destination": "Mumbai Central",
    },
    {
      "trainNumber": "12952",
      "trainName": "Mumbai Rajdhani",
      "scheduledTime": "16:15",
      "platform": "2",
      "status": "Delayed",
      "delay": "10 min",
      "source": "",
      "destination": "Mumbai Central",
    },
    {
      "trainNumber": "12424",
      "trainName": "Dibrugarh Rajdhani",
      "scheduledTime": "16:30",
      "platform": "5",
      "status": "On Time",
      "delay": null,
      "source": "",
      "destination": "Dibrugarh",
    },
    {
      "trainNumber": "12616",
      "trainName": "Grand Trunk Express",
      "scheduledTime": "16:45",
      "platform": "3",
      "status": "Platform Changed",
      "delay": null,
      "source": "",
      "destination": "Chennai Central",
    },
    {
      "trainNumber": "12010",
      "trainName": "Shatabdi Express",
      "scheduledTime": "17:00",
      "platform": "4",
      "status": "On Time",
      "delay": null,
      "source": "",
      "destination": "Kalka",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredTrains() {
    final currentData =
        _tabController.index == 0 ? _arrivalsData : _departuresData;

    if (_searchQuery.isEmpty) {
      return currentData;
    }

    return currentData.where((train) {
      final trainNumber = (train['trainNumber'] as String? ?? '').toLowerCase();
      final trainName = (train['trainName'] as String? ?? '').toLowerCase();
      final destination = (train['destination'] as String? ?? '').toLowerCase();
      final source = (train['source'] as String? ?? '').toLowerCase();
      final query = _searchQuery.toLowerCase();

      return trainNumber.contains(query) ||
          trainName.contains(query) ||
          destination.contains(query) ||
          source.contains(query);
    }).toList();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate network call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Filter Options',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'train',
                color: AppTheme.lightTheme.primaryColor,
                size: 24,
              ),
              title: const Text('Train Types'),
              trailing: CustomIconWidget(
                iconName: 'keyboard_arrow_right',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'schedule',
                color: AppTheme.moderateDelayAmber,
                size: 24,
              ),
              title: const Text('Time Range'),
              trailing: CustomIconWidget(
                iconName: 'keyboard_arrow_right',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'location_on',
                color: AppTheme.onTimeGreen,
                size: 24,
              ),
              title: const Text('Destinations'),
              trailing: CustomIconWidget(
                iconName: 'keyboard_arrow_right',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Apply Filters'),
              ),
            ),
            SizedBox(height: 1.h),
          ],
        ),
      ),
    );
  }

  void _handleSwipeAction(Map<String, dynamic> trainData) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Quick Actions',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              '${trainData['trainNumber']} - ${trainData['trainName']}',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'route',
                color: AppTheme.lightTheme.primaryColor,
                size: 24,
              ),
              title: const Text('View Full Route'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/train-status-details');
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'notifications',
                color: AppTheme.moderateDelayAmber,
                size: 24,
              ),
              title: const Text('Set Alert'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Alert set for ${trainData['trainNumber']}'),
                    backgroundColor: AppTheme.onTimeGreen,
                  ),
                );
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'favorite',
                color: AppTheme.delayedRed,
                size: 24,
              ),
              title: const Text('Add to Favorites'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('${trainData['trainNumber']} added to favorites'),
                    backgroundColor: AppTheme.onTimeGreen,
                  ),
                );
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformChangeBanner() {
    final platformChangedTrain = _getFilteredTrains().firstWhere(
      (train) =>
          (train['status'] as String).toLowerCase() == 'platform changed',
      orElse: () => <String, dynamic>{},
    );

    if (platformChangedTrain.isEmpty ||
        _dismissedBanners.contains(platformChangedTrain['trainNumber'])) {
      return const SizedBox.shrink();
    }

    return PlatformChangeBannerWidget(
      trainNumber: platformChangedTrain['trainNumber'] as String,
      oldPlatform: '2',
      newPlatform: platformChangedTrain['platform'] as String,
      onDismiss: () {
        setState(() {
          _dismissedBanners.add(platformChangedTrain['trainNumber'] as String);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTrains = _getFilteredTrains();
    final isLateNight = DateTime.now().hour >= 23 || DateTime.now().hour < 5;

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Column(
        children: [
          ScheduleHeaderWidget(
            stationName: _stationData['stationName'] as String,
            stationCode: _stationData['stationCode'] as String,
            currentTime: _stationData['currentTime'] as String,
          ),
          ScheduleTabWidget(
            tabController: _tabController,
            onArrivalsTab: () {
              setState(() {});
            },
            onDeparturesTab: () {
              setState(() {});
            },
          ),
          ScheduleSearchWidget(
            onSearchChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
            onFilterPressed: _showFilterBottomSheet,
          ),
          TimePickerWidget(
            selectedTime: _selectedTime,
            onTimeChanged: (time) {
              setState(() {
                _selectedTime = time;
              });
            },
          ),
          _buildPlatformChangeBanner(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Arrivals Tab
                _buildTrainList(filteredTrains, isLateNight),
                // Departures Tab
                _buildTrainList(filteredTrains, isLateNight),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleRefresh,
        backgroundColor: AppTheme.lightTheme.primaryColor,
        child: _isRefreshing
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : CustomIconWidget(
                iconName: 'refresh',
                color: Colors.white,
                size: 24,
              ),
      ),
    );
  }

  Widget _buildTrainList(List<Map<String, dynamic>> trains, bool isLateNight) {
    if (trains.isEmpty && _searchQuery.isNotEmpty) {
      return EmptyScheduleWidget(
        message: 'No trains found',
        subMessage: 'Try adjusting your search criteria or check the spelling',
        onRefresh: () {
          setState(() {
            _searchQuery = '';
          });
        },
      );
    }

    if (trains.isEmpty && isLateNight) {
      return EmptyScheduleWidget(
        message: 'No trains scheduled',
        subMessage:
            'Late night hours - next trains start from 05:00 AM tomorrow',
        onRefresh: _handleRefresh,
      );
    }

    if (trains.isEmpty) {
      return EmptyScheduleWidget(
        message: 'No trains available',
        subMessage: 'Pull to refresh for the latest schedule information',
        onRefresh: _handleRefresh,
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppTheme.lightTheme.primaryColor,
      child: ListView.builder(
        padding: EdgeInsets.only(bottom: 10.h),
        itemCount: trains.length,
        itemBuilder: (context, index) {
          final train = trains[index];
          return TrainScheduleCardWidget(
            trainData: train,
            onTap: () {
              Navigator.pushNamed(context, '/train-status-details');
            },
            onSwipeRight: () => _handleSwipeAction(train),
          );
        },
      ),
    );
  }
}
