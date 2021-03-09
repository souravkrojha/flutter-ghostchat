import 'package:chat_app/Screens/home_screen.dart';
import 'package:chat_app/Screens/singin_screen.dart';
import 'package:chat_app/functions/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Phoenix(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GhostChat',
      home: FutureBuilder(
        future: Authentication().getCurrentUser(),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return HomeScreen();
          } else {
            return SignInScreen();
          }
        },
      ),
    );
  }
}
