import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Sends a receipt image to the backend OCR service.
/// Uses multipart/form-data as requested.
Future<Map<String, dynamic>> scanReceipt(File imageFile) async {
  debugPrint("DEBUG: scanReceipt called with file: ${imageFile.path}");
  
  // Assuming 3002 based on the group controller port
  final url = Uri.parse('http://10.0.2.2:3002/orc');
  
  try {
    var request = http.MultipartRequest('POST', url);
    
    // Create multipart file from the image path
    var multipartFile = await http.MultipartFile.fromPath(
      'image', // The field name the backend expects
      imageFile.path,
    );
    
    request.files.add(multipartFile);
    
    // Send the request
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    
    debugPrint("DEBUG: Scan A Response: ${response.statusCode} - ${response.body}");
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      if (decoded['success'] == true) {
        final data = decoded['data'];
        // Extraction logic for the nested "result" object
        if (data is Map<String, dynamic> && data.containsKey('result')) {
          return data['result'] as Map<String, dynamic>;
        }
        return data as Map<String, dynamic>;
      }
      throw Exception(decoded['message'] ?? 'OCR processing failed');
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint("DEBUG: Scan API Error: $e");
    throw Exception('Failed to connect to OCR service: $e');
  }
}
