enum ReportStatus {
  submitted,
  underReview,
  inProgress,
  resolved;

  String get label {
    switch (this) {
      case ReportStatus.submitted:
        return 'Submitted';
      case ReportStatus.underReview:
        return 'Under review';
      case ReportStatus.inProgress:
        return 'In progress';
      case ReportStatus.resolved:
        return 'Resolved';
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
