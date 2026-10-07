import 'package:flutter/material.dart';
import '../../app.dart';
import '../../theme/app_theme.dart';
import 'citizen_report_detail_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final notifications = state.citizenNotifications;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 25),
        children: [
          const Text('Notifications',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text(
            'Updates about your reports and local issues.',
            style: TextStyle(color: AppTheme.muted),
          ),
          const SizedBox(height: 18),
          if (notifications.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 42),
                child: Column(
                  children: [
                    Icon(Icons.notifications_none,
                        size: 36, color: AppTheme.muted),
                    SizedBox(height: 10),
                    Text('No notifications yet'),
                    SizedBox(height: 4),
                    Text(
                      'Updates about your reports will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.muted),
                    ),
                  ],
                ),
              ),
            )
          else
            ...notifications.map(
              (notification) => _Notice(
                title: notification.title,
                body:
                    '${notification.body}\nReport ID: ${notification.reportId}',
                time: MaterialLocalizations.of(context)
                    .formatMediumDate(notification.createdAt),
                onTap: () {
                  final matchingReports = state.citizenReports.where(
                    (report) => report.id == notification.reportId,
                  );
                  if (matchingReports.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('The report details are no longer available.'),
                      ),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => CitizenReportDetailScreen(
                        report: matchingReports.first,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final String title;
  final String body;
  final String time;
  final VoidCallback onTap;

  const _Notice({
    required this.title,
    required this.body,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppTheme.blue.withValues(alpha: .08),
          child: const Icon(Icons.notifications_active_outlined,
              color: AppTheme.green),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(body),
        ),
        trailing: Text(time,
            style: const TextStyle(fontSize: 10, color: AppTheme.muted)),
      ),
    );
  }
}
