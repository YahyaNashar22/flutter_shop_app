import 'package:flutter/material.dart';
import 'package:shop_app/widgets/grocery_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shop App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 2, 212, 254),
            surface: const Color.fromARGB(255, 44, 50, 60),
          ),
          scaffoldBackgroundColor: const Color.fromARGB(255, 49, 57, 59),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color.fromARGB(255, 49, 57, 59),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            labelStyle: TextStyle(color: Colors.white, fontSize: 14),
          )),
      home: const GroceryList(),
    );
  }
}
