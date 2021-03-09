import 'package:chat_app/Screens/home_screen.dart';
import 'package:chat_app/functions/database.dart';
import 'package:chat_app/utils/shared_pref_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Authentication {
  final FirebaseAuth auth = FirebaseAuth.instance;
  Future getCurrentUser() async {
    return auth.currentUser;
  }

  signInWithGoogle(BuildContext context) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final GoogleSignIn _signIn = GoogleSignIn();
    final GoogleSignInAccount signInAccount = await _signIn.signIn();
    final GoogleSignInAuthentication signInAuthentication =
        await signInAccount.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: signInAuthentication.idToken,
        accessToken: signInAuthentication.accessToken);
    UserCredential userCredential =
        await _auth.signInWithCredential(credential);
    User userDetails = userCredential.user;

    if (userCredential == null) {
    } else {
      SharedPreferancesHelper().saveUserId(userDetails.uid);
      SharedPreferancesHelper()
          .saveUserName(userDetails.email.replaceAll("@gmail.com", ""));
      SharedPreferancesHelper().saveDisplayName(userDetails.displayName);
      SharedPreferancesHelper().saveUserEmail(userDetails.email);
      SharedPreferancesHelper().saveUserProfile(userDetails.photoURL);
      Map<String, dynamic> userInfo = {
        "email": userDetails.email,
        "username": userDetails.email.replaceAll("@gmail.com", ""),
        "name": userDetails.displayName,
        "userId": userDetails.uid,
        "profilePhotoUrl": userDetails.photoURL
      };

      Database().addUserInfoToFirestore(userDetails.uid, userInfo).then(
            (value) => {
              Navigator.pushReplacement(
                context,
                CupertinoPageRoute(
                  builder: (context) => HomeScreen(),
                ),
              )
            },
          );
      Phoenix.rebirth(context);
    }
  }

  signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    await auth.signOut();
  }
}
