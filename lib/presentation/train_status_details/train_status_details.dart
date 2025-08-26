import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/live_tracking_section.dart';
import './widgets/offline_status_banner.dart';
import './widgets/quick_actions_section.dart';
import './widgets/train_header_card.dart';

class TrainStatusDetails extends StatefulWidget {
  const TrainStatusDetails({Key? key}) : super(key: key);

  @override
  State<TrainStatusDetails> createState() => _TrainStatusDetailsState();
}

class _TrainStatusDetailsState extends State<TrainStatusDetails> {
  bool _isLoading = false;
  bool _isOffline = false;
  bool _isFavorite = false;
  bool _notificationsEnabled = true;
  DateTime _lastUpdated = DateTime.now();

  // Mock train data
  final Map<String, dynamic> _trainData = {
    "number": "12345",
    "name": "Rajdhani Express",
    "source": "New Delhi",
    "destination": "Mumbai Central",
    "status": "running",
    "delay": "15",
    "departureTime": "16:55",
    "departureDate": "26 Aug 2025",
    "arrivalTime": "08:35",
    "arrivalDate": "27 Aug 2025",
  };

  final List<Map<String, dynamic>> _stations = [
    {
      "name": "New Delhi",
      "scheduledTime": "16:55",
      "actualTime": "17:10",
      "delay": "15",
      "platform": "1",
    },
    {
      "name": "Gurgaon",
      "scheduledTime": "17:25",
      "actualTime": "17:40",
      "delay": "15",
      "platform": "2",
    },
    {
      "name": "Rewari",
      "scheduledTime": "18:15",
      "actualTime": "18:30",
      "delay": "15",
      "platform": "1",
    },
    {
      "name": "Alwar",
      "scheduledTime": "19:05",
      "actualTime": "--:--",
      "delay": "0",
      "platform": "3",
    },
    {
      "name": "Jaipur",
      "scheduledTime": "20:30",
      "actualTime": "--:--",
      "delay": "0",
      "platform": "2",
    },
    {
      "name": "Ajmer",
      "scheduledTime": "22:15",
      "actualTime": "--:--",
      "delay": "0",
      "platform": "1",
    },
    {
      "name": "Abu Road",
      "scheduledTime": "01:45",
      "actualTime": "--:--",
      "delay": "0",
      "platform": "2",
    },
    {
      "name": "Ahmedabad",
      "scheduledTime": "04:20",
      "actualTime": "--:--",
      "delay": "0",
      "platform": "4",
    },
    {
      "name": "Vadodara",
      "scheduledTime": "06:15",
      "actualTime": "--:--",
      "delay": "0",
      "platform": "3",
    },
    {
      "name": "Mumbai Central",
      "scheduledTime": "08:35",
      "actualTime": "--:--",
      "delay": "0",
      "platform": "1",
    },
  ];

  int _currentStationIndex = 2; // Currently at Rewari (index 2)

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _loadTrainStatus();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOffline = connectivityResult == ConnectivityResult.none;
    });
  }

  Future<void> _loadTrainStatus() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
      _lastUpdated = DateTime.now();
    });
  }

  Future<void> _refreshStatus() async {
    HapticFeedback.lightImpact();
    await _checkConnectivity();

    if (!_isOffline) {
      await _loadTrainStatus();
      Fluttertoast.showToast(
        msg: "Status updated successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.onTimeGreen,
        textColor: Colors.white,
      );
    } else {
      Fluttertoast.showToast(
        msg: "No internet connection",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.delayedRed,
        textColor: Colors.white,
      );
    }
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    HapticFeedback.selectionClick();
    Fluttertoast.showToast(
      msg: _isFavorite ? "Added to favorites" : "Removed from favorites",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.primaryColor,
      textColor: Colors.white,
    );
  }

  void _shareStatus() {
    final String shareText = '''
Train Status: ${_trainData['number']} - ${_trainData['name']}
Route: ${_trainData['source']} → ${_trainData['destination']}
Status: ${_trainData['status']}
${_trainData['delay'] != '0' ? 'Delay: +${_trainData['delay']} minutes' : ''}

Shared via TrainTracker App
    ''';

    // In a real app, you would use the share_plus package
    Fluttertoast.showToast(
      msg: "Status copied to clipboard",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.primaryColor,
      textColor: Colors.white,
    );

    Clipboard.setData(ClipboardData(text: shareText));
  }

  void _toggleNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
    });

    HapticFeedback.selectionClick();
    Fluttertoast.showToast(
      msg: value ? "Notifications enabled" : "Notifications disabled",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.primaryColor,
      textColor: Colors.white,
    );
  }

  void _showStationAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Station Alert',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Set custom alerts for specific stations or journey updates.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Fluttertoast.showToast(
                  msg: "Station alert set successfully",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: AppTheme.onTimeGreen,
                  textColor: Colors.white,
                );
              },
              child: const Text('Set Alert'),
            ),
          ],
        );
      },
    );
  }

  void _setCustomAlert() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 40.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 12.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Set Custom Alert',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Choose when you want to be notified about this train:',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              SizedBox(height: 3.h),
              _buildAlertOption(
                  '30 minutes before arrival', () => _setAlert('30 min')),
              _buildAlertOption(
                  '1 hour before arrival', () => _setAlert('1 hour')),
              _buildAlertOption('On departure from current station',
                  () => _setAlert('departure')),
              _buildAlertOption(
                  'On any delay updates', () => _setAlert('delay')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertOption(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        margin: EdgeInsets.only(bottom: 2.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.lightTheme.dividerColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: 'notifications',
              color: AppTheme.lightTheme.primaryColor,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                title,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            CustomIconWidget(
              iconName: 'arrow_forward_ios',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _setAlert(String alertType) {
    Navigator.pop(context);
    Fluttertoast.showToast(
      msg: "Alert set for $alertType",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.onTimeGreen,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Train Status',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        foregroundColor: AppTheme.lightTheme.appBarTheme.foregroundColor,
        elevation: AppTheme.lightTheme.appBarTheme.elevation,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.appBarTheme.foregroundColor!,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'refresh',
              color: AppTheme.lightTheme.appBarTheme.foregroundColor!,
              size: 24,
            ),
            onPressed: _refreshStatus,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshStatus,
        color: AppTheme.lightTheme.primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              if (_isOffline)
                OfflineStatusBanner(
                  lastUpdated: _lastUpdated,
                  onRetry: _refreshStatus,
                ),
              SizedBox(height: 2.h),
              TrainHeaderCard(trainData: _trainData),
              SizedBox(height: 2.h),
              LiveTrackingSection(
                stations: _stations,
                currentStationIndex: _currentStationIndex,
                onStationLongPress: _showStationAlert,
              ),
              SizedBox(height: 2.h),
              QuickActionsSection(
                isFavorite: _isFavorite,
                notificationsEnabled: _notificationsEnabled,
                onFavoriteToggle: _toggleFavorite,
                onShare: _shareStatus,
                onNotificationToggle: _toggleNotifications,
              ),
              SizedBox(height: 10.h), // Space for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _setCustomAlert,
        backgroundColor:
            AppTheme.lightTheme.floatingActionButtonTheme.backgroundColor,
        foregroundColor:
            AppTheme.lightTheme.floatingActionButtonTheme.foregroundColor,
        icon: CustomIconWidget(
          iconName: 'add_alert',
          color: AppTheme.lightTheme.floatingActionButtonTheme.foregroundColor!,
          size: 20,
        ),
        label: Text(
          'Set Alert',
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color:
                AppTheme.lightTheme.floatingActionButtonTheme.foregroundColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}