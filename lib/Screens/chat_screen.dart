import 'package:chat_app/functions/database.dart';
import 'package:chat_app/utils/shared_pref_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';

class ChatScreen extends StatefulWidget {
  final String username, name;

  ChatScreen({this.username, this.name});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _controller = TextEditingController();
  Stream messageStream;
  String chatId, messageId = '';
  String myName, myProfilePhoto, myUserName, myEmail;

  getMyInfoFromPerfs() async {
    myName = await SharedPreferancesHelper().getDisplayName();
    myProfilePhoto = await SharedPreferancesHelper().getUSerProfilePicture();
    myUserName = await SharedPreferancesHelper().getUserName();
    myEmail = await SharedPreferancesHelper().getUserEmail();

    chatId = getChatIdByUsernames(widget.username, myUserName);
  }

  getChatIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  addMessage(bool clicked) {
    if (_controller.text != "") {
      String message = _controller.text;
      var lastMessageTime = DateTime.now();
      Map<String, dynamic> messageInfo = {
        "message": message,
        "sentBy": myUserName,
        "timestamp": lastMessageTime,
        "imgUrl": myProfilePhoto
      };
      if (messageId == "") {
        messageId = randomAlphaNumeric(12);
      }
      Database().addMessage(chatId, messageId, messageInfo).then((value) {
        Map<String, dynamic> lastMessageInfo = {
          "lastMessage": message,
          "lastMessageTimestamp": lastMessageTime,
          "lastMessageSentBy": myUserName
        };
        Database().updateLastMessageSent(chatId, lastMessageInfo);
        if (clicked) {
          _controller.text = "";
          messageId = "";
        }
      });
    }
  }

  getAndSetMessages() async {
    messageStream = await Database().getChatMessages(chatId);
    setState(() {});
  }

  doThisOnLaunch() async {
    await getMyInfoFromPerfs();
    getAndSetMessages();
    setState(() {});
  }

  Widget messageTile(String message, String imgUrl, bool sentByMe) {
    return Row(
        mainAxisAlignment:
            sentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            decoration: BoxDecoration(
                color: sentByMe ? Colors.blueAccent : Colors.grey[300],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomRight:
                      sentByMe ? Radius.circular(0) : Radius.circular(24),
                  topRight: Radius.circular(24),
                  bottomLeft:
                      sentByMe ? Radius.circular(24) : Radius.circular(0),
                )),
            padding: EdgeInsets.all(8),
            child: Text(
              message,
              style: TextStyle(color: sentByMe ? Colors.white : Colors.black),
            ),
          ),
        ]);
  }

  Widget messages() {
    return StreamBuilder(
        stream: messageStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  reverse: true,
                  padding: EdgeInsets.only(
                    bottom: 60,
                  ),
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot doc = snapshot.data.docs[index];
                    return messageTile(doc["message"], doc['imgUrl'],
                        myUserName == doc['sentBy']);
                  })
              : Center(child: CircularProgressIndicator());
        });
  }

  @override
  void initState() {
    doThisOnLaunch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
            color: Colors.black,
            icon: Icon(
              Icons.arrow_back_ios,
              size: 20,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Text(
          widget.name,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            messages(),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                padding: EdgeInsets.only(left: 16, right: 5),
                decoration: BoxDecoration(
                    color: Color(0xff373737),
                    borderRadius: BorderRadius.circular(50)),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          addMessage(false);
                        },
                        controller: _controller,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                        ),
                        cursorColor: Colors.grey,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Type a message",
                          hintStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        addMessage(true);
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.send,
                          size: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
