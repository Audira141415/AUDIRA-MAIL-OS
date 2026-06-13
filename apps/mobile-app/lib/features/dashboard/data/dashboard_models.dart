class DashboardStats {
  final int totalAccounts;
  final int activeAccounts;
  final int emailsToday;
  final int otpToday;
  final double storageUsedGb;

  const DashboardStats({
    required this.totalAccounts,
    required this.activeAccounts,
    required this.emailsToday,
    required this.otpToday,
    required this.storageUsedGb,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalAccounts: json['totalAccounts'] as int? ?? 0,
      activeAccounts: json['activeAccounts'] as int? ?? 0,
      emailsToday: json['emailsToday'] as int? ?? 0,
      otpToday: json['otpToday'] as int? ?? 0,
      storageUsedGb: (json['storageUsedGb'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class OtpEntry {
  final String id;
  final String serviceName;
  final String otpCode;
  final String sender;
  final String subject;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const OtpEntry({
    required this.id,
    required this.serviceName,
    required this.otpCode,
    required this.sender,
    required this.subject,
    required this.createdAt,
    this.expiresAt,
  });

  factory OtpEntry.fromJson(Map<String, dynamic> json) {
    return OtpEntry(
      id: json['id'] as String,
      serviceName: json['serviceName'] as String? ?? 'Unknown',
      otpCode: json['otpCode'] as String? ?? '------',
      sender: json['sender'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      expiresAt: json['expiresAt'] != null ? DateTime.tryParse(json['expiresAt']) : null,
    );
  }
}

class EmailEntry {
  final String id;
  final String sender;
  final String subject;
  final String? category;
  final bool isRead;
  final DateTime receivedAt;

  const EmailEntry({
    required this.id,
    required this.sender,
    required this.subject,
    this.category,
    required this.isRead,
    required this.receivedAt,
  });

  factory EmailEntry.fromJson(Map<String, dynamic> json) {
    return EmailEntry(
      id: json['id'] as String,
      sender: json['sender'] as String? ?? 'Unknown',
      subject: json['subject'] as String? ?? 'No Subject',
      category: json['category'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      receivedAt: DateTime.tryParse(json['receivedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
