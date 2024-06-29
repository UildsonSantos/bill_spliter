import 'package:flutter/material.dart';

import 'package:bill_splitter/screens/screens.dart';

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
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/simple_division': (context) => const SimpleDivisionScreen(),
        '/custom_division': (context) => const CustomDivisionScreen(),
      },
    );
  }
}
