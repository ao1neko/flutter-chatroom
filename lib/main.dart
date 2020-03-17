import 'package:flutter/material.dart';
import './pages/auth.dart';
import './pages/create_room.dart';
import './pages/room.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/':(context)=> Auth(),
        '/createroom':(context)=>CreateRoom(),
      },
    );
  }
}
