import 'package:flutter/material.dart';

import 'home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          body2: TextStyle(
            color: Colors.black,
            fontSize: 16.0,
          ),
          display1: TextStyle(color: Colors.black),
          display2: TextStyle(color: Colors.black),
        ),
      ),
      home: Homepage(),
    );
  }
}
