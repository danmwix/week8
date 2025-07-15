import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/transaction_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_card.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  _TransferScreenState createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  String? _selectedAccount;
  bool _saveRecipient = false;
  bool _showSuccess = false;
  late AnimationController _animationController;
  late Animation<Offset> _animation;

  final List<String> _accounts = ['Savings', 'Checking', 'Investment'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      Provider.of<TransactionProvider>(context, listen: false).setTransaction(
        _recipientController.text,
        amount,
        _selectedAccount!,
        _saveRecipient,
      );
      setState(() {
        _showSuccess = true;
      });
      _animationController.forward();
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _showSuccess = false;
        });
        _animationController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Money'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppStyles.defaultPadding),
          child: CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _recipientController,
                        decoration: const InputDecoration(
                          labelText: 'Recipient Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a recipient name';
                          }
                          if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                            return 'Name should contain only letters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppStyles.defaultPadding),
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppStyles.defaultPadding),
                      DropdownButtonFormField<String>(
                        value: _selectedAccount,
                        decoration: const InputDecoration(
                          labelText: 'Account Type',
                          border: OutlineInputBorder(),
                        ),
                        items: _accounts
                            .map((account) => DropdownMenuItem(
                                  value: account,
                                  child: Text(account),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedAccount = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select an account';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppStyles.defaultPadding),
                      SwitchListTile(
                        title: const Text('Save Recipient'),
                        value: _saveRecipient,
                        onChanged: (value) {
                          setState(() {
                            _saveRecipient = value;
                          });
                        },
                      ),
                      const SizedBox(height: AppStyles.defaultPadding),
                      CustomButton(
                        text: 'Submit Transfer',
                        onPressed: _submitForm,
                      ),
                    ],
                  ),
                ),
                if (_showSuccess)
                  SlideTransition(
                    position: _animation,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppStyles.defaultPadding),
                      color: Colors.green,
                      child: const Text(
                        'Transfer Successful!',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}