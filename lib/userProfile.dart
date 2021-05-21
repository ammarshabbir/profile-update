import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'dart:io';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {

  File _image;
  final picker = ImagePicker();
  String url;

  bool progress = false;

  String name;
  String phoneNumber;
  String email;
  String password;


  Future getImage()async{
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if(pickedFile != null){
        _image = File(pickedFile.path);
      }else{
        print('No Image selected');
      }
    });
  }

  Future<void>uploadImage()async{
    setState(() {
      progress = true;
    });
    await firebase_storage.FirebaseStorage.instance.ref('profile/$phoneNumber').putFile(_image).then((value){
      setState(() {
        progress = false;
      });
      print('file uploaded');
    } ).catchError((e){
      print(e);
    });
  }

  Future<void>downloadURL()async{
    setState(() {
      progress = true;
    });
    String downloadURL = await firebase_storage.FirebaseStorage.instance.ref('profile/$phoneNumber').getDownloadURL();
    setState(() {
      url = downloadURL;
      progress = false;
    });
    url = downloadURL;
    print(url);
  }

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void>addUser(){
    setState(() {
      progress = true;
    });
    return users.doc(phoneNumber).set({
      'imageUrl':url,
      'name':name,
      'phoneNumber':phoneNumber,
      'email':email,
    }).then((value) {
      setState(() {
        progress = false;
      });
      print('user added');
    }).catchError((e){
      print(e);
    });
  }



  Future<void>uploadProfile()async{
    setState(() {
      progress = true;
    });
    await firebase_storage.FirebaseStorage.instance.ref('profile/$phoneNumber').putFile(_image).then((imageUpload)async{
      String downloadURL = await firebase_storage.FirebaseStorage.instance.ref('profile/$phoneNumber').getDownloadURL();
      setState(() {
        url = downloadURL;
      });
    }).whenComplete(() {
      return users.doc(phoneNumber).set({
        'imageUrl':url,
        'name':name,
        'phoneNumber':phoneNumber,
        'email':email,
      }).then((value) {
        setState(() {
          progress = false;
          print('user added');
        });
      });
    }).catchError((e){
      print(e);
    });

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('User Profile'),
      ),
      body: ModalProgressHUD(
        inAsyncCall: progress,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Center(
                  child: _image == null ? GestureDetector(
                    onTap: (){
                      getImage();
                    },
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.grey,
                      child: Icon(
                          Icons.camera_alt_rounded,
                        size: 70,
                      ),
                    ),
                  ):Image.file(
                      _image,
                    height: 180,
                    width: 150,
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        onChanged: (value){
                          name = value;
                        },
                        decoration: InputDecoration(
                          hintText: 'Name',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        onChanged: (value){
                          phoneNumber = value;
                        },
                        decoration: InputDecoration(
                          hintText: 'Phone Number',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        onChanged: (value){
                          email = value;
                        },
                        decoration: InputDecoration(
                            hintText: 'email'
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        onChanged: (value){
                          password = value;
                        },
                        decoration: InputDecoration(
                          hintText: 'password',
                        ),
                      ),
                    ),
                    RaisedButton(
                      onPressed: (){

                      uploadProfile();
                      },
                      child: Text('submit'),
                    ),
                    RaisedButton(
                      onPressed: (){
                        uploadImage();
                      },
                      child: Text('upload image'),
                    ),
                    RaisedButton(
                      onPressed: (){
                        downloadURL();
                      },
                      child: Text('download url'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
