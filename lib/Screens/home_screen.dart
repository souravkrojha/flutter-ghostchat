import 'package:chat_app/Screens/chat_screen.dart';
import 'package:chat_app/Screens/profile_screen.dart';
import 'package:chat_app/Screens/singin_screen.dart';
import 'package:chat_app/functions/auth.dart';
import 'package:chat_app/functions/database.dart';
import 'package:chat_app/utils/shared_pref_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  Stream chatRoomsStream;
  AnimationController animationController;

  TextEditingController _controller = TextEditingController();
  static const double minDragStartEdge = 60;
  static const double maxDragStartEdge = 150.0 - 16;
  String myName, myProfilePhoto, myUserName, myEmail;
  bool _canBeDragged = false;

  bool isSearching = false;
  Stream usersStream;
  getMyInfoFromPerfs() async {
    myName = await SharedPreferancesHelper().getDisplayName();
    myProfilePhoto = await SharedPreferancesHelper().getUSerProfilePicture();
    myUserName = await SharedPreferancesHelper().getUserName();
    myEmail = await SharedPreferancesHelper().getUserEmail();
  }

  getChatIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  onScearch() async {
    isSearching = true;
    setState(() {});
    usersStream = await Database().getUserByUserName(_controller.text);
    setState(() {});
  }

  Widget chatRoomList() {
    return StreamBuilder(
        stream: chatRoomsStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot doc = snapshot.data.docs[index];
                    return ChatRoomListTile(
                      chatId: doc.id,
                      lastMessage: doc["lastMessage"],
                      myUserName: myUserName,
                      lastMessageTimestamp: doc["lastMessageTimestamp"],
                    );
                  })
              : Center(
                  child: CircularProgressIndicator(),
                );
        });
  }

  Widget searchedUsersListTile(
      String profilePhotoUrl, String name, String email, String username) {
    return Container(
      margin: EdgeInsets.only(left: 50, top: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.network(
              profilePhotoUrl,
              height: 50,
              width: 50,
            ),
          ),
          SizedBox(
            width: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(name), Text(email)],
          ),
          SizedBox(
            width: 50,
          ),
          IconButton(
              icon: Icon(Icons.message),
              onPressed: () {
                var chatId = getChatIdByUsernames(myUserName, username);
                Map<String, dynamic> chatRoomInfo = {
                  "users": [myUserName, username]
                };
                Database().createChatRoom(chatId, chatRoomInfo);
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => ChatScreen(name: name, username: username),
                  ),
                );
              })
        ],
      ),
    );
  }

  Widget searchedUsersList() {
    return StreamBuilder(
      stream: usersStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot doc = snapshot.data.docs[index];
                  return searchedUsersListTile(doc['profilePhotoUrl'],
                      doc['name'], doc['email'], doc['username']);
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  toggle() {
    animationController.isDismissed
        ? animationController.forward()
        : animationController.reverse();
  }

  _onDragStart(DragStartDetails details) {
    bool isDragOpenFromLeft = animationController.isDismissed &&
        details.globalPosition.dx < minDragStartEdge;
    bool isDragCloseFromRight = animationController.isCompleted &&
        details.globalPosition.dx > maxDragStartEdge;

    _canBeDragged = isDragOpenFromLeft || isDragCloseFromRight;
  }

  _onDragUpdate(DragUpdateDetails details) {
    if (_canBeDragged) {
      double delta = details.primaryDelta / 150.0;
      animationController.value += delta;
    }
  }

  _onDragEnd(DragEndDetails details) {
    if (animationController.isDismissed || animationController.isCompleted) {
      return;
    }
    if (details.velocity.pixelsPerSecond.dx.abs() >= 365.0) {
      double visualVelocity = details.velocity.pixelsPerSecond.dx /
          MediaQuery.of(context).size.width;
      animationController.fling(velocity: visualVelocity);
    } else if (animationController.value < 0.5) {
      animationController.reverse();
    } else {
      animationController.forward();
    }
  }

  getChatRooms() async {
    chatRoomsStream = await Database().getChatRooms();
    setState(() {});
  }

  onLoad() async {
    await getMyInfoFromPerfs();
    getChatRooms();
    setState(() {});
  }

  @override
  void initState() {
    onLoad();
    setState(() {});
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, _) {
          double slide = 150.0 * animationController.value;
          double scale = 1 - (animationController.value * 0.35);
          return Stack(
            children: [
              Material(
                color: Color(0xff26c6da),
                child: SafeArea(
                  child: Theme(
                    data: ThemeData(brightness: Brightness.dark),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0, left: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "GhostChat",
                                style: TextStyle(
                                  fontSize: 50,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(
                                width: 100,
                              ),
                              InkWell(
                                onTap: () => toggle(),
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.close,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (_) => ProfileScreen(
                                            name: myName,
                                            email: myEmail,
                                            userName: myUserName,
                                            profilePicture: myProfilePhoto,
                                          )));
                            },
                            child: Row(
                              children: [
                                Text(
                                  "Profile   ",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white),
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                Icon(Icons.perm_contact_calendar_sharp)
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          InkWell(
                            onTap: () async {
                              const url =
                                  "https://github.com/bughunter-99/flutter-ghostchat";
                              if (await canLaunch(url)) {
                                await launch(url);
                              }
                            },
                            child: Row(
                              children: [
                                Text(
                                  "Code     ",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white),
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                Icon(Icons.code)
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          InkWell(
                            onTap: () async {
                              const url = "https://github.com/bughunter-99";
                              if (await canLaunch(url)) {
                                await launch(url);
                              }
                            },
                            child: Row(
                              children: [
                                Text(
                                  "Contact ",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(Icons.contact_page_outlined)
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          InkWell(
                            onTap: () {
                              Authentication().signOut().then((value) {
                                Navigator.pushReplacement(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (_) => SignInScreen(),
                                  ),
                                );
                              });
                            },
                            child: Row(
                              children: [
                                Text(
                                  "Sign Out",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(Icons.logout)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Transform(
                transform: Matrix4.identity()
                  ..translate(slide)
                  ..scale(scale),
                alignment: Alignment.centerLeft,
                child: Stack(
                  children: [
                    Scaffold(
                      key: _scaffoldKey,
                      appBar: AppBar(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        title: Text(
                          "Ghost Chat",
                          style: TextStyle(color: Colors.black),
                        ),
                        actions: [
                          IconButton(
                            icon: Icon(
                              Icons.settings,
                              color: Colors.black,
                            ),
                            onPressed: () => toggle(),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.white,
                      body: Container(
                        margin: EdgeInsets.symmetric(horizontal: 15),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Row(children: [
                                isSearching
                                    ? IconButton(
                                        icon:
                                            Icon(Icons.arrow_back_ios_outlined),
                                        onPressed: () {
                                          isSearching = false;
                                          _controller.text = "";
                                          setState(() {});
                                        })
                                    : Container(),
                                Expanded(
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 15),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey,
                                        style: BorderStyle.solid,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _controller,
                                            decoration: InputDecoration(
                                                hintText: "Search usernames",
                                                border: InputBorder.none,
                                                contentPadding:
                                                    EdgeInsets.all(0)),
                                            cursorColor: Colors.grey,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.search),
                                          onPressed: () {
                                            _controller.text == ""
                                                ? showDialog(
                                                    context: _scaffoldKey
                                                        .currentContext,
                                                    builder: (_) {
                                                      return AlertDialog(
                                                        title: Text("error"),
                                                        content: Text(
                                                            "Please enter a valid username"),
                                                        actions: [
                                                          ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child:
                                                                  Text("Close"))
                                                        ],
                                                      );
                                                    })
                                                : onScearch();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ]),
                              isSearching
                                  ? searchedUsersList()
                                  : chatRoomList(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                        bottom: 50,
                        left: 20,
                        child: SafeArea(
                          child: Material(
                            color: Colors.white,
                            child: Text(
                              "You can always search for osouravkumar \n to start messsageing...",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 20),
                            ),
                          ),
                        )),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage;
  final String chatId;
  final String myUserName;
  final Timestamp lastMessageTimestamp;

  ChatRoomListTile(
      {this.lastMessage,
      this.chatId,
      this.myUserName,
      this.lastMessageTimestamp});
  @override
  _ChatRoomListTileState createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String profilePicture;
  String name;
  String username;

  getThisUser() async {
    setState(() {});
    username =
        widget.chatId.replaceAll(widget.myUserName, "").replaceAll("_", "");
    QuerySnapshot querySnapshot = await Database().getUserInfo(username);
    print(querySnapshot.docs[0].id);
    name = querySnapshot.docs[0]['name'];
    profilePicture = querySnapshot.docs[0]["profilePhotoUrl"];
    setState(() {});
  }

  @override
  void initState() {
    getThisUser();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime date = widget.lastMessageTimestamp.toDate();
    return profilePicture == null && name == null
        ? SizedBox(
            width: 200.0,
            height: 100.0,
            child: Shimmer.fromColors(
              baseColor: Colors.grey[200],
              highlightColor: Colors.white,
              child: Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(10),
                color: Colors.grey,
              ),
            ),
          )
        : InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (_) => ChatScreen(
                            name: name,
                            username: username,
                          )));
            },
            child: Container(
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[100]))),
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      profilePicture,
                      height: 50,
                      width: 50,
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w400),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              widget.lastMessage,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w300),
                            ),
                          ],
                        ),
                        Positioned(
                          child: Text(DateFormat.jm().format(date)),
                          top: 5,
                          right: 10,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
  }
}
