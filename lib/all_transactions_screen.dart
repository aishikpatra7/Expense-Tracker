import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  _AllTransactionsScreenState createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  List<Map<String, String>> transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionString = prefs.getString('transactions') ?? '[]';
    final List<dynamic> transactionList = json.decode(transactionString);
    setState(() {
      transactions = transactionList
          .map((item) => Map<String, String>.from(item))
          .toList();
      _sortTransactionsByDate();
    });
  }

  void _sortTransactionsByDate() {
    transactions.sort((a, b) {
      final dateA = DateFormat('dd MMM').parse(a['date']!);
      final dateB = DateFormat('dd MMM').parse(b['date']!);
      return dateB.compareTo(dateA); // Latest date first
    });
  }

  void _deleteTransaction(int index) {
    setState(() {
      transactions.removeAt(index);
      _saveTransactions();
    });
  }

  void _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionString = json.encode(transactions);
    prefs.setString('transactions', transactionString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          bool isNegative = transaction['amount']!.contains('-');
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            child: ListTile(
              contentPadding: const EdgeInsets.all(15),
              title: Text(
                transaction['description']!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${transaction['amount']} ',
                      style: TextStyle(
                        color: isNegative ? Colors.red : Colors.green,
                      ),
                    ),
                    TextSpan(
                      text: '- ${transaction['date']}',
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteTransaction(index),
              ),
            ),
          );
        },
      ),
    );
  }
}
