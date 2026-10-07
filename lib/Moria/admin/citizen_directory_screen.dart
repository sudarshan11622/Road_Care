import 'package:flutter/material.dart';
import '../../app.dart';
import '../../models/report.dart';
import '../../theme/app_theme.dart';

class CitizenDirectoryScreen extends StatefulWidget {
  const CitizenDirectoryScreen({super.key});

  @override
  State<CitizenDirectoryScreen> createState() => _CitizenDirectoryScreenState();
}

class _CitizenDirectoryScreenState extends State<CitizenDirectoryScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final reportsByCitizen = <String, List<Report>>{};
    for (final report in state.reports) {
      reportsByCitizen.putIfAbsent(report.citizenName, () => []).add(report);
    }
    final citizens = reportsByCitizen.entries.where((entry) {
      final phone = entry.key == 'Sudarshan Roy' ? state.phone : '';
      return '${entry.key} $phone ${entry.value.length}'
          .toLowerCase()
          .contains(_query);
    }).toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 25),
        children: [
          const Text('Citizen directory',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          const Text('Search citizens and review their report history.',
              style: TextStyle(color: AppTheme.muted)),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) =>
                setState(() => _query = value.trim().toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Search citizen',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 12),
          ...citizens.map(
            (c) => Card(
              child: ListTile(
                onTap: () => _showCitizenHistory(context, c.key, c.value),
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEAF1FF),
                  child: Icon(Icons.person_outline, color: AppTheme.blue),
                ),
                title: Text(c.key,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(
                  '${c.key == 'Sudarshan Roy' && state.phone.isNotEmpty ? '+91 ${state.phone}' : 'Citizen account'}\n'
                  '${c.value.length} ${c.value.length == 1 ? 'report' : 'reports'}',
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.history),
              ),
            ),
          ),
          if (citizens.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: Text('No citizens match this search.')),
            ),
        ],
      ),
    );
  }

  void _showCitizenHistory(
    BuildContext context,
    String citizenName,
    List<Report> reports,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$citizenName report history'),
        content: SizedBox(
          width: 420,
          child: reports.isEmpty
              ? const Text('No reports found.')
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: reports.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(report.title),
                      subtitle: Text('${report.id} • ${report.status.label}'),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
