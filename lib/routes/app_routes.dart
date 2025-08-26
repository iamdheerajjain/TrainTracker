import 'package:flutter/material.dart';
import '../presentation/home_screen/home_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/train_status_details/train_status_details.dart';
import '../presentation/profile_settings/profile_settings.dart';
import '../presentation/station_schedule/station_schedule.dart';
import '../presentation/train_search_results/train_search_results.dart';
import '../presentation/auth/login_screen.dart';

class AppRoutes {
  static const String initial = "/";
  static const String splashScreen = "/splash_screen";
  static const String homeScreen = "/home_screen";
  static const String trainStatusDetails = "/train-status-details";
  static const String profileSettings = "/profile-settings";
  static const String stationSchedule = "/station-schedule";
  static const String trainSearchResults = "/train-search-results";
  static const String login = "/login";

  static Map<String, WidgetBuilder> get routes => {
        initial: (context) => const HomeScreen(),
        splashScreen: (context) => const SplashScreen(),
        homeScreen: (context) => const HomeScreen(),
        trainStatusDetails: (context) => const TrainStatusDetails(),
        profileSettings: (context) => const ProfileSettings(),
        stationSchedule: (context) => const StationSchedule(),
        trainSearchResults: (context) => const TrainSearchResults(),
        login: (context) => const LoginScreen(),
      };
}
