import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Classes/addBill.dart';
import '../Classes/abstract/addBill.dart';

Future<void> createBill(Bill bill) async {
  print("-----------------------------------------------");
  try {
    print("try case work");
    final response = await http.post(
      Uri.parse(
        'http://10.0.2.2:3000/api/session/create',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(bill.toJson()),
    );
    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      print("Fail Section ");
    } else {
      print("'sucess section");
    }
  } catch (e) {
    print(e);
  }
}