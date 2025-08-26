import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/confirmation_dialog_widget.dart';
import './widgets/language_selector_widget.dart';
import './widgets/notification_toggle_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/settings_tile_widget.dart';
import './widgets/storage_info_widget.dart';
import './widgets/timing_selector_widget.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({Key? key}) : super(key: key);

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  // Notification settings
  bool _trainDelayNotifications = true;
  bool _pnrStatusNotifications = true;
  bool _favoriteTrainAlerts = true;
  bool _platformChangeNotifications = true;

  // Timing preferences
  String _delayNotificationTiming = '15 minutes before';
  String _arrivalNotificationTiming = '30 minutes before';

  // Language setting
  String _selectedLanguage = 'en';

  // App version
  final String _appVersion = '2.1.4';
  final String _buildNumber = '2025082601';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _trainDelayNotifications =
          prefs.getBool('train_delay_notifications') ?? true;
      _pnrStatusNotifications =
          prefs.getBool('pnr_status_notifications') ?? true;
      _favoriteTrainAlerts = prefs.getBool('favorite_train_alerts') ?? true;
      _platformChangeNotifications =
          prefs.getBool('platform_change_notifications') ?? true;
      _delayNotificationTiming =
          prefs.getString('delay_notification_timing') ?? '15 minutes before';
      _arrivalNotificationTiming =
          prefs.getString('arrival_notification_timing') ?? '30 minutes before';
      _selectedLanguage = prefs.getString('selected_language') ?? 'en';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('train_delay_notifications', _trainDelayNotifications);
    await prefs.setBool('pnr_status_notifications', _pnrStatusNotifications);
    await prefs.setBool('favorite_train_alerts', _favoriteTrainAlerts);
    await prefs.setBool(
        'platform_change_notifications', _platformChangeNotifications);
    await prefs.setString(
        'delay_notification_timing', _delayNotificationTiming);
    await prefs.setString(
        'arrival_notification_timing', _arrivalNotificationTiming);
    await prefs.setString('selected_language', _selectedLanguage);
  }

  void _handleNotificationToggle(String type, bool value) {
    setState(() {
      switch (type) {
        case 'train_delay':
          _trainDelayNotifications = value;
          break;
        case 'pnr_status':
          _pnrStatusNotifications = value;
          break;
        case 'favorite_train':
          _favoriteTrainAlerts = value;
          break;
        case 'platform_change':
          _platformChangeNotifications = value;
          break;
      }
    });
    _saveSettings();
    HapticFeedback.lightImpact();
  }

  void _handleTimingChange(String type, String value) {
    setState(() {
      if (type == 'delay') {
        _delayNotificationTiming = value;
      } else if (type == 'arrival') {
        _arrivalNotificationTiming = value;
      }
    });
    _saveSettings();
  }

  void _handleLanguageChange(String languageCode) {
    setState(() {
      _selectedLanguage = languageCode;
    });
    _saveSettings();
    Fluttertoast.showToast(
      msg: 'Language updated successfully',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _clearCache() {
    // Cache clearing logic would be implemented here
    HapticFeedback.mediumImpact();
  }

  Future<void> _clearRecentSearches() async {
    final confirmed = await ConfirmationDialogWidget.show(
      context: context,
      title: 'Clear Recent Searches',
      message:
          'This will remove all your recent train searches. This action cannot be undone.',
      confirmText: 'Clear',
      isDestructive: true,
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('recent_searches');
      Fluttertoast.showToast(
        msg: 'Recent searches cleared',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> _clearFavorites() async {
    final confirmed = await ConfirmationDialogWidget.show(
      context: context,
      title: 'Clear Favorites',
      message:
          'This will remove all your favorite trains. This action cannot be undone.',
      confirmText: 'Clear',
      isDestructive: true,
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('favorite_trains');
      Fluttertoast.showToast(
        msg: 'Favorites cleared',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _rateApp() {
    // Rate app functionality would open app store
    Fluttertoast.showToast(
      msg: 'Opening app store...',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _shareApp() {
    // Share app functionality
    Fluttertoast.showToast(
      msg: 'Share TrainTracker with friends!',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _openPrivacyPolicy() {
    // Open privacy policy
    Fluttertoast.showToast(
      msg: 'Opening privacy policy...',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _openTermsOfService() {
    // Open terms of service
    Fluttertoast.showToast(
      msg: 'Opening terms of service...',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _contactSupport() {
    // Contact support functionality
    Fluttertoast.showToast(
      msg: 'Opening support contact...',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _exportData() {
    // Export user data functionality
    Fluttertoast.showToast(
      msg: 'Preparing data export...',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Profile Settings',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        foregroundColor: AppTheme.lightTheme.appBarTheme.foregroundColor,
        elevation: AppTheme.lightTheme.appBarTheme.elevation,
        centerTitle: AppTheme.lightTheme.appBarTheme.centerTitle,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.appBarTheme.foregroundColor!,
            size: 6.w,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 2.h),

            // Notifications Section
            SettingsSectionWidget(
              title: 'Notifications',
              children: [
                NotificationToggleWidget(
                  title: 'Train Delays',
                  subtitle: 'Get notified when your trains are delayed',
                  initialValue: _trainDelayNotifications,
                  onChanged: (value) =>
                      _handleNotificationToggle('train_delay', value),
                ),
                NotificationToggleWidget(
                  title: 'PNR Status Changes',
                  subtitle:
                      'Updates on booking confirmation and seat allocation',
                  initialValue: _pnrStatusNotifications,
                  onChanged: (value) =>
                      _handleNotificationToggle('pnr_status', value),
                ),
                NotificationToggleWidget(
                  title: 'Favorite Train Alerts',
                  subtitle: 'Status updates for your favorite trains',
                  initialValue: _favoriteTrainAlerts,
                  onChanged: (value) =>
                      _handleNotificationToggle('favorite_train', value),
                ),
                NotificationToggleWidget(
                  title: 'Platform Changes',
                  subtitle: 'Alerts when platform numbers change',
                  initialValue: _platformChangeNotifications,
                  onChanged: (value) =>
                      _handleNotificationToggle('platform_change', value),
                  showDivider: false,
                ),
              ],
            ),

            // Notification Timing Section
            SettingsSectionWidget(
              title: 'Notification Timing',
              children: [
                TimingSelectorWidget(
                  title: 'Delay Notifications',
                  options: const [
                    '5 minutes before',
                    '15 minutes before',
                    '30 minutes before',
                    '1 hour before'
                  ],
                  selectedOption: _delayNotificationTiming,
                  onChanged: (value) => _handleTimingChange('delay', value),
                ),
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color:
                      AppTheme.lightTheme.dividerColor.withValues(alpha: 0.3),
                  indent: 4.w,
                  endIndent: 4.w,
                ),
                TimingSelectorWidget(
                  title: 'Arrival Notifications',
                  options: const [
                    '15 minutes before',
                    '30 minutes before',
                    '1 hour before',
                    '2 hours before'
                  ],
                  selectedOption: _arrivalNotificationTiming,
                  onChanged: (value) => _handleTimingChange('arrival', value),
                ),
              ],
            ),

            // Language Section
            SettingsSectionWidget(
              title: 'Language',
              children: [
                LanguageSelectorWidget(
                  currentLanguage: _selectedLanguage,
                  onLanguageChanged: _handleLanguageChange,
                ),
              ],
            ),

            // Data & Storage Section
            SettingsSectionWidget(
              title: 'Data & Storage',
              children: [
                StorageInfoWidget(
                  onClearCache: _clearCache,
                ),
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color:
                      AppTheme.lightTheme.dividerColor.withValues(alpha: 0.3),
                  indent: 4.w,
                  endIndent: 4.w,
                ),
                SettingsTileWidget(
                  title: 'Clear Recent Searches',
                  subtitle: 'Remove all recent train searches',
                  leadingIcon: 'history',
                  onTap: _clearRecentSearches,
                ),
                SettingsTileWidget(
                  title: 'Clear Favorites',
                  subtitle: 'Remove all favorite trains',
                  leadingIcon: 'favorite_border',
                  onTap: _clearFavorites,
                ),
                SettingsTileWidget(
                  title: 'Export Data',
                  subtitle: 'Download your favorites and preferences',
                  leadingIcon: 'download',
                  onTap: _exportData,
                  showDivider: false,
                ),
              ],
            ),

            // App Actions Section
            SettingsSectionWidget(
              title: 'App',
              children: [
                SettingsTileWidget(
                  title: 'Rate App',
                  subtitle: 'Help us improve by rating TrainTracker',
                  leadingIcon: 'star_border',
                  onTap: _rateApp,
                ),
                SettingsTileWidget(
                  title: 'Share App',
                  subtitle: 'Recommend TrainTracker to friends',
                  leadingIcon: 'share',
                  onTap: _shareApp,
                  showDivider: false,
                ),
              ],
            ),

            // About Section
            SettingsSectionWidget(
              title: 'About',
              children: [
                SettingsTileWidget(
                  title: 'App Version',
                  subtitle: '$_appVersion (Build $_buildNumber)',
                  leadingIcon: 'info_outline',
                  trailing: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(1.w),
                    ),
                    child: Text(
                      'Latest',
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SettingsTileWidget(
                  title: 'Privacy Policy',
                  subtitle: 'How we handle your data',
                  leadingIcon: 'privacy_tip',
                  onTap: _openPrivacyPolicy,
                ),
                SettingsTileWidget(
                  title: 'Terms of Service',
                  subtitle: 'App usage terms and conditions',
                  leadingIcon: 'description',
                  onTap: _openTermsOfService,
                ),
                SettingsTileWidget(
                  title: 'Contact Support',
                  subtitle: 'Get help with TrainTracker',
                  leadingIcon: 'support_agent',
                  onTap: _contactSupport,
                  showDivider: false,
                ),
              ],
            ),

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }
}
