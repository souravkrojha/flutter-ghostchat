import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final String name;
  final String userName;
  final String email;
  final String profilePicture;

  const ProfileScreen(
      {this.name, this.userName, this.email, this.profilePicture});
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Text(
          "Ghost Chat",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(
              widget.profilePicture,
              height: 200,
              width: 200,
            ),
            Text(
              widget.name,
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 30,
            ),
            Text(widget.userName,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w400)),
            SizedBox(
              height: 30,
            ),
            Text(widget.email,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300))
          ],
        ),
      ),
    );
  }
}
