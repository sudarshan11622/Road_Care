enum ReportStatus {
  submitted,
  underReview,
  assigned,
  inProgress,
  resolved,
  closed,
  rejected;

  String get label {
    switch (this) {
      case ReportStatus.submitted:
        return 'Submitted';
      case ReportStatus.underReview:
        return 'Under review';
      case ReportStatus.assigned:
        return 'Assigned';
      case ReportStatus.inProgress:
        return 'In progress';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.closed:
        return 'Closed';
      case ReportStatus.rejected:
        return 'Rejected';
    }
  }

  String get notificationTitle {
    switch (this) {
      case ReportStatus.submitted:
        return 'Report submitted';
      case ReportStatus.underReview:
        return 'Report under review';
      case ReportStatus.assigned:
        return 'Report assigned';
      case ReportStatus.inProgress:
        return 'Work in progress';
      case ReportStatus.resolved:
        return 'Report resolved';
      case ReportStatus.closed:
        return 'Report closed';
      case ReportStatus.rejected:
        return 'Report rejected';
    }
  }

  String get notificationBody {
    switch (this) {
      case ReportStatus.submitted:
        return 'Your report has been submitted successfully.';
      case ReportStatus.underReview:
        return 'Your report is currently being reviewed by the RoadCare team.';
      case ReportStatus.assigned:
        return 'Your report has been assigned to the responsible team.';
      case ReportStatus.inProgress:
        return 'Work has started on the problem you reported.';
      case ReportStatus.resolved:
        return 'The problem you reported has been resolved.';
      case ReportStatus.closed:
        return 'Your report has been closed. Thank you for using RoadCare.';
      case ReportStatus.rejected:
        return 'Your report could not be accepted. Tap to view the reason.';
    }
  }
}

class Report {
  final String id;
  final String title;
  final String type;
  final String location;
  final String description;
  final String? imagePath;
  final DateTime createdAt;
  final ReportStatus status;
  final String citizenName;
  final String citizenPhone;
  final String assignedTeam;
  final bool isTrackable;

  const Report({
    required this.id,
    required this.title,
    required this.type,
    required this.location,
    required this.description,
    this.imagePath,
    required this.createdAt,
    required this.status,
    required this.citizenName,
    this.citizenPhone = '',
    this.assignedTeam = 'Unassigned',
    this.isTrackable = false,
  });

  String get trackabilityLabel => isTrackable ? 'Trackable' : 'Non-trackable';

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      location: json['location'] as String,
      description: json['description'] as String,
      imagePath: json['imagePath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: ReportStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => ReportStatus.submitted,
      ),
      citizenName: json['citizenName'] as String,
      citizenPhone: json['citizenPhone'] as String? ?? '',
      assignedTeam: json['assignedTeam'] as String? ?? 'Unassigned',
      isTrackable: json['isTrackable'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type,
        'location': location,
        'description': description,
        'imagePath': imagePath,
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
        'citizenName': citizenName,
        'citizenPhone': citizenPhone,
        'assignedTeam': assignedTeam,
        'isTrackable': isTrackable,
      };

  Report copyWith({
    ReportStatus? status,
    String? citizenName,
    String? citizenPhone,
    String? assignedTeam,
    bool? isTrackable,
  }) {
    return Report(
      id: id,
      title: title,
      type: type,
      location: location,
      description: description,
      imagePath: imagePath,
      createdAt: createdAt,
      status: status ?? this.status,
      citizenName: citizenName ?? this.citizenName,
      citizenPhone: citizenPhone ?? this.citizenPhone,
      assignedTeam: assignedTeam ?? this.assignedTeam,
      isTrackable: isTrackable ?? this.isTrackable,
    );
  }
}
