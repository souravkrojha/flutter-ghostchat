import 'package:chat_app/utils/shared_pref_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  // add the users information to firebase firestore
  Future addUserInfoToFirestore(
      String userId, Map<String, dynamic> userInfo) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .set(userInfo);
  }

  // search a user by their username
  Future<Stream<QuerySnapshot>> getUserByUserName(String username) async {
    return FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: username)
        .snapshots();
  }

  //add messages to databse
  Future addMessage(String chatId, String messageId, Map messageInfo) async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatId)
        .collection("chats")
        .doc(messageId)
        .set(messageInfo);
  }

  //to update the last message sent
  updateLastMessageSent(String chatId, Map lastMessageInfo) {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatId)
        .update(lastMessageInfo);
  }

  // to create a chat room
  createChatRoom(String chatId, Map chatRoomInfo) async {
    final snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatId)
        .get();
    if (snapshot.exists) {
      return true;
    } else {
      return FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(chatId)
          .set(chatRoomInfo);
    }
  }

  // to get the chat messages
  Future<Stream<QuerySnapshot>> getChatMessages(String chatId) async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatId)
        .collection("chats")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  // to get the chat rooms
  Future<Stream<QuerySnapshot>> getChatRooms() async {
    String myUserName = await SharedPreferancesHelper().getUserName();
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .orderBy("lastMessageTimestamp", descending: true)
        .where('users', arrayContains: myUserName)
        .snapshots();
  }

  Future<QuerySnapshot> getUserInfo(String username) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: username)
        .get();
  }
}
