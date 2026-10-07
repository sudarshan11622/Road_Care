import 'package:flutter/material.dart';
import '../../app.dart';
import '../../models/report.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/report_image.dart';

class ReportDetailScreen extends StatelessWidget {
  final Report report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(report.id)),
      body: ListenableBuilder(
        listenable: state,
        builder: (_, __) {
          final current = state.reports.firstWhere(
            (r) => r.id == report.id,
            orElse: () => report,
          );
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 25),
            children: [
              if (current.imagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: reportImage(
                    current.imagePath!,
                    width: double.infinity,
                    height: 190,
                  ),
                ),
              const SizedBox(height: 15),
              Text(current.title,
                  style: const TextStyle(
                      fontSize: 23, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              StatusPill(
                  label: current.status.label,
                  color: statusColor(current.status.label)),
              const SizedBox(height: 16),
              _Info('Type', current.type),
              _Info('Location', current.location),
              _Info('Citizen', current.citizenName),
              _Info('Tracking status', current.trackabilityLabel),
              _Info('Assigned team', current.assignedTeam),
              _Info('Description', current.description),
              if (current.status == ReportStatus.rejected &&
                  current.rejectionReason != null)
                _Info('Rejection reason', current.rejectionReason!),
              const SizedBox(height: 12),
              const Text('Assign to team',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                key: ValueKey(current.assignedTeam),
                initialValue: current.assignedTeam,
                decoration: const InputDecoration(),
                items: const [
                  'Unassigned',
                  'Road maintenance',
                  'Electrical services',
                  'Drainage team',
                ].map((team) {
                  return DropdownMenuItem(value: team, child: Text(team));
                }).toList(),
                onChanged: (team) {
                  if (team != null) state.assignReport(current.id, team);
                },
              ),
              const SizedBox(height: 16),
              const Text('Update status',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              DropdownButtonFormField<ReportStatus>(
                key: ValueKey(current.status),
                initialValue: current.status,
                decoration: const InputDecoration(),
                items: ReportStatus.values.map((s) {
                  return DropdownMenuItem(value: s, child: Text(s.label));
                }).toList(),
                onChanged: (value) async {
                  if (value == null) return;
                  if (value == ReportStatus.rejected) {
                    final reason = await _requestRejectionReason(context);
                    if (reason == null) return;
                    await state.updateReportStatus(
                      current.id,
                      value,
                      rejectionReason: reason,
                    );
                    return;
                  }
                  await state.updateReportStatus(current.id, value);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

Future<String?> _requestRejectionReason(BuildContext context) async {
  return showDialog<String>(
    context: context,
    builder: (_) => const _RejectionReasonDialog(),
  );
}

class _RejectionReasonDialog extends StatefulWidget {
  const _RejectionReasonDialog();

  @override
  State<_RejectionReasonDialog> createState() => _RejectionReasonDialogState();
}

class _RejectionReasonDialogState extends State<_RejectionReasonDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('Reject report'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Reason for rejection',
            hintText: 'Explain why this report cannot be accepted',
          ),
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Enter a reason before rejecting'
              : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.pop(context, _controller.text.trim());
            }
          },
          child: const Text('Save reason'),
        ),
      ],
    );
  }
}

class _Info extends StatelessWidget {
  final String label;
  final String value;
  const _Info(this.label, this.value);

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
                width: 80,
                child: Text(label,
                    style:
                        const TextStyle(color: AppTheme.muted, fontSize: 12))),
            Expanded(
                child: Text(value,
                    style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
      ),
    );
  }
}
