import 'dart:convert';
import 'dart:typed_data';

/// Parsed session + QR result returned from POST /api/session/create.
///
/// Backend response shape (double-nested `data` — the gateway wraps the
/// session service's own envelope):
/// { success, data: { success, data: { session: {...}, qr: { success, data: { token, qr } } } } }
class SessionSummary {
  final String id;
  final String sessionType;
  final String? description;
  final String createdBy;
  final num amount; // NOTE: assumed cents per project convention — confirm with backend
  final String status;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? cancelledAt;
  final DateTime? settledAt;
  final String title;
  final String splitType;
  final String category;
  final String groupId;

  const SessionSummary({
    required this.id,
    required this.sessionType,
    this.description,
    required this.createdBy,
    required this.amount,
    required this.status,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    this.cancelledAt,
    this.settledAt,
    required this.title,
    required this.splitType,
    required this.category,
    required this.groupId,
  });

  factory SessionSummary.fromJson(Map<String, dynamic> json) {
    return SessionSummary(
      id: json['id'] as String,
      sessionType: json['session_type'] as String? ?? 'manual',
      description: json['description'] as String?,
      createdBy: json['created_by'] as String,
      amount: (json['amount'] as num?) ?? 0,
      status: json['status'] as String? ?? 'OPEN',
      expiresAt: _parseDate(json['expires_at']),
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
      cancelledAt: _parseDate(json['cancelled_at']),
      settledAt: _parseDate(json['settled_at']),
      title: json['title'] as String? ?? 'Untitled',
      splitType: json['split_type'] as String? ?? 'equal',
      category: json['category'] as String? ?? 'other',
      groupId: json['group_id'] as String? ?? '',
    );
  }

  static DateTime? _parseDate(dynamic v) =>
      v == null ? null : DateTime.tryParse(v as String);
}

class QrData {
  final String token;
  final String qrDataUri; // "data:image/png;base64,...."

  const QrData({required this.token, required this.qrDataUri});

  factory QrData.fromJson(Map<String, dynamic> json) => QrData(
    token: json['token'] as String? ?? '',
    qrDataUri: json['qr'] as String? ?? '',
  );

  /// Decoded PNG bytes, stripped of the data-URI prefix.
  Uint8List get imageBytes {
    final raw = qrDataUri.contains(',') ? qrDataUri.split(',').last : qrDataUri;
    return base64Decode(raw);
  }
}

class SessionCreateResult {
  final SessionSummary session;
  final QrData qr;

  const SessionCreateResult({required this.session, required this.qr});

  /// Parses the full raw response body from POST /api/session/create.
  factory SessionCreateResult.fromJson(Map<String, dynamic> json) {
    if (json['success'] != true) {
      throw Exception(_extractError(json) ?? 'Session creation failed');
    }
    final level1 = json['data'];
    if (level1 is! Map<String, dynamic> || level1['success'] != true) {
      throw Exception(
        _extractError(level1 is Map<String, dynamic> ? level1 : json) ??
            'Session creation failed',
      );
    }
    final level2 = level1['data'];
    if (level2 is! Map<String, dynamic>) {
      throw Exception('Malformed session response');
    }

    final sessionJson = level2['session'];
    if (sessionJson is! Map<String, dynamic>) {
      throw Exception('Missing session data in response');
    }

    final qrOuter = level2['qr'];
    Map<String, dynamic> qrJson = const {};
    if (qrOuter is Map<String, dynamic> && qrOuter['data'] is Map<String, dynamic>) {
      qrJson = qrOuter['data'] as Map<String, dynamic>;
    }

    return SessionCreateResult(
      session: SessionSummary.fromJson(sessionJson),
      qr: QrData.fromJson(qrJson),
    );
  }

  static String? _extractError(dynamic json) {
    if (json is Map<String, dynamic>) {
      final err = json['error'];
      if (err is Map<String, dynamic>) return err['message'] as String?;
      if (err is String) return err;
    }
    return null;
  }
}