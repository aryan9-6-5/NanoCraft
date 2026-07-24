import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String reportId;
  final String reporterId;
  final String levelId;
  final String reason;
  final DateTime timestamp;
  final String status; // 'open', 'resolved', 'ignored'

  const Report({
    required this.reportId,
    required this.reporterId,
    required this.levelId,
    required this.reason,
    required this.timestamp,
    required this.status,
  });

  Report copyWith({
    String? reportId,
    String? reporterId,
    String? levelId,
    String? reason,
    DateTime? timestamp,
    String? status,
  }) {
    return Report(
      reportId: reportId ?? this.reportId,
      reporterId: reporterId ?? this.reporterId,
      levelId: levelId ?? this.levelId,
      reason: reason ?? this.reason,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reportId': reportId,
      'reporterId': reporterId,
      'levelId': levelId,
      'reason': reason,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status,
    };
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      reportId: map['reportId'] as String? ?? '',
      reporterId: map['reporterId'] as String? ?? '',
      levelId: map['levelId'] as String? ?? '',
      reason: map['reason'] as String? ?? '',
      timestamp: _parseDateTime(map['timestamp']),
      status: map['status'] as String? ?? 'open',
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.now();
  }
}
