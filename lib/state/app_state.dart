import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_notification.dart';
import '../models/report.dart';

class AppState extends ChangeNotifier {
  SharedPreferences? _prefs;

  bool citizenLoggedIn = false;
  bool adminLoggedIn = false;
  bool isDarkMode = false;
  bool requireLocationConfirmation = true;
  String organizationName = 'RoadCare Municipal Services';
  String serviceArea = 'Central District';
  String citizenName = 'RoadCare Citizen';
  String citizenEmail = '';
  String citizenAddress = '';
  String? citizenProfileImage;
  String phone = '';
  int citizenTab = 0;
  int adminTab = 0;

  String get homeRoute {
    if (citizenLoggedIn) return '/citizen';
    if (adminLoggedIn) return '/admin';
    return '/';
  }

  List<Report> get citizenReports {
    if (phone.trim().isEmpty) return const [];
    final normalizedPhone = phone.trim();
    final matches = reports
        .where((report) => report.citizenPhone.trim() == normalizedPhone)
        .toList();
    matches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return matches;
  }

  int get citizenReportsCount => citizenReports.length;
  int get citizenResolvedReports => citizenReports
      .where((report) => report.status == ReportStatus.resolved)
      .length;
  int get citizenProgressingReports => citizenReports
      .where((report) =>
          report.status == ReportStatus.inProgress ||
          report.status == ReportStatus.underReview)
      .length;
  int get citizenAssignedReports => citizenReports
      .where((report) => report.assignedTeam != 'Unassigned')
      .length;
  int get citizenUnassignedReports => citizenReports
      .where((report) => report.assignedTeam == 'Unassigned')
      .length;

  final List<Report> reports = [
    Report(
      id: 'RC-1048',
      title: 'Pothole near Main Road',
      type: 'Pothole',
      location: 'Station Road, Ward 4',
      description: 'Large pothole causing difficulty for two-wheelers.',
      imagePath: 'assets/images/demo_road.jpg',
      createdAt: DateTime(2026, 10, 2),
      status: ReportStatus.inProgress,
      citizenName: 'Sudarshan Roy',
      citizenPhone: '9876543210',
      isTrackable: true,
    ),
    Report(
      id: 'RC-1042',
      title: 'Broken street light',
      type: 'Street light',
      location: 'Market Chowk, Ward 2',
      description: 'Street light has not worked for several nights.',
      createdAt: DateTime(2026, 9, 28),
      status: ReportStatus.underReview,
      citizenName: 'Anonymous resident',
      isTrackable: false,
    ),
    Report(
      id: 'RC-1037',
      title: 'Open drain',
      type: 'Drainage',
      location: 'School Road, Ward 1',
      description: 'Drain cover is missing near the school entrance.',
      createdAt: DateTime(2026, 9, 22),
      status: ReportStatus.resolved,
      citizenName: 'Sudarshan Roy',
      citizenPhone: '9876543210',
      isTrackable: true,
    ),
  ];
  final List<AppNotification> notifications = [];

  List<AppNotification> get citizenNotifications => notifications
      .where((notification) => notification.phone == phone)
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    citizenLoggedIn = _prefs?.getBool('citizenLoggedIn') ?? false;
    adminLoggedIn = _prefs?.getBool('adminLoggedIn') ?? false;
    isDarkMode = _prefs?.getBool('isDarkMode') ?? false;
    organizationName =
        _prefs?.getString('organizationName') ?? 'RoadCare Municipal Services';
    serviceArea = _prefs?.getString('serviceArea') ?? 'Central District';
    requireLocationConfirmation =
        _prefs?.getBool('requireLocationConfirmation') ?? true;
    phone = _prefs?.getString('phone') ?? '';
    citizenName = _prefs?.getString('citizenName_$phone') ?? 'RoadCare Citizen';
    citizenEmail = _prefs?.getString('citizenEmail_$phone') ?? '';
    citizenAddress = _prefs?.getString('citizenAddress_$phone') ?? '';
    citizenProfileImage = _prefs?.getString('citizenProfileImage_$phone');
    final storedReports = _prefs?.getString('reports');
    if (storedReports != null) {
      try {
        final decoded = jsonDecode(storedReports) as List<dynamic>;
        reports
          ..clear()
          ..addAll(
            decoded.map(
              (report) => Report.fromJson(report as Map<String, dynamic>),
            ),
          );
      } on FormatException {
        await _prefs?.remove('reports');
      } on TypeError {
        await _prefs?.remove('reports');
      }
    }
    final storedNotifications = _prefs?.getString('notifications');
    if (storedNotifications != null) {
      try {
        final decoded = jsonDecode(storedNotifications) as List<dynamic>;
        notifications
          ..clear()
          ..addAll(
            decoded.map(
              (notification) => AppNotification.fromJson(
                notification as Map<String, dynamic>,
              ),
            ),
          );
      } on FormatException {
        await _prefs?.remove('notifications');
      } on TypeError {
        await _prefs?.remove('notifications');
      }
    }
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    isDarkMode = value;
    await _prefs?.setBool('isDarkMode', value);
    notifyListeners();
  }

  Future<void> saveAdminSettings({
    required String organizationName,
    required String serviceArea,
  }) async {
    this.organizationName = organizationName.trim();
    this.serviceArea = serviceArea.trim();
    this.requireLocationConfirmation = true;
    await _prefs?.setString('organizationName', this.organizationName);
    await _prefs?.setString('serviceArea', this.serviceArea);
    await _prefs?.setBool('requireLocationConfirmation', true);
    notifyListeners();
  }

  Future<void> _saveReports() async {
    final encoded = jsonEncode(
      reports.map((report) => report.toJson()).toList(),
    );
    await _prefs?.setString('reports', encoded);
  }

  Future<void> _saveNotifications() async {
    final encoded = jsonEncode(
      notifications.map((notification) => notification.toJson()).toList(),
    );
    await _prefs?.setString('notifications', encoded);
  }

  Future<void> loginCitizen(String value) async {
    phone = value.replaceAll(RegExp(r'\D'), '');
    citizenLoggedIn = true;
    citizenName =
        _prefs?.getString('citizenName_$phone') ?? 'RoadCare Citizen';
    citizenEmail = _prefs?.getString('citizenEmail_$phone') ?? '';
    citizenAddress = _prefs?.getString('citizenAddress_$phone') ?? '';
    citizenProfileImage = _prefs?.getString('citizenProfileImage_$phone');

    for (final report in reports) {
      if (report.citizenPhone.trim().isEmpty && phone.isNotEmpty) {
        reports[reports.indexOf(report)] = report.copyWith(
          citizenPhone: phone,
          isTrackable: true,
        );
      }
    }

    await _prefs?.setBool('citizenLoggedIn', true);
    await _prefs?.setString('phone', phone);
    await _saveReports();
    notifyListeners();
  }

  Future<void> updateCitizenProfile({
    required String name,
    required String email,
    required String address,
    String? profileImage,
    bool removeProfileImage = false,
  }) async {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) return;

    citizenName = normalizedName;
    citizenEmail = email.trim();
    citizenAddress = address.trim();
    if (removeProfileImage) {
      citizenProfileImage = null;
    } else if (profileImage != null) {
      citizenProfileImage = profileImage;
    }
    if (phone.isNotEmpty) {
      await _prefs?.setString('citizenName_$phone', citizenName);
      await _prefs?.setString('citizenEmail_$phone', citizenEmail);
      await _prefs?.setString('citizenAddress_$phone', citizenAddress);
      if (citizenProfileImage == null) {
        await _prefs?.remove('citizenProfileImage_$phone');
      } else {
        await _prefs?.setString(
          'citizenProfileImage_$phone',
          citizenProfileImage!,
        );
      }
      for (var index = 0; index < reports.length; index++) {
        if (reports[index].citizenPhone == phone) {
          reports[index] = reports[index].copyWith(citizenName: citizenName);
        }
      }
      await _saveReports();
    }
    notifyListeners();
  }

  Future<void> logoutCitizen() async {
    citizenLoggedIn = false;
    phone = '';
    citizenName = 'RoadCare Citizen';
    citizenEmail = '';
    citizenAddress = '';
    citizenProfileImage = null;
    await _prefs?.setBool('citizenLoggedIn', false);
    await _prefs?.remove('phone');
    notifyListeners();
  }

  Future<void> loginAdmin() async {
    adminLoggedIn = true;
    await _prefs?.setBool('adminLoggedIn', true);
    notifyListeners();
  }

  Future<void> logoutAdmin() async {
    adminLoggedIn = false;
    await _prefs?.setBool('adminLoggedIn', false);
    notifyListeners();
  }

  void setCitizenTab(int index) {
    citizenTab = index;
    notifyListeners();
  }

  void setAdminTab(int index) {
    adminTab = index;
    notifyListeners();
  }

  Future<void> addReport({
    required String title,
    required String type,
    required String location,
    required String description,
    String? imagePath,
    String? phoneNumber,
  }) async {
    final id = 'RC-${1050 + reports.length}';
    final normalizedPhone = (phoneNumber ?? phone).replaceAll(RegExp(r'\D'), '');
    final isTrackable = citizenLoggedIn || normalizedPhone.isNotEmpty;
    reports.insert(
      0,
      Report(
        id: id,
        title: title,
        type: type,
        location: location,
        description: description,
        imagePath: imagePath,
        createdAt: DateTime.now(),
        status: ReportStatus.submitted,
        citizenName: citizenLoggedIn ? citizenName : 'Anonymous citizen',
        citizenPhone: normalizedPhone,
        isTrackable: isTrackable,
      ),
    );
    if (normalizedPhone.isNotEmpty) {
      phone = normalizedPhone;
      await _prefs?.setString('phone', phone);
    }
    await _saveReports();
    if (isTrackable && normalizedPhone.isNotEmpty) {
      _addReportNotification(reports.first, ReportStatus.submitted);
      await _saveNotifications();
    }
    notifyListeners();
  }

  Future<void> updateReportStatus(String id, ReportStatus status) async {
    final index = reports.indexWhere((r) => r.id == id);
    if (index == -1) return;
    final previous = reports[index];
    if (previous.status == status) return;
    reports[index] = reports[index].copyWith(status: status);
    await _saveReports();
    if (previous.isTrackable && previous.citizenPhone.isNotEmpty) {
      _addReportNotification(reports[index], status);
      await _saveNotifications();
    }
    notifyListeners();
  }

  Future<void> assignReport(String id, String team) async {
    final index = reports.indexWhere((report) => report.id == id);
    if (index == -1) return;
    final previous = reports[index];
    if (previous.assignedTeam == team) return;
    final newStatus = team != 'Unassigned' &&
            (previous.status == ReportStatus.submitted ||
                previous.status == ReportStatus.underReview)
        ? ReportStatus.assigned
        : previous.status;
    reports[index] = previous.copyWith(
      assignedTeam: team,
      status: newStatus,
    );
    await _saveReports();
    if (team != 'Unassigned' &&
        previous.isTrackable &&
        previous.citizenPhone.isNotEmpty) {
      _addReportNotification(reports[index], ReportStatus.assigned);
      await _saveNotifications();
    }
    notifyListeners();
  }

  void _addReportNotification(Report report, ReportStatus status) {
    notifications.add(
      AppNotification(
        reportId: report.id,
        phone: report.citizenPhone,
        title: status.notificationTitle,
        body: status.notificationBody,
        createdAt: DateTime.now(),
      ),
    );
  }
}
