import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './room.dart';
import 'dart:async';



class CreateRoom extends StatelessWidget {
  final myController = TextEditingController();
  final String account_name;
  CreateRoom(this.account_name);

  Widget roomlist (BuildContext context){
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('rooms').snapshots(),
      builder: (context,snapshot){
        return buildlist(context,snapshot.data.documents);
      },
    );
  }

  Widget buildlist(BuildContext context, List<DocumentSnapshot> snapshot){
    return ListView(
        scrollDirection:  Axis.vertical,
        shrinkWrap: true,
        padding: EdgeInsets.all(11.0),
        children: snapshot.map((data)=> buildlistitem(context,data)).toList()
    );
  }

  Widget buildlistitem(BuildContext context,DocumentSnapshot snapshot){
    Map<String, dynamic> person_map=snapshot.data;
    return GestureDetector(
        onTap: (){
          Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) => Room(person_map['name'],account_name),),
          );
        },
        child:ListTile(
          leading: Icon(Icons.play_arrow,),
          title: Text(person_map['name']),
    ));
  }

  Widget returnbutton (BuildContext context){
    return FlatButton(
      onPressed: (){
        SystemNavigator.pop();
      },
      child: (
          Text("アプリを終了")
      ),
      color: Colors.black12,
    );
  }





  @override
  void dispose() {
    myController.dispose();
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              roomlist(context),
              TextField(controller: myController,),
              FlatButton(
                onPressed: (){
                  Firestore.instance.collection('rooms').document(DateTime.now().toString()).setData({'name': myController.text});
                  Firestore.instance.collection(myController.text).document(DateTime.now().toString()).setData({'name': "bot","text":"roomが作成されました","type":"text"});
                },
                child: Text("create room"),
              )
            ],
          ),
        ),
      ),
    );
  }
}


