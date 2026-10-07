import 'package:flutter/material.dart';
import '../../app.dart';
import 'admin_overview_screen.dart';
import 'report_management_screen.dart';
import 'citizen_directory_screen.dart';
import 'admin_settings_screen.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final pages = const [
      AdminOverviewScreen(),
      ReportManagementScreen(),
      CitizenDirectoryScreen(),
      AdminSettingsScreen(),
    ];

    return ListenableBuilder(
      listenable: state,
      builder: (_, __) => Scaffold(
        body: pages[state.adminTab],
        bottomNavigationBar: NavigationBar(
          selectedIndex: state.adminTab,
          onDestinationSelected: (i) {
            state.setAdminTab(i);
          },
          destinations: const [
            NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Overview'),
            NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: 'Reports'),
            NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Citizens'),
            NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}
