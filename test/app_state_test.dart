import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roadcare/models/report.dart';
import 'package:roadcare/state/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppState session restoration', () {
    test('does not create a report without a location', () async {
      SharedPreferences.setMockInitialValues({});

      final state = AppState();
      await state.load();

      await expectLater(
        state.addReport(
          title: 'Road issue',
          type: 'Pothole',
          location: '  ',
          description: 'Needs repair',
        ),
        throwsArgumentError,
      );
      expect(state.reports, hasLength(3));
    });

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

    test('restores only terminal status notifications', () async {
      SharedPreferences.setMockInitialValues({
        'notifications': jsonEncode([
          {
            'reportId': 'RC-1',
            'phone': '9876543210',
            'title': 'Report under review',
            'body': 'Review update',
            'createdAt': DateTime(2026, 10, 7).toIso8601String(),
          },
          {
            'reportId': 'RC-2',
            'phone': '9876543210',
            'title': 'Report resolved',
            'body': 'Resolved update',
            'createdAt': DateTime(2026, 10, 7).toIso8601String(),
          },
        ]),
      });

      final state = AppState();
      await state.load();

      expect(state.notifications, hasLength(1));
      expect(state.notifications.single.title, 'Report resolved');
    });

    test('marks notifications read for the current citizen and persists it',
        () async {
      SharedPreferences.setMockInitialValues({});

      final state = AppState();
      await state.load();
      await state.loginCitizen('9876543210');
      await state.addReport(
        title: 'First problem',
        type: 'Pothole',
        location: 'North Road',
        description: 'Needs repair.',
      );
      final firstReport = state.reports.first;
      await state.addReport(
        title: 'Second problem',
        type: 'Drainage',
        location: 'South Road',
        description: 'Drain cover is missing.',
      );
      final secondReport = state.reports.first;

      await state.updateReportStatus(firstReport.id, ReportStatus.resolved);
      await state.updateReportStatus(secondReport.id, ReportStatus.rejected,
          rejectionReason: 'Duplicate report.');

      expect(state.citizenUnreadNotificationCount, 2);
      await state.markCitizenNotificationsRead();
      expect(state.citizenUnreadNotificationCount, 0);
      expect(state.citizenNotifications.every((notification) => notification.isRead),
          isTrue);

      final restored = AppState();
      await restored.load();
      await restored.loginCitizen('9876543210');
      expect(restored.citizenUnreadNotificationCount, 0);

      await restored.logoutCitizen();
      await restored.loginCitizen('1111111111');
      expect(restored.citizenUnreadNotificationCount, 0);
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

    test('notifies separately per report only for resolved or rejected status',
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
      await state.updateReportStatus(
        secondReport.id,
        ReportStatus.rejected,
        rejectionReason: 'The location is outside the service area.',
      );

      expect(state.citizenNotifications, hasLength(2));
      expect(
        state.citizenNotifications
            .where((notification) => notification.reportId == firstReport.id)
            .map((notification) => notification.body),
        ['The problem you reported has been resolved.'],
      );
      expect(
        state.citizenNotifications
            .where((notification) => notification.reportId == secondReport.id)
            .map((notification) => notification.body),
        ['Your report could not be accepted. Tap to view the reason.'],
      );
      expect(
        state.reports
            .singleWhere((report) => report.id == secondReport.id)
            .rejectionReason,
        'The location is outside the service area.',
      );

      final restored = AppState();
      await restored.load();
      await restored.loginCitizen('9876543210');
      expect(restored.citizenNotifications, hasLength(2));
      expect(
        restored.reports
            .singleWhere((report) => report.id == secondReport.id)
            .rejectionReason,
        'The location is outside the service area.',
      );
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

      await state.updateReportStatus(
        report.id,
        ReportStatus.rejected,
        rejectionReason: 'The report does not include a road issue.',
      );

      expect(
        state.citizenNotifications
            .singleWhere(
              (notification) =>
                  notification.body ==
                  'Your report could not be accepted. Tap to view the reason.',
            )
            .body,
        'Your report could not be accepted. Tap to view the reason.',
      );
    });

    test('rejecting a report requires a reason and does not update without it',
        () async {
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

      await expectLater(
        state.updateReportStatus(report.id, ReportStatus.rejected),
        throwsArgumentError,
      );

      expect(state.reports.first.status, ReportStatus.submitted);
      expect(state.citizenNotifications, isEmpty);
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
