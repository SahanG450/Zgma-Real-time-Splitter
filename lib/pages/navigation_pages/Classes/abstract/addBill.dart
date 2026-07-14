import 'dart:convert';
import 'package:flutter/material.dart';
import '../addBill.dart';

abstract class SplitType {
  String get name;
  void calculate(
      List<Participant> participants,
      double totalAmount,
      );
  Map<String, dynamic> toJson();
}

abstract class Bill {

  String title;
  double totalAmount;
  String? groupId;
  Category category;
  SplitType splitType;
  DateTime billDate;
  String description;
  String sessionType;
  List<Participant> participants;

  Bill({
    required this.title,
    required this.totalAmount,
    required this.category,
    required this.splitType,
    required this.billDate,
    required this.participants,
    required this.groupId,
    required this.description,
    required this.sessionType
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
      "sessionType": sessionType,

      // Enum -> String
      "category": category.name,
      // or category.displayName if your backend expects "Food", "Transport", etc.

      "splitType": splitType.toJson(), // if SplitType is a class

      "billDate": billDate.toIso8601String(),
      "description": description,

      "participants": participants
          .map((p) => p.toJson())
          .toList(),
    };
  }
  void validate();
}