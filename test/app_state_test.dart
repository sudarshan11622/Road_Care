import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roadcare/models/report.dart';
import 'package:roadcare/state/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppState session restoration', () {
    test('restores a saved citizen session to the citizen home', () async {
      SharedPreferences.setMockInitialValues({
        'citizenLoggedIn': true,
        'phone': '9876543210',
      });

      final state = AppState();
      await state.load();

      expect(state.citizenLoggedIn, isTrue);
      expect(state.homeRoute, '/citizen');
    });

    test('uses the admin route when an admin is already signed in', () async {
      SharedPreferences.setMockInitialValues({
        'adminLoggedIn': true,
      });

      final state = AppState();
      await state.load();

      expect(state.adminLoggedIn, isTrue);
      expect(state.homeRoute, '/admin');
    });

    test('restores the saved dark mode preference', () async {
      SharedPreferences.setMockInitialValues({
        'isDarkMode': true,
      });

      final state = AppState();
      await state.load();

      expect(state.isDarkMode, isTrue);
      await state.setDarkMode(false);
      expect(state.isDarkMode, isFalse);
    });

    test('persists profile details and updates only that citizen reports',
        () async {
      SharedPreferences.setMockInitialValues({});

      final state = AppState();
      await state.load();
      await state.loginCitizen('9876543210');
      await state.addReport(
        title: 'My road report',
        type: 'Pothole',
        location: 'Ward 1',
        description: 'Needs repair',
      );

      await state.updateCitizenProfile(
        name: 'Asha Patel',
        email: 'asha@example.com',
        address: '12 Main Road, Ward 4',
      );

      expect(state.citizenName, 'Asha Patel');
      expect(state.citizenEmail, 'asha@example.com');
      expect(state.citizenAddress, '12 Main Road, Ward 4');
      expect(state.citizenReports.first.citizenName, 'Asha Patel');

      await state.logoutCitizen();
      await state.loginCitizen('1111111111');
      expect(state.citizenName, 'RoadCare Citizen');

      await state.logoutCitizen();
      await state.loginCitizen('9876543210');
      expect(state.citizenName, 'Asha Patel');
      expect(state.citizenEmail, 'asha@example.com');
      expect(state.citizenAddress, '12 Main Road, Ward 4');
    });

    test('persists report status changes and admin settings', () async {
      SharedPreferences.setMockInitialValues({});

      final state = AppState();
      await state.load();
      await state.updateReportStatus('RC-1048', ReportStatus.resolved);
      await state.assignReport('RC-1048', 'Road maintenance');
      await state.saveAdminSettings(
        organizationName: 'RoadCare City Office',
        serviceArea: 'North District',
      );

      final restored = AppState();
      await restored.load();

      expect(
        restored.reports.firstWhere((report) => report.id == 'RC-1048').status,
        ReportStatus.resolved,
      );
      expect(
        restored.reports
            .firstWhere((report) => report.id == 'RC-1048')
            .assignedTeam,
        'Road maintenance',
      );
      expect(restored.organizationName, 'RoadCare City Office');
      expect(restored.serviceArea, 'North District');
    });

    test('creates a separate notification for each report status update',
        () async {
      SharedPreferences.setMockInitialValues({});

      final state = AppState();
      await state.load();
      await state.loginCitizen('9876543210');
      await state.addReport(
        title: 'Blocked road',
        type: 'Road damage',
        location: 'North Road',
        description: 'Debris is blocking the lane.',
      );
      final firstReport = state.reports.first;
      await state.addReport(
        title: 'Damaged drain',
        type: 'Drainage',
        location: 'South Road',
        description: 'Drain cover is missing.',
      );
      final secondReport = state.reports.first;

      await state.updateReportStatus(firstReport.id, ReportStatus.underReview);
      await state.assignReport(firstReport.id, 'Road maintenance');
      await state.updateReportStatus(firstReport.id, ReportStatus.inProgress);
      await state.updateReportStatus(firstReport.id, ReportStatus.resolved);
      await state.updateReportStatus(firstReport.id, ReportStatus.resolved);
      await state.updateReportStatus(secondReport.id, ReportStatus.closed);

      expect(state.citizenNotifications, hasLength(7));
      expect(
        state.citizenNotifications
            .where((notification) => notification.reportId == firstReport.id)
            .map((notification) => notification.body),
        unorderedEquals([
          'The problem you reported has been resolved.',
          'Work has started on the problem you reported.',
          'Your report has been assigned to the responsible team.',
          'Your report is currently being reviewed by the RoadCare team.',
          'Your report has been submitted successfully.',
        ]),
      );
      expect(
        state.citizenNotifications
            .where((notification) => notification.reportId == secondReport.id)
            .map((notification) => notification.body),
        unorderedEquals([
          'Your report has been closed. Thank you for using RoadCare.',
          'Your report has been submitted successfully.',
        ]),
      );

      final restored = AppState();
      await restored.load();
      await restored.loginCitizen('9876543210');
      expect(restored.citizenNotifications, hasLength(7));
      await restored.logoutCitizen();
      await restored.loginCitizen('1111111111');
      expect(restored.citizenNotifications, isEmpty);
    });

    test('uses the configured rejected status notification text', () async {
      SharedPreferences.setMockInitialValues({});

      final state = AppState();
      await state.load();
      await state.loginCitizen('9876543210');
      await state.addReport(
        title: 'Unsafe sign',
        type: 'Traffic sign',
        location: 'Market Road',
        description: 'The sign is damaged.',
      );
      final report = state.reports.first;

      await state.updateReportStatus(report.id, ReportStatus.rejected);

      expect(
        state.citizenNotifications.first.body,
        'Your report could not be accepted. Tap to view the reason.',
      );
    });

    test('does not notify anonymous reports that are not trackable', () async {
      SharedPreferences.setMockInitialValues({});

      final state = AppState();
      await state.load();
      state.reports.insert(
        0,
        Report(
          id: 'RC-9000',
          title: 'Anonymous problem',
          type: 'Drainage',
          location: 'Ward 3',
          description: 'Anonymous complaint',
          createdAt: DateTime.now(),
          status: ReportStatus.submitted,
          citizenName: 'Anonymous citizen',
          citizenPhone: '9876543210',
          isTrackable: false,
        ),
      );

      await state.updateReportStatus('RC-9000', ReportStatus.resolved);

      expect(state.citizenNotifications, isEmpty);
    });

    test('keeps anonymous reports visible after later login with same number',
        () async {
      SharedPreferences.setMockInitialValues({});

      final firstState = AppState();
      await firstState.load();
      await firstState.addReport(
        title: 'Road issue',
        type: 'Pothole',
        location: 'North Road',
        description: 'Needs repair',
        phoneNumber: '9876543210',
      );

      expect(firstState.reports.first.citizenPhone, '9876543210');
      expect(firstState.reports.first.isTrackable, isTrue);

      final secondState = AppState();
      await secondState.load();
      await secondState.loginCitizen('9876543210');

      expect(
        secondState.citizenReports.map((report) => report.title),
        contains('Road issue'),
      );
    });

    test('shows only the logged-in user reports and exact personal counts',
        () async {
      SharedPreferences.setMockInitialValues({});

      final state = AppState();
      await state.load();
      await state.loginCitizen('9999999999');

      state.reports
        ..clear()
        ..addAll([
          Report(
            id: 'RC-1',
            title: 'Mine resolved',
            type: 'Pothole',
            location: 'Area A',
            description: 'Mine',
            createdAt: DateTime.now(),
            status: ReportStatus.resolved,
            citizenName: 'Me',
            citizenPhone: '9999999999',
            assignedTeam: 'Road maintenance',
            isTrackable: true,
          ),
          Report(
            id: 'RC-2',
            title: 'Mine in progress',
            type: 'Drainage',
            location: 'Area B',
            description: 'Mine',
            createdAt: DateTime.now(),
            status: ReportStatus.inProgress,
            citizenName: 'Me',
            citizenPhone: '9999999999',
            assignedTeam: 'Road maintenance',
            isTrackable: true,
          ),
          Report(
            id: 'RC-3',
            title: 'Mine unassigned',
            type: 'Street light',
            location: 'Area C',
            description: 'Mine',
            createdAt: DateTime.now(),
            status: ReportStatus.submitted,
            citizenName: 'Me',
            citizenPhone: '9999999999',
            assignedTeam: 'Unassigned',
            isTrackable: true,
          ),
          Report(
            id: 'RC-4',
            title: 'Other user report',
            type: 'Pothole',
            location: 'Area D',
            description: 'Someone else',
            createdAt: DateTime.now(),
            status: ReportStatus.inProgress,
            citizenName: 'Other',
            citizenPhone: '1111111111',
            assignedTeam: 'Electrical services',
            isTrackable: true,
          ),
        ]);

      expect(state.citizenReports, hasLength(3));
      expect(
          state.citizenReports.where((r) => r.status == ReportStatus.resolved),
          hasLength(1));
      expect(
          state.citizenReports
              .where((r) => r.status == ReportStatus.inProgress),
          hasLength(1));
      expect(state.citizenReports.where((r) => r.assignedTeam == 'Unassigned'),
          hasLength(1));
      expect(state.citizenReports.where((r) => r.assignedTeam != 'Unassigned'),
          hasLength(2));
      expect(state.citizenReportsCount, 3);
      expect(state.citizenResolvedReports, 1);
      expect(state.citizenProgressingReports, 1);
      expect(state.citizenAssignedReports, 2);
      expect(state.citizenUnassignedReports, 1);
    });
  });
}
