import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewExpenseScreen extends StatefulWidget {
  final void Function(
      String description, String amount, String date, String type) onSave;

  const NewExpenseScreen({super.key, required this.onSave});

  @override
  _NewExpenseScreenState createState() => _NewExpenseScreenState();
}

class _NewExpenseScreenState extends State<NewExpenseScreen> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  String _transactionType = 'expense'; // Default to 'expense'

  void _submitData() {
    if (_amountController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _selectedDate == null) {
      return;
    }

    final enteredAmount = _amountController.text;
    final enteredDescription = _descriptionController.text;
    final formattedDate = DateFormat('dd MMM').format(_selectedDate!);

    widget.onSave(
      enteredDescription,
      enteredAmount,
      formattedDate,
      _transactionType,
    );

    Navigator.of(context).pop();
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'No Date Chosen!'
                        : 'Picked Date: ${DateFormat('dd MMM').format(_selectedDate!)}',
                  ),
                ),
                TextButton(
                  onPressed: _presentDatePicker,
                  child: const Text('Choose Date'),
                ),
              ],
            ),
            DropdownButton<String>(
              value: _transactionType,
              onChanged: (String? newValue) {
                setState(() {
                  _transactionType = newValue!;
                });
              },
              items: <String>['income', 'expense']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value[0].toUpperCase() + value.substring(1)),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitData,
              child: const Text('Save Transaction'),
            ),
          ],
        ),
      ),
    );
  }
}
