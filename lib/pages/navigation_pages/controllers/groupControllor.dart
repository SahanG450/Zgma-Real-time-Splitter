import 'dart:convert';

Future<SessionCreateResult> getGroups(string userid) async {
  late final http.Response response;
  try {
    response = await http.get(
      Uri.parse('http://10.0.2.2:3000/api/session/getGroup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userid.toJson()),
    );
  } catch (e) {
    throw Exception('Could not reach the server. Check your connection and try again.');
  }

}