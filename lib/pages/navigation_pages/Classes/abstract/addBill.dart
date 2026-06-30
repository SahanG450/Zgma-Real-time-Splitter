import 'dart:convert';
import 'package:flutter/material.dart';
import '../addBill.dart';

abstract class SplitType {
  String get name;
  void calculate(
      List<Participant> participants,
      double totalAmount,
      );
}

abstract class Bill {

  String title;
  double totalAmount;
  String groupId;
  Category category;
  SplitType splitType;
  DateTime billDate;
  String description;
  List<Participant> participants;

  Bill({
    required this.title,
    required this.totalAmount,
    required this.category,
    required this.splitType,
    required this.billDate,
    required this.participants,
    required this.groupId,
    required this.description
  });

  void calculateSplit() {
    splitType.calculate(
      participants,
      totalAmount,
    );
  }

Map<String, dynamic> toJson() {
  return {
    "title": title,
    "amount": totalAmount,
    "groupId": groupId,
    "category": category,
    "splitType": splitType,
    "billDate": billDate.toIso8601String(),
    "description": description,
  };
}
  void validate();
}