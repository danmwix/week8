import 'package:flutter/material.dart';

class TransactionProvider with ChangeNotifier {
  String? _recipient;
  double? _amount;
  String? _accountType;
  bool _saveRecipient = false;

  String? get recipient => _recipient;
  double? get amount => _amount;
  String? get accountType => _accountType;
  bool get saveRecipient => _saveRecipient;

  void setTransaction(String recipient, double amount, String accountType, bool saveRecipient) {
    _recipient = recipient;
    _amount = amount;
    _accountType = accountType;
    _saveRecipient = saveRecipient;
    notifyListeners();
  }
}