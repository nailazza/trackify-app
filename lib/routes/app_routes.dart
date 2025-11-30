import 'package:flutter/material.dart';
import '../pages/add_activity_page.dart';
import '../pages/detail_activity_page.dart';
import '../pages/edit_activity_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/welcome_page.dart';
import '../pages/main_home_page.dart';
import '../models/activity.dart';

class AppRoutes {
  static const welcome = '/';
  static const mainHome = '/main_home';
  static const addActivity = '/add';
  static const detailActivity = '/detail';
  static const editActivity = '/edit';
  static const dashboard = '/dashboard';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomePage());

      case mainHome:
        return MaterialPageRoute(builder: (_) => const MainHomePage());

      case addActivity:
        return MaterialPageRoute(builder: (_) => const AddActivityPage());

      case detailActivity:
        final args = settings.arguments as Activity;
        return MaterialPageRoute(
          builder: (_) => DetailActivityPage(activity: args),
        );

      case editActivity:
        final args = settings.arguments as Activity;
        return MaterialPageRoute(
          builder: (_) => EditActivityPage(activity: args),
        );

      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardPage());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text(
                "404 — Page Not Found",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
    }
  }
}
