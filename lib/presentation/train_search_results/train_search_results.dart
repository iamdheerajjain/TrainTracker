import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/empty_results_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/filter_chips_widget.dart';
import './widgets/search_header_widget.dart';
import './widgets/train_card_widget.dart';

class TrainSearchResults extends StatefulWidget {
  const TrainSearchResults({Key? key}) : super(key: key);

  @override
  State<TrainSearchResults> createState() => _TrainSearchResultsState();
}

class _TrainSearchResultsState extends State<TrainSearchResults> {
  List<String> _activeFilters = [];
  bool _isLoading = false;
  bool _isOfflineMode = false;

  // Mock data for train search results
  final List<Map<String, dynamic>> _trainResults = [
    {
      "id": "1",
      "trainNumber": "12345",
      "trainName": "Rajdhani Express",
      "departureTime": "06:30",
      "arrivalTime": "14:45",
      "duration": "8h 15m",
      "status": "On Time",
      "delay": "",
      "isFavorite": false,
      "classes": [
        {"name": "1A", "available": true},
        {"name": "2A", "available": true},
        {"name": "3A", "available": false},
      ],
    },
    {
      "id": "2",
      "trainNumber": "12678",
      "trainName": "Karnataka Express",
      "departureTime": "08:15",
      "arrivalTime": "18:30",
      "duration": "10h 15m",
      "status": "Delayed",
      "delay": "45 min",
      "isFavorite": true,
      "classes": [
        {"name": "SL", "available": true},
        {"name": "3A", "available": true},
        {"name": "2A", "available": false},
      ],
    },
    {
      "id": "3",
      "trainNumber": "16340",
      "trainName": "Mumbai Express",
      "departureTime": "10:45",
      "arrivalTime": "22:15",
      "duration": "11h 30m",
      "status": "On Time",
      "delay": "",
      "isFavorite": false,
      "classes": [
        {"name": "SL", "available": true},
        {"name": "CC", "available": true},
        {"name": "2S", "available": true},
      ],
    },
    {
      "id": "4",
      "trainNumber": "22691",
      "trainName": "Hazrat Nizamuddin Rajdhani",
      "departureTime": "15:55",
      "arrivalTime": "08:35",
      "duration": "16h 40m",
      "status": "Cancelled",
      "delay": "",
      "isFavorite": false,
      "classes": [
        {"name": "1A", "available": false},
        {"name": "2A", "available": false},
        {"name": "3A", "available": false},
      ],
    },
    {
      "id": "5",
      "trainNumber": "12951",
      "trainName": "Mumbai Central Rajdhani",
      "departureTime": "17:20",
      "arrivalTime": "09:45",
      "duration": "16h 25m",
      "status": "On Time",
      "delay": "",
      "isFavorite": true,
      "classes": [
        {"name": "1A", "available": true},
        {"name": "2A", "available": true},
        {"name": "3A", "available": true},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Sticky Header
            SearchHeaderWidget(
              fromStation: "New Delhi",
              toStation: "Mumbai Central",
              selectedDate: "26 Aug 2025",
              onEditPressed: _onEditSearch,
            ),

            // Filter Chips
            FilterChipsWidget(
              activeFilters: _activeFilters,
              onFilterTap: _onFilterTap,
              onSortPressed: _showFilterBottomSheet,
            ),

            // Offline Mode Indicator
            if (_isOfflineMode)
              Container(
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
                        'Offline mode - Showing cached data. Real-time status unavailable.',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.moderateDelayAmber,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Main Content
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _trainResults.isEmpty
                      ? EmptyResultsWidget(
                          onTryAlternativeDate: _onTryAlternativeDate,
                          onSearchNearbyStations: _onSearchNearbyStations,
                        )
                      : RefreshIndicator(
                          onRefresh: _onRefresh,
                          child: ListView.builder(
                            padding: EdgeInsets.only(bottom: 2.h),
                            itemCount: _trainResults.length,
                            itemBuilder: (context, index) {
                              final trainData = _trainResults[index];
                              return TrainCardWidget(
                                trainData: trainData,
                                onTap: () => _onTrainCardTap(trainData),
                                onFavoritePressed: () =>
                                    _onFavoritePressed(index),
                                onAlertPressed: () =>
                                    _onAlertPressed(trainData),
                                onSharePressed: () =>
                                    _onSharePressed(trainData),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFilterBottomSheet,
        child: CustomIconWidget(
          iconName: 'tune',
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.lightTheme.primaryColor,
          ),
          SizedBox(height: 2.h),
          Text(
            'Searching for trains...',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _onEditSearch() {
    Navigator.pushNamed(context, '/home-screen');
  }

  void _onFilterTap(String filter) {
    setState(() {
      if (_activeFilters.contains(filter)) {
        _activeFilters.remove(filter);
      } else {
        _activeFilters.add(filter);
      }
    });
    _applyFilters();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        selectedFilters: _activeFilters,
        onFiltersChanged: (filters) {
          setState(() {
            _activeFilters = filters;
          });
          _applyFilters();
        },
      ),
    );
  }

  void _onTrainCardTap(Map<String, dynamic> trainData) {
    Navigator.pushNamed(
      context,
      '/train-status-details',
      arguments: trainData,
    );
  }

  void _onFavoritePressed(int index) {
    setState(() {
      _trainResults[index]['isFavorite'] =
          !(_trainResults[index]['isFavorite'] ?? false);
    });

    final isFavorite = _trainResults[index]['isFavorite'] ?? false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite
              ? 'Train added to favorites'
              : 'Train removed from favorites',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onAlertPressed(Map<String, dynamic> trainData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Alert'),
        content: Text(
          'Do you want to receive notifications for ${trainData['trainName']} (${trainData['trainNumber']})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Alert set for ${trainData['trainName']}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text('Set Alert'),
          ),
        ],
      ),
    );
  }

  void _onSharePressed(Map<String, dynamic> trainData) {
    final shareText = '''
Train Details:
${trainData['trainName']} (${trainData['trainNumber']})
Departure: ${trainData['departureTime']}
Arrival: ${trainData['arrivalTime']}
Duration: ${trainData['duration']}
Status: ${trainData['status']}${trainData['delay'].isNotEmpty ? ' (${trainData['delay']})' : ''}

Shared via TrainTracker App
    ''';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Train details copied to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onTryAlternativeDate() {
    Navigator.pushNamed(context, '/home-screen');
  }

  void _onSearchNearbyStations() {
    Navigator.pushNamed(context, '/station-schedule');
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      // Update real-time status
      for (var train in _trainResults) {
        if (train['status'] == 'Delayed') {
          train['delay'] =
              '${(int.tryParse(train['delay'].split(' ')[0]) ?? 45) + 5} min';
        }
      }
    });
  }

  void _applyFilters() {
    // Apply filtering logic based on active filters
    // This would typically involve API calls or local filtering
    setState(() {
      // Simulate filtering effect
    });
  }
}
