import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

Future<List<Map<String, String>>> getGroups(String userid) async {
  debugPrint("DEBUG: API getGroups called for userId: $userid");
  late final http.Response response;
  try {
    response = await http.post(
      Uri.parse('http://172.20.10.2:3002/group/getGroup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userid}),
    );
  } catch (e) {
    debugPrint("DEBUG: API Connecion Error: $e");
    throw Exception('Could not reach the server. Check your connection and try again.');
  }

  debugPrint("DEBUG: API Response: ${response.statusCode} - ${response.body}");

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    final List<dynamic> dataList = jsonResponse['data'] as List<dynamic>;
    
    // Return list of maps with both id and name
    return dataList.map<Map<String, String>>((group) => {
      'id': group['id'].toString(),
      'name': group['name'].toString(),
    }).toList();
  } else {
    throw Exception('Failed to load groups. Status: ${response.statusCode}');
  }
}
