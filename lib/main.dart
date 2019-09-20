import 'package:flutter/material.dart';
import 'package:kredit_plus/pages/addItemsPage.dart';
import 'package:kredit_plus/pages/loginPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kredit Plus',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
      routes: <String, WidgetBuilder>{
        '/login': (BuildContext context) => LoginPage(),
        '/items-add': (BuildContext context) => AddItemsPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
