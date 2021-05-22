import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'dart:io';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {


  File _image;
  final picker = ImagePicker();
  String url;

  bool progress = false;

  String name;
  String phoneNumber;
  String email;
  String password;

  final _auth = FirebaseAuth.instance;



  Future<void>loginUser()async{
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email, password: password);
    if(userCredential != null){
      print('User loged in');
    }else{
      print('user not logged in');
    }
  }



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


  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void>uploadProfile()async{
    setState(() {
      progress = true;
    });

    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email, password: password).whenComplete(() async{
      await firebase_storage.FirebaseStorage.instance.ref('profile/${_auth.currentUser.uid}').putFile(_image).then((imageUploade)async{
        String downloadURL = await firebase_storage.FirebaseStorage.instance.ref('profile/${_auth.currentUser.uid}').getDownloadURL();
        setState(() {
          url = downloadURL;
        });
      });
    }).whenComplete(() {
      return users.doc(_auth.currentUser.uid).set({
        'imageUrl':url,
        'name':name,
        'phoneNumber':phoneNumber,
        'email':email,
      }).then((value) {
        setState(() {
          progress = false;
          print('user added');
          Navigator.of(context).pushNamed('/profilePage');
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
        title: Text('Signup Page'),
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
                  ):CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.grey,
                    backgroundImage: FileImage(_image),
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
                        obscureText: true,
                        onChanged: (value){
                          password = value;
                        },
                        decoration: InputDecoration(
                          hintText: 'password',
                        ),
                      ),
                    ),
                   GestureDetector(
                     onTap: (){
                       uploadProfile();

                     },
                     child: Container(
                       padding: EdgeInsets.all(10),
                       decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(20),
                         color: Colors.blue,
                       ),
                       child: Center(
                         child: Text(
                             'Sign up',
                           style: TextStyle(
                             color: Colors.white,
                             fontSize: 18,
                           ),
                         ),
                       ),
                     ),
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
