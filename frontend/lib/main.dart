import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wybr/mainScreen.dart';

void main() {
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        appBarTheme: AppBarTheme(
            titleTextStyle: TextStyle(
              fontSize: 29,
              color: Colors.black,
              fontWeight: FontWeight.bold
            )
          ),
        textTheme: TextTheme(
          titleMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          bodyMedium: TextStyle(
            fontSize: 15,
          ),
          headlineMedium: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)
        ),
      ),
      home: Mainscreen()
    );
  }
}