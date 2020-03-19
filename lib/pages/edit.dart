import 'package:flutter/material.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:path/path.dart';

class Edit extends StatefulWidget{
  final String account_name,account_id;
  Edit(this.account_id,this.account_name);

  EditState createState()=>EditState(account_id,account_name);
}

class EditState extends State<Edit>{
  final myController = TextEditingController();
  var _image;
  var url;
  final Directory tempDir = Directory.systemTemp;

  final String account_name,account_id;
  EditState(this.account_id,this.account_name);

  @override
  void dispose() {
    myController.dispose();
  }


  Widget textlist (BuildContext context){
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection(account_id).snapshots(),
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

      return
          Container(child:Image.network(person_map["path"],width: 200.0,height: 100.0,fit:BoxFit.contain)
      );
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
     url= await taskSnapshot.ref.getDownloadURL();
    print(url);
    Firestore.instance.collection(account_id).document(account_id).setData({'path': url,"name":account_name});
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
              Text(account_name),
              textlist(context),
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