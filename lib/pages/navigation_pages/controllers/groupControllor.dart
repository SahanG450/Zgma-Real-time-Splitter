import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<String>> getGroups(String userid) async {
  late final http.Response response;
  try {
    // Note: get() doesn't support a body in the http package. 
    // If your API requires a body, use post().
    response = await http.post(
      Uri.parse('http://10.0.2.2:3000/api/session/getGroup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userid}),
    );
  } catch (e) {
    throw Exception('Could not reach the server. Check your connection and try again.');
  }

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((group) => group.toString()).toList();
  } else {
    throw Exception('Failed to load groups. Status: ${response.statusCode}');
  }
}
