import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'all_transactions_screen.dart'; // Import the new screen
import 'new_expense_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  void _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionString = json.encode(transactions);
    prefs.setString('transactions', transactionString);
  }

  void _sortTransactionsByDate() {
    transactions.sort((a, b) {
      final dateA = DateFormat('dd MMM').parse(a['date']!);
      final dateB = DateFormat('dd MMM').parse(b['date']!);
      return dateB.compareTo(dateA); // Latest date first
    });
  }

  void _addNewTransaction(
      String description, String amount, String date, String type) {
    setState(() {
      transactions.add({
        'description': description,
        'amount': amount,
        'date': date,
        'type': type,
      });
      _sortTransactionsByDate();
      _saveTransactions();
    });
  }

  void _deleteTransaction(int index) {
    setState(() {
      transactions.removeAt(index);
      _saveTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalIncome = transactions
        .where((tx) => tx['type'] == 'income')
        .fold(0.0, (sum, tx) => sum + _parseAmount(tx['amount']!));
    double totalExpenses = transactions
        .where((tx) => tx['type'] == 'expense')
        .fold(0.0, (sum, tx) => sum + _parseAmount(tx['amount']!));
    double totalBalance = totalIncome - totalExpenses;

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.lightGreenAccent.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Expense Tracker',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Balance: Rs. ${totalBalance.toStringAsFixed(2)}/-',
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.blueAccent,
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) =>
                      NewExpenseScreen(onSave: _addNewTransaction),
                ),
              );
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Text(
                'Add Expense',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 20.0),
          const Text(
            'Recent Transactions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: transactions.length > 5 ? 5 : transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                bool isNegative =
                    transaction['type'] == 'expense'; // Check type
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
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
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.blueAccent,
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const AllTransactionsScreen(),
                ),
              );
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Text(
                'View All Transactions',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _parseAmount(String amount) {
    return double.tryParse(amount.replaceAll(RegExp(r'[^\d.-]'), '')) ?? 0.0;
  }
}
