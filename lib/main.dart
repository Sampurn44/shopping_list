import 'package:flutter/material.dart';

import 'package:shopping_list/widgets/grocery_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Groceries',
      theme: ThemeData.dark().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 198, 186, 15),
          brightness: Brightness.dark,
          surface: const Color.fromARGB(255, 169, 167, 18),
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 43, 39, 39),
      ),
      home: const GroceryList(),
    );
  }
}
