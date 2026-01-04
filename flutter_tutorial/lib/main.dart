import 'package:flutter/material.dart';
import 'package:flutter_tutorial/views/widget_tree.dart';

void main() {
  runApp(const MyApp());
}

//Material_App(Statefull Wid)
//Scaffold
//AppBar
//NavigationBar

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 32, 219, 42),
          brightness: Brightness.dark
        ),
      ),

      home: WidgetTree()
      );
  }
}
  