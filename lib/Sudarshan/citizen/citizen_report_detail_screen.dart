import 'package:flutter/material.dart';

import '../../models/report.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/report_image.dart';

class CitizenReportDetailScreen extends StatelessWidget {
  final Report report;

  const CitizenReportDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(report.id)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 25),
        children: [
          if (report.imagePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: reportImage(
                report.imagePath!,
                width: double.infinity,
                height: 210,
              ),
            ),
          const SizedBox(height: 15),
          Text(
            report.title,
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          StatusPill(
            label: report.status.label,
            color: statusColor(report.status.label),
          ),
          const SizedBox(height: 16),
          _ReportInfo(label: 'Problem', value: report.type),
          _ReportInfo(label: 'Location', value: report.location),
          _ReportInfo(label: 'Status', value: report.status.label),
          _ReportInfo(label: 'Assigned team', value: report.assignedTeam),
          _ReportInfo(label: 'Description', value: report.description),
          if (report.status == ReportStatus.rejected &&
              report.rejectionReason != null)
            _ReportInfo(
              label: 'Rejection reason',
              value: report.rejectionReason!,
            ),
          _ReportInfo(
            label: 'Submitted',
            value: MaterialLocalizations.of(context)
                .formatMediumDate(report.createdAt),
          ),
        ],
      ),
    );
  }
}

class _ReportInfo extends StatelessWidget {
  final String label;
  final String value;

  const _ReportInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppTheme.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 96,
              child: Text(
                label,
                style: const TextStyle(color: AppTheme.muted, fontSize: 12),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
