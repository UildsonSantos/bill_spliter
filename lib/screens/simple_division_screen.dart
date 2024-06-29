import 'package:flutter/material.dart';

import 'package:bill_splitter/models/models.dart';

class SimpleDivisionScreen extends StatefulWidget {
  const SimpleDivisionScreen({super.key});

  @override
  State<SimpleDivisionScreen> createState() => _SimpleDivisionScreenState();
}

class _SimpleDivisionScreenState extends State<SimpleDivisionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _totalAmountController = TextEditingController();
  final _numberOfPeopleController = TextEditingController();
  final List<SplitAmount> _results = [];
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
        for (int i = 0; i < numberOfPeople - 1; i++) {
          _results.add(SplitAmount(
            'R\$ ${roundedSplitAmount.toStringAsFixed(2)}',
            false,
            false,
          ));
        }
        _results.add(SplitAmount(
          'R\$ ${adjustment.toStringAsFixed(2)}',
          false,
          adjustment.toStringAsFixed(2) == roundedSplitAmount.toStringAsFixed(2)
              ? false
              : true,
        ));
      });
    }
  }

  String? _validateSplitAmount(String? value) {
    totalAmount = int.parse(_totalAmountController.text);
    numberOfPeople = int.parse(_numberOfPeopleController.text);
    splitAmount = totalAmount / numberOfPeople;

    if (value == null || value.isEmpty) {
      return 'Por favor, digite o número de participantes';
    }

    final regex = RegExp(r'^([1-9][0-9]*\.[0-9]+|0\.[1-9][0-9]*)$');
    if (!regex.hasMatch(splitAmount.toString())) {
      return 'Desculpe, esta conta pode ser dividada por no máximo ${totalAmount * 10} participantes';
    }
    return null;
  }

  void _clearGrid() {
    if (_results.isNotEmpty) {
      setState(() {
        _results.clear();
      });
    }
  }

  void onChangeTextFormField(String value) {
    _clearGrid();
    if (_formKey.currentState!.validate()) {
      _calculateSplit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Divisor de contas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                onChanged: onChangeTextFormField,
                controller: _totalAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Valor total da conta',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, digite o valor total da conta.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                  onTap: () => _numberOfPeopleController.clear(),
                  onChanged: onChangeTextFormField,
                  controller: _numberOfPeopleController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Número de participantes',
                    prefixIcon: const Icon(Icons.people),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  validator: _validateSplitAmount),
              const SizedBox(height: 20),
              Expanded(
                child: _results.isEmpty
                    ? const Center(
                        child: Text(
                            'Por favor, digite os valores nos campos acima!'))
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 2,
                        ),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _results[index].isPaid =
                                    !_results[index].isPaid;
                              });
                            },
                            child: Card(
                              color: _results[index].isPaid
                                  ? const Color.fromARGB(255, 1, 255, 1)
                                  : (_results[index].isLast
                                      ? Colors.orange[200]
                                      : Colors.red[200]),
                              child: Center(
                                child: Text(
                                  _results[index].amount,
                                  style: const TextStyle(fontSize: 30),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
