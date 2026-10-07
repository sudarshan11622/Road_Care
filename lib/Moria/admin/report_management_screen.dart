import 'package:flutter/material.dart';
import '../../app.dart';
import '../../models/report.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'report_detail_screen.dart';

class ReportManagementScreen extends StatefulWidget {
  const ReportManagementScreen({super.key});

  @override
  State<ReportManagementScreen> createState() => _ReportManagementScreenState();
}

class _ReportManagementScreenState extends State<ReportManagementScreen> {
  String _query = '';
  ReportStatus? _statusFilter;
  bool? _trackabilityFilter;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return SafeArea(
      child: ListenableBuilder(
        listenable: state,
        builder: (_, __) => ListView(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 25),
          children: [
            const Text('Report management',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 5),
            const Text('Review, assign and update citizen reports.',
                style: TextStyle(color: AppTheme.muted)),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) =>
                  setState(() => _query = value.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search by ID, title or location',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<ReportStatus?>(
              initialValue: _statusFilter,
              decoration: const InputDecoration(labelText: 'Filter by status'),
              items: [
                const DropdownMenuItem<ReportStatus?>(
                  value: null,
                  child: Text('All statuses'),
                ),
                ...ReportStatus.values.map(
                  (status) => DropdownMenuItem<ReportStatus?>(
                    value: status,
                    child: Text(status.label),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _statusFilter = value),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<bool?>(
              initialValue: _trackabilityFilter,
              decoration: const InputDecoration(
                labelText: 'Filter by tracking type',
              ),
              items: const [
                DropdownMenuItem<bool?>(
                    value: null, child: Text('All reports')),
                DropdownMenuItem<bool?>(value: true, child: Text('Trackable')),
                DropdownMenuItem<bool?>(
                    value: false, child: Text('Non-trackable')),
              ],
              onChanged: (value) => setState(() => _trackabilityFilter = value),
            ),
            const SizedBox(height: 14),
            ...state.reports.where((report) {
              final searchable =
                  '${report.id} ${report.title} ${report.location} ${report.type} ${report.citizenName} ${report.status.label} ${report.trackabilityLabel}'
                      .toLowerCase();
              return searchable.contains(_query) &&
                  (_statusFilter == null || report.status == _statusFilter) &&
                  (_trackabilityFilter == null ||
                      report.isTrackable == _trackabilityFilter);
            }).map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Card(
                  child: ListTile(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ReportDetailScreen(report: r)),
                    ),
                    leading: CircleAvatar(
                      backgroundColor:
                          statusColor(r.status.label).withValues(alpha: .10),
                      child: Icon(Icons.report_problem_outlined,
                          color: statusColor(r.status.label)),
                    ),
                    title: Text(r.title,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(
                        '${r.id} • ${r.type}\n${r.location}\n${r.trackabilityLabel}'),
                    isThreeLine: true,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: r.isTrackable
                            ? const Color(0xFFEAF7EE)
                            : const Color(0xFFFFF4E5),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        r.trackabilityLabel,
                        style: TextStyle(
                          color: r.isTrackable ? Colors.green : Colors.orange,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (state.reports.isEmpty ||
                !state.reports.any((report) {
                  final searchable =
                      '${report.id} ${report.title} ${report.location} ${report.type} ${report.citizenName} ${report.status.label} ${report.trackabilityLabel}'
                          .toLowerCase();
                  return searchable.contains(_query) &&
                      (_statusFilter == null ||
                          report.status == _statusFilter) &&
                      (_trackabilityFilter == null ||
                          report.isTrackable == _trackabilityFilter);
                }))
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: Text('No matching reports found.')),
              ),
          ],
        ),
      ),
    );
  }
}
