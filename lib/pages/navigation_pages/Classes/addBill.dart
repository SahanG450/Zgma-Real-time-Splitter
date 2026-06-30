import './abstract/addBill.dart';
// Bill Main class
enum Category {
  food,
  transport,
  hotel,
  entertainment,
  groceries,
  other,
}

extension CategoryExtension on Category {
  String get displayName {
    switch (this) {
      case Category.food:
        return "Food";
      case Category.transport:
        return "Transport";
      case Category.hotel:
        return "Hotel";
      case Category.entertainment:
        return "Entertainment";
      case Category.groceries:
        return "Groceries";
      case Category.other:
        return "Other";
    }
  }
}

// participant
class Participant {
  final String id;
  final String name;

  double contribution;

  Participant({
    required this.id,
    required this.name,
    this.contribution = 0,
  });
}

//bill items
class BillItem {

  String name;
  double price;
  int quantity;

  BillItem({
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  double get total => price * quantity;
}

// bill methods

class ManualBill extends Bill {

  ManualBill({
    required super.title,
    required super.totalAmount,
    required super.category,
    required super.splitType,
    required super.billDate,
    required super.groupId,
    required super.description,
    required super.participants,
  });

  @override
  void validate() {
    if (title.trim().isEmpty) {
      throw Exception("Bill title is required.");
    }

    if (totalAmount <= 0) {
      throw Exception("Amount must be greater than zero.");
    }

    if (participants.isEmpty) {
      throw Exception("At least one participant is required.");
    }
  }
}

class ScanBill extends Bill {

  List<BillItem> items;

  ScanBill({
    required super.title,
    required super.totalAmount,
    required super.category,
    required super.splitType,
    required super.billDate,
    required super.participants,
    required super.groupId,
    required super.description,
    required this.items,
  });

  @override
  void validate() {

    if (items.isEmpty) {
      throw Exception("Receipt contains no items.");
    }

    double total = 0;

    for (var item in items) {
      total += item.total;
    }

    if (total != totalAmount) {
      throw Exception(
        "Receipt total doesn't match bill amount.",
      );
    }
  }
}

class ScheduleBill extends Bill {

  DateTime expireDate;

  ScheduleBill({
    required super.title,
    required super.totalAmount,
    required super.category,
    required super.splitType,
    required super.billDate,
    required super.participants,
    required super.groupId,
    required super.description,
    required this.expireDate,
  });

  bool get isExpired =>
      DateTime.now().isAfter(expireDate);

  @override
  void validate() {

    if (expireDate.isBefore(billDate)) {
      throw Exception(
        "Expire date must be after bill date.",
      );
    }
  }
}

// spliter method

class EqualSplit extends SplitType {

  @override
  String get name => "Equal";

  @override
  void calculate(
      List<Participant> participants,
      double totalAmount,
      ) {

    double share = totalAmount / participants.length;

    for (var p in participants) {
      p.contribution = share;
    }
  }
}

class AmountSplit extends SplitType {

  @override
  String get name => "Amount";

  @override
  void calculate(
      List<Participant> participants,
      double totalAmount,
      ) {

    double total = 0;

    for (var p in participants) {
      total += p.contribution;
    }

    if (total != totalAmount) {
      throw Exception(
          "Amounts do not equal total bill.");
    }
  }
}

class PercentageSplit extends SplitType {

  final Map<String, double> percentages;

  PercentageSplit(this.percentages);

  @override
  String get name => "Percentage";

  @override
  void calculate(
      List<Participant> participants,
      double totalAmount,
      ) {

    for (var p in participants) {
      p.contribution =totalAmount * percentages[p.id]! /100;
    }
  }
}

class SharesSplit extends SplitType {

  final Map<String, int> shares;

  SharesSplit(this.shares);

  @override
  String get name => "Shares";

  @override
  void calculate(
      List<Participant> participants,
      double totalAmount,
      ) {

    int totalShares =
    shares.values.reduce((a, b) => a + b);

    for (var p in participants) {
      p.contribution =
          totalAmount *
              shares[p.id]! /
              totalShares;
    }
  }
}