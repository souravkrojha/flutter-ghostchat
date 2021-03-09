import 'package:chat_app/functions/auth.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "GhostChat",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w300),
              ),
              SizedBox(
                height: 50,
              ),
              SignInButton(
                Buttons.GoogleDark,
                onPressed: () {
                  Authentication().signInWithGoogle(context);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
