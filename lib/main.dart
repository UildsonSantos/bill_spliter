import 'package:flutter/material.dart';

void main() {
  runApp(const BillSplitterApp());
}

class BillSplitterApp extends StatelessWidget {
  const BillSplitterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Divisor de contas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BillSplitterScreen(),
    );
  }
}

class BillSplitterScreen extends StatefulWidget {
  const BillSplitterScreen({super.key});

  @override
  BillSplitterScreenState createState() => BillSplitterScreenState();
}

class BillSplitterScreenState extends State<BillSplitterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _totalAmountController = TextEditingController();
  final _numberOfPeopleController = TextEditingController();
  final List<SplitAmount> _results = [];

  void _calculateSplit() {
    if (_formKey.currentState!.validate()) {
      double totalAmount = double.parse(_totalAmountController.text);
      int numberOfPeople = int.parse(_numberOfPeopleController.text);
      double splitAmount = totalAmount / numberOfPeople;
      double roundedSplitAmount = (splitAmount * 100).round() / 100;
      double totalRounded = roundedSplitAmount * numberOfPeople;
      double adjustment = totalAmount - totalRounded;

      setState(() {
        _results.clear();
        for (int i = 0; i < numberOfPeople - 1; i++) {
          _results.add(SplitAmount(
              'R\$ ${roundedSplitAmount.toStringAsFixed(2)}', false));
        }
        _results.add(SplitAmount(
            'R\$ ${(roundedSplitAmount + adjustment).toStringAsFixed(2)}',
            false));
      });
    }
  }

  @override
  void dispose() {
    _totalAmountController.dispose();
    _numberOfPeopleController.dispose();
    super.dispose();
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
                controller: _totalAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Valor da conta'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor insira o valor total da conta';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _numberOfPeopleController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Número de pessoas'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor insira o número de pessoas';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _calculateSplit,
                child: const Text('Calcular'),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2,
                  ),
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _results[index].isPaid = !_results[index].isPaid;
                        });
                      },
                      child: Card(
                        color: _results[index].isPaid
                            ? const Color.fromARGB(255, 1, 255, 1)
                            : Colors.red.shade200,
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

class SplitAmount {
  final String amount;
  bool isPaid;

  SplitAmount(this.amount, this.isPaid);
}
