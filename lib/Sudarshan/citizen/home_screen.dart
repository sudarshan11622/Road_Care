import 'package:flutter/material.dart';
import '../../app.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/report_image.dart';
import 'report_flow_screen.dart';

class CitizenHomeScreen extends StatelessWidget {
  const CitizenHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final myReports = state.citizenReports;
    final total = state.citizenReportsCount;
    final resolved = state.citizenResolvedReports;
    final progressing = state.citizenProgressingReports;
    final assigned = state.citizenAssignedReports;
    final unassigned = state.citizenUnassignedReports;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(),
            const SizedBox(height: 25),
            const Text(
              'Let’s improve your\nneighborhood.',
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Spot a problem? Send it to the right people.',
              style: TextStyle(color: AppTheme.muted),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.blue,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SPOT A ROAD PROBLEM?',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Report it in under 2 minutes.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 15),
                  FilledButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReportFlowScreen()),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.blue,
                    ),
                    child: const Text('Report a problem'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const SectionTitle(title: 'Your reports'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _Stat(value: '$total', label: 'Total'),
                _Stat(value: '$resolved', label: 'Resolved'),
                _Stat(value: '$progressing', label: 'Progressing'),
                _Stat(value: '$assigned', label: 'Assigned'),
                _Stat(value: '$unassigned', label: 'Unassigned'),
              ],
            ),
            const SizedBox(height: 22),
            const SectionTitle(title: 'Recent report'),
            const SizedBox(height: 10),
            if (myReports.isNotEmpty) _ReportPreview(report: myReports.first),
            if (myReports.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Text(
                  'No reports for this account yet.',
                  style: TextStyle(color: AppTheme.muted),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const RoadCareLogo(markSize: 34, fontSize: 16),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
          ],
        ),
      ),
    );
  }
}

class _ReportPreview extends StatelessWidget {
  final dynamic report;
  const _ReportPreview({required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: report.imagePath != null
                ? reportImage(report.imagePath!, width: 72, height: 72)
                : Container(width: 72, height: 72, color: AppTheme.surface),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(report.location, style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
                const SizedBox(height: 7),
                StatusPill(
                  label: report.status.label,
                  color: statusColor(report.status.label),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
