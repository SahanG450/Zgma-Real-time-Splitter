import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Classes/addBill.dart';
import '../Classes/abstract/addBill.dart';
import '../Classes/session.dart';
import '../sessionSummery.dart';

/// POSTs a bill/session to the backend and returns the parsed session + QR.
/// Throws an [Exception] with a user-presentable message on any failure.
Future<SessionCreateResult> createBill(Bill bill) async {
  late final http.Response response;
  try {
    response = await http.post(
      Uri.parse('http://172.20.10.2:3000/api/session/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(bill.toJson()),
    );
  } catch (e) {
    throw Exception('Could not reach the server. Check your connection and try again.');
  }

  Map<String, dynamic> decoded;
  try {
    decoded = jsonDecode(response.body) as Map<String, dynamic>;
  } catch (e) {
    throw Exception('Server returned an unexpected response.');
  }

  if (response.statusCode == 200 || response.statusCode == 201) {
    return SessionCreateResult.fromJson(decoded);
  }

  final message = (decoded['error'] is Map<String, dynamic>)
      ? (decoded['error']['message'] as String? ?? 'Failed to create bill')
      : (decoded['message'] as String? ?? 'Failed to create bill (${response.statusCode})');
  throw Exception(message);
}