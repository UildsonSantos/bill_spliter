import 'package:flutter/material.dart';

import 'package:bill_splitter/models/models.dart';

class CustomDivisionScreen extends StatefulWidget {
  const CustomDivisionScreen({super.key});

  @override
  State<CustomDivisionScreen> createState() => _CustomDivisionScreenState();
}

class _CustomDivisionScreenState extends State<CustomDivisionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _totalAmountController = TextEditingController();
  final _numberOfPeopleController = TextEditingController();
  String? _numberOfPeopleErrorText;
  final List<SplitAmount> _results = [];
  final List<double> _updatedAmounts = [];
  int totalAmount = 0;
  int numberOfPeople = 0;
  double splitAmount = 0.0;

  @override
  void dispose() {
    _totalAmountController.dispose();
    _numberOfPeopleController.dispose();
    super.dispose();
  }

  void _calculateSplit() {
    if (_formKey.currentState!.validate()) {
      totalAmount = int.parse(_totalAmountController.text);
      numberOfPeople = int.parse(_numberOfPeopleController.text);
      splitAmount = totalAmount / numberOfPeople;

      double roundedSplitAmount = (splitAmount * 100).round() / 100;
      double adjustment =
          totalAmount - (roundedSplitAmount * (numberOfPeople - 1));

      setState(() {
        _results.clear();
        _updatedAmounts.clear();
        for (int i = 0; i < numberOfPeople - 1; i++) {
          _results.add(SplitAmount(
            'R\$ ${roundedSplitAmount.toStringAsFixed(2)}',
            false,
            false,
          ));
          _updatedAmounts.add(roundedSplitAmount);
        }
        _results.add(SplitAmount(
          'R\$ ${adjustment.toStringAsFixed(2)}',
          false,
          adjustment.toStringAsFixed(2) !=
              roundedSplitAmount.toStringAsFixed(2),
        ));
        _updatedAmounts.add(adjustment);
      });
    }
  }

  String? _validateTotalAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, digite o valor total da conta.';
    }
    return null;
  }

  String? _validateNumberOfPeople(String? value) {
    totalAmount = int.parse(_totalAmountController.text);
    numberOfPeople = int.parse(_numberOfPeopleController.text);
    if (value == null || value.isEmpty) {
      setState(() {
        _numberOfPeopleErrorText =
            'Por favor, digite o número de participantes';
      });
      return null;
    }

    if (numberOfPeople > totalAmount) {
      setState(() {
        _numberOfPeopleErrorText =
            'Desculpe, esta conta pode ser dividida por no máximo $totalAmount participantes';
      });
      return null;
    }

    setState(() {
      _numberOfPeopleErrorText = null;
    });
    return null;
  }

  void _clearGrid() {
    if (_results.isNotEmpty) {
      setState(() {
        _results.clear();
        _updatedAmounts.clear();
      });
    }
  }

  void _onChangeTextFormField(String value) {
    _clearGrid();
    if (_formKey.currentState!.validate() && _numberOfPeopleErrorText == null) {
      _calculateSplit();
    }
  }

  void _clearTextFormFieldNumberOfPeople() {
    _numberOfPeopleController.clear();
    _clearGrid();
    setState(() {
      _numberOfPeopleErrorText = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Divisão Simples'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                onChanged: _onChangeTextFormField,
                controller: _totalAmountController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: 'Valor total da conta',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: _validateTotalAmount,
              ),
              const SizedBox(height: 20),
              TextFormField(
                onTap: _clearTextFormFieldNumberOfPeople,
                onChanged: _onChangeTextFormField,
                controller: _numberOfPeopleController,
                keyboardType: TextInputType.number,
                maxLength: totalAmount.toString().length,
                decoration: InputDecoration(
                  labelText: 'Número de participantes',
                  prefixIcon: const Icon(Icons.people),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  errorText: _numberOfPeopleErrorText,
                ),
                validator: _validateNumberOfPeople,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _results.isEmpty
                    ? const Center(
                        child: Text(
                            'Por favor, digite os valores válidos nos campos acima!'))
                    : ListView.builder(
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          return _buildListItem(index);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(int index) {
    final originalAmount =
        double.parse(_results[index].amount.replaceAll('R\$ ', ''));
    final textController = TextEditingController();

    return Card(
      color: _results[index].isPaid
          ? const Color.fromARGB(255, 1, 255, 1)
          : (_results[index].isLast ? Colors.orange[200] : Colors.red[200]),
      child: ListTile(
        title: Row(
          children: [
            Text(
              _results[index].amount,
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade900),
            ),
            const SizedBox(width: 30),
            Expanded(
              child: TextFormField(
                controller: textController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Valor adicional',
                ),
                onChanged: (value) {
                  setState(() {
                    if (value.isNotEmpty) {
                      var addedValue = double.parse(value);
                      _updatedAmounts[index] = originalAmount + addedValue;
                    } else {
                      _updatedAmounts[index] = originalAmount;
                    }
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'R\$ ${_updatedAmounts[index].toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
