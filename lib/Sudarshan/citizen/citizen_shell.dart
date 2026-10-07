import 'package:flutter/material.dart';
import '../../app.dart';
import 'my_reports_screen.dart';
import 'home_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

class CitizenShell extends StatefulWidget {
  const CitizenShell({super.key});

  @override
  State<CitizenShell> createState() => _CitizenShellState();
}

class _CitizenShellState extends State<CitizenShell> {
  final pages = const [
    CitizenHomeScreen(),
    MyReportsScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return ListenableBuilder(
      listenable: state,
      builder: (_, __) => Scaffold(
        body: pages[state.citizenTab],
        bottomNavigationBar: NavigationBar(
          selectedIndex: state.citizenTab,
          onDestinationSelected: (index) async {
            state.setCitizenTab(index);
            if (index == 2) {
              await state.markCitizenNotificationsRead();
            }
          },
          destinations: [
            const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home'),
            const NavigationDestination(
                icon: Icon(Icons.description_outlined),
                selectedIcon: Icon(Icons.description),
                label: 'Reports'),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: state.citizenUnreadNotificationCount > 0,
                label: Text('${state.citizenUnreadNotificationCount}'),
                child: const Icon(Icons.notifications_none),
              ),
              selectedIcon: Badge(
                isLabelVisible: state.citizenUnreadNotificationCount > 0,
                label: Text('${state.citizenUnreadNotificationCount}'),
                child: const Icon(Icons.notifications),
              ),
              label: 'Alerts',
            ),
            const NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
