import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/train_models.dart';
import '../../services/auth_service.dart';
import '../../services/train_service.dart';
import './widgets/network_status_widget.dart';
import './widgets/quick_actions_widget.dart';
import './widgets/recent_searches_widget.dart';
import './widgets/search_card_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isOnline = true;
  DateTime? _lastSyncTime = DateTime.now();
  late TabController _tabController;

  List<SearchHistory> _recentSearches = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _simulateNetworkStatus();
    _loadRecentSearches();
  }

  void _simulateNetworkStatus() {
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _isOnline = false;
          _lastSyncTime = DateTime.now().subtract(const Duration(minutes: 5));
        });
      }
    });
  }

  Future<void> _loadRecentSearches() async {
    if (!AuthService.isAuthenticated) return;

    try {
      setState(() => _isLoading = true);
      final searches =
          await TrainService.getUserSearchHistory(AuthService.currentUser!.id);
      setState(() {
        _recentSearches = searches.take(5).toList();
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load recent searches: $error')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onSearchTrain(String from, String to, DateTime date) async {
    try {
      // Get station information
      final fromStation = await TrainService.searchStations(from);
      final toStation = await TrainService.searchStations(to);

      if (fromStation.isEmpty || toStation.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter valid station names')),
        );
        return;
      }

      // Add to search history if user is authenticated
      if (AuthService.isAuthenticated) {
        await TrainService.addSearchHistory(
          userId: AuthService.currentUser!.id,
          searchType: 'train_search',
          fromStationId: fromStation.first.id,
          toStationId: toStation.first.id,
          journeyDate: date,
          searchQuery: {
            'from_station_name': fromStation.first.name,
            'to_station_name': toStation.first.name,
          },
        );

        // Reload recent searches
        _loadRecentSearches();
      }

      // Navigate to search results
      Navigator.pushNamed(
        context,
        '/train-search-results',
        arguments: {
          'fromStation': fromStation.first,
          'toStation': toStation.first,
          'date': date,
        },
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed: $error')),
      );
    }
  }

  void _onRecentSearchTap(SearchHistory search) async {
    try {
      // Get station details
      Station? fromStation;
      Station? toStation;

      if (search.fromStationId != null) {
        final stations = await TrainService.getAllStations();
        fromStation = stations.firstWhere((s) => s.id == search.fromStationId);
      }

      if (search.toStationId != null) {
        final stations = await TrainService.getAllStations();
        toStation = stations.firstWhere((s) => s.id == search.toStationId);
      }

      Navigator.pushNamed(
        context,
        '/train-search-results',
        arguments: {
          'fromStation': fromStation,
          'toStation': toStation,
          'date': search.journeyDate ?? DateTime.now(),
        },
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load search: $error')),
      );
    }
  }

  Future<void> _onDeleteSearch(SearchHistory search) async {
    try {
      await TrainService.deleteSearchHistory(search.id);
      _loadRecentSearches();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete search: $error')),
      );
    }
  }

  Future<void> _onFavoriteSearch(SearchHistory search) async {
    try {
      await TrainService.toggleFavoriteSearch(search.id, !search.isFavorite);
      _loadRecentSearches();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update favorite: $error')),
      );
    }
  }

  void _onPNRStatusTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PNR Status feature coming soon')),
    );
  }

  void _onLiveTrainStatusTap() {
    Navigator.pushNamed(context, '/train-status-details');
  }

  void _onStationScheduleTap() {
    Navigator.pushNamed(context, '/station-schedule');
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isOnline = true;
      _lastSyncTime = DateTime.now();
    });
    await _loadRecentSearches();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        Navigator.pushNamed(context, '/train-search-results');
        break;
      case 2:
        Navigator.pushNamed(context, '/favorites');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile-settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'train',
              color: Colors.white,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'TrainTracker',
              style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
            ),
          ],
        ),
        actions: [
          // Show login button if not authenticated
          if (!AuthService.isAuthenticated)
            IconButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              icon: CustomIconWidget(
                iconName: 'person',
                color: Colors.white,
                size: 24,
              ),
              tooltip: 'Login',
            ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Voice search feature coming soon')),
              );
            },
            icon: CustomIconWidget(
              iconName: 'mic',
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            NetworkStatusWidget(
              isOnline: _isOnline,
              lastSyncTime: _lastSyncTime,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2.h),
                      SearchCardWidget(
                        onSearch: _onSearchTrain,
                      ),
                      SizedBox(height: 3.h),
                      if (AuthService.isAuthenticated && !_isLoading)
                        RecentSearchesWidget(
                          recentSearches: _recentSearches
                              .map((search) => {
                                    'id': search.id,
                                    'from': search.searchQuery?[
                                            'from_station_name'] ??
                                        'Unknown',
                                    'to': search
                                            .searchQuery?['to_station_name'] ??
                                        'Unknown',
                                    'date': search.journeyDate
                                            ?.toString()
                                            .split(' ')[0] ??
                                        'Unknown',
                                    'searchTime':
                                        _formatSearchTime(search.searchedAt),
                                    'isFavorite': search.isFavorite,
                                    'searchHistory': search,
                                  })
                              .toList(),
                          onSearchTap: (data) => _onRecentSearchTap(
                              data['searchHistory'] as SearchHistory),
                          onDeleteSearch: (data) => _onDeleteSearch(
                              data['searchHistory'] as SearchHistory),
                          onFavoriteSearch: (data) => _onFavoriteSearch(
                              data['searchHistory'] as SearchHistory),
                        ),
                      if (_isLoading)
                        Container(
                          height: 20.h,
                          child:
                              const Center(child: CircularProgressIndicator()),
                        ),
                      if (!AuthService.isAuthenticated)
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.account_circle,
                                  size: 48, color: Colors.blue),
                              SizedBox(height: 2.h),
                              Text(
                                'Sign in to save your searches',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                'Access your search history, bookings, and get personalized recommendations',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.blue.shade600,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              ElevatedButton(
                                onPressed: () =>
                                    Navigator.pushNamed(context, '/login'),
                                child: Text('Sign In'),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 3.h),
                      QuickActionsWidget(
                        onPNRStatusTap: _onPNRStatusTap,
                        onLiveTrainStatusTap: _onLiveTrainStatusTap,
                        onStationScheduleTap: _onStationScheduleTap,
                      ),
                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'home',
              color: _currentIndex == 0
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'search',
              color: _currentIndex == 1
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'favorite',
              color: _currentIndex == 2
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'person',
              color: _currentIndex == 3
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/train-search-results');
        },
        child: CustomIconWidget(
          iconName: 'search',
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  String _formatSearchTime(DateTime searchTime) {
    final now = DateTime.now();
    final difference = now.difference(searchTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
