import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<String>> getGroups(String userid) async {
  print("DEBUG: API getGroups called for userId: $userid");
  late final http.Response response;
  try {
    response = await http.post(
      Uri.parse('http://10.0.2.2:3002/group/getGroup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userid}),
    );
  } catch (e) {
    print("DEBUG: API Connection Error: $e");
    throw Exception('Could not reach the server. Check your connection and try again.');
  }

  print("DEBUG: API Response: ${response.statusCode} - ${response.body}");

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    final List<dynamic> dataList = jsonResponse['data'] as List<dynamic>;
    
    // Extract only the 'name' field from each group object
    return dataList.map((group) => group['name'].toString()).toList();
  } else {
    throw Exception('Failed to load groups. Status: ${response.statusCode}');
  }
}
