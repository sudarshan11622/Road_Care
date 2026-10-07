class AppNotification {
  final String reportId;
  final String phone;
  final String title;
  final String body;
  final DateTime createdAt;

  const AppNotification({
    required this.reportId,
    required this.phone,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      reportId: json['reportId'] as String,
      phone: json['phone'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'reportId': reportId,
        'phone': phone,
        'title': title,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
      };
}
