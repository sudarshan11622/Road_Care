import 'package:flutter/material.dart';
import '../../app.dart';
import '../../models/report.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/report_image.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final reports = state.citizenReports.where((report) {
      final searchable =
          '${report.id} ${report.title} ${report.location}'.toLowerCase();
      return searchable.contains(_query);
    }).toList();
    return SafeArea(
      child: ListenableBuilder(
        listenable: state,
        builder: (_, __) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('My reports',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 5),
              const Text(
                'Track everything you have submitted.',
                style: TextStyle(color: AppTheme.muted),
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (value) =>
                    setState(() => _query = value.trim().toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search reports',
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 14),
              ...reports.map((report) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ReportCard(report: report),
                  )),
              if (reports.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child:
                      Center(child: Text('No reports found for this account.')),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Report report;
  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(11),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: report.imagePath != null
                ? reportImage(report.imagePath!, width: 64, height: 64)
                  : Container(width: 64, height: 64, color: AppTheme.surface),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(report.title,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(report.id,
                      style:
                          const TextStyle(fontSize: 11, color: AppTheme.muted)),
                  const SizedBox(height: 6),
                  StatusPill(
                      label: report.status.label,
                      color: statusColor(report.status.label)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
