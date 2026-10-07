import 'package:flutter/material.dart';
import '../../app.dart';
import '../../models/report.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'report_detail_screen.dart';

class AdminOverviewScreen extends StatelessWidget {
  const AdminOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return SafeArea(
      child: ListenableBuilder(
        listenable: state,
        builder: (_, __) {
          final total = state.reports.length;
          final pending = state.reports
              .where((r) => r.status != ReportStatus.resolved)
              .length;
          final resolved = state.reports
              .where((r) => r.status == ReportStatus.resolved)
              .length;
          final trackable = state.reports.where((r) => r.isTrackable).length;
          final nonTrackable =
              state.reports.where((r) => !r.isTrackable).length;
          final today = DateUtils.dateOnly(DateTime.now());
          final weekDays = List.generate(
            7,
            (index) => today.subtract(Duration(days: 6 - index)),
          );
          final weeklyCounts = weekDays
              .map(
                (day) => state.reports
                    .where(
                        (report) => DateUtils.isSameDay(report.createdAt, day))
                    .length,
              )
              .toList();
          final maximumWeeklyCount = weeklyCounts.fold<int>(
            0,
            (maximum, count) => count > maximum ? count : maximum,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 25),
            children: [
              const Text('Operations overview',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 5),
              const Text('Monitor reports and neighborhood issues.',
                  style: TextStyle(color: AppTheme.muted)),
              const SizedBox(height: 18),
              Row(
                children: [
                  _Metric('Reports', '$total', Icons.description_outlined),
                  const SizedBox(width: 8),
                  _Metric('Pending', '$pending', Icons.schedule),
                  const SizedBox(width: 8),
                  _Metric('Resolved', '$resolved', Icons.check_circle_outline),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _Metric('Trackable', '$trackable', Icons.person_outline),
                  const SizedBox(width: 8),
                  _Metric('Non-trackable', '$nonTrackable', Icons.lock_clock),
                ],
              ),
              const SizedBox(height: 20),
              SectionTitle(
                title: 'Recent reports',
                action: 'View all',
                onAction: () => state.setAdminTab(1),
              ),
              const SizedBox(height: 10),
              ...state.reports.take(5).map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Card(
                      child: ListTile(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReportDetailScreen(report: r),
                          ),
                        ),
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFEAF1FF),
                          child: Icon(Icons.report_problem_outlined,
                              color: AppTheme.blue),
                        ),
                        title: Text(r.title,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text('${r.location}\n${r.id}'),
                        isThreeLine: true,
                        trailing: StatusPill(
                            label: r.status.label,
                            color: statusColor(r.status.label)),
                      ),
                    ),
                  )),
              const SizedBox(height: 15),
              const Text('Reports this week',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Container(
                height: 150,
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppTheme.border),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (i) {
                    final count = weeklyCounts[i];
                    final barHeight = maximumWeeklyCount == 0
                        ? 8.0
                        : 8 + (count / maximumWeeklyCount) * 84;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('$count', style: const TextStyle(fontSize: 10)),
                        const SizedBox(height: 4),
                        Container(
                          width: 22,
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: AppTheme.blue,
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          [
                            'M',
                            'T',
                            'W',
                            'T',
                            'F',
                            'S',
                            'S'
                          ][weekDays[i].weekday - 1],
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _Metric(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppTheme.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: AppTheme.blue),
            const SizedBox(height: 7),
            Text(value,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            Text(label,
                style: const TextStyle(fontSize: 10, color: AppTheme.muted)),
          ],
        ),
      ),
    );
  }
}
