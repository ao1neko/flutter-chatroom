import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart';

class Room extends StatefulWidget{
  final String roomname;
  Room(this.roomname);

  RoomState createState()=>RoomState(roomname);
}

class RoomState extends State<Room>{
  final myController = TextEditingController();
  var _image;
  final Directory tempDir = Directory.systemTemp;

  final String roomname;
  RoomState(this.roomname);

  Widget textlist (BuildContext context){
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection(roomname).snapshots(),
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
        children: snapshot.map((data)=> buildlistitem(context,data)).toList(),
        reverse: false,
    );
  }

  Widget buildlistitem(BuildContext context,DocumentSnapshot snapshot){
    Map<String, dynamic> person_map=snapshot.data;
    return ListTile(
      leading: Icon(Icons.play_arrow,),
      title: Text(person_map['text']),
    );
  }
  @override
  void dispose() {
    myController.dispose();
  }


  Future getImage() async{
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
      print(_image.path);
    });
  }

  Future uploadPic(BuildContext context) async{
    String filename= basename(_image.path);

    StorageReference ref= FirebaseStorage.instance.ref().child(filename);
    StorageUploadTask uploadTask = ref.putFile(_image);
    StorageTaskSnapshot taskSnapshot =await uploadTask.onComplete;
    String url= await taskSnapshot.ref.getDownloadURL();

    setState(() {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Profile Picture Uploaded')));
    });
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
              textlist(context),
              TextField(controller: myController,),
              FlatButton(
                onPressed: (){
                  Firestore.instance.collection(roomname).document(DateTime.now().toString()).setData({'name': "test","text":myController.text});
                },
                child: Text("talk"),
              ),
              RaisedButton(
                onPressed: () {
                  uploadPic(context);
                },
                child: Text('Submit', style: TextStyle(color: Colors.white, fontSize: 16.0),),
              ),
              RaisedButton(
                child: Text('search', style: TextStyle(color: Colors.white, fontSize: 16.0),),
                onPressed: () {
                  getImage();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}