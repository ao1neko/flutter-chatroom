import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './create_room.dart';


class Auth extends StatefulWidget{
  AuthState createState()=>AuthState();
}

class AuthState extends State<Auth>{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  String account_name="";

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final AuthResult authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    account_name=currentUser.uid;
    assert(user.uid == currentUser.uid);

  }

  void signOutGoogle() async{
    await googleSignIn.signOut();

    print("User Sign Out");
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("myapp"),
      ),
      body: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              RaisedButton(
                onPressed: (){Navigator.pushNamed(context, '/createroom');},
                child: Text("go"),
              ),
              RaisedButton(
                onPressed:  () {
                  signInWithGoogle().whenComplete(() {
                    Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) => CreateRoom(account_name),),
                    );
                  });
                },
                child: Text("sign in"),
              ),
              RaisedButton(
                onPressed: () async {
                  signOutGoogle();
                },
                child: Text("sign out"),
              )
            ],
          ),
        ),
      ),
    );
  }
}