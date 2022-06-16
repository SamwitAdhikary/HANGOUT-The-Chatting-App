import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hangout_test/HomePage/homepage_screen.dart';
import 'package:hangout_test/constants/configs.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateName extends StatefulWidget {
  @override
  State<UpdateName> createState() => _UpdateNameState();
}

class _UpdateNameState extends State<UpdateName> {
  final firebaseUser = FirebaseAuth.instance;

  TextEditingController nameController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _statusForm = GlobalKey<FormState>();

  final ImagePicker _picker = ImagePicker();
  XFile photo;
  String photoUrl = '';
  bool pressed = false;

  String deviceTokenToSendPushNotification;

  createUserInFireStore(String imgUrl) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: firebaseUser.currentUser.uid)
        .get();
    final List<DocumentSnapshot> documents = result.docs;
    if (documents.length == 0) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.currentUser.uid)
          .set({
        'active': "Online",
        'deviceToken': deviceTokenToSendPushNotification,
        'nickname': firebaseUser.currentUser.displayName,
        'status': statusController.text,
        'photoUrl': imgUrl,
        'id': firebaseUser.currentUser.uid,
        'phone': firebaseUser.currentUser.phoneNumber,
      });
    }
    print("User Name: ${firebaseUser.currentUser.displayName}");
  }

  void pickImage() async {
    photo =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 25);
  }

  Future<void> uploadPfp() async {
    File uploadFile = File(photo.path);
    try {
      await FirebaseStorage.instance
          .ref('uploads/${uploadFile.path}')
          .putFile(uploadFile != null ? uploadFile : File("assets/noimg.png"));
    } catch (e) {
      print(e);
    }
  }

  Future<String> getDownload() async {
    File uploadFile = File(photo.path);

    return FirebaseStorage.instance
        .ref('uploads/${uploadFile.path}')
        .getDownloadURL();
  }

  Future<void> getDeviceTokenToSendNotification() async {
    final FirebaseMessaging _fcm = FirebaseMessaging.instance;
    final token = await _fcm.getToken();
    deviceTokenToSendPushNotification = token.toString();
    print("Token Value: $deviceTokenToSendPushNotification");
  }

  @override
  Widget build(BuildContext context) {
    getDeviceTokenToSendNotification();
    return SafeArea(
      child: pressed == false
          ? Scaffold(
              backgroundColor: Configs.black,
              appBar: MyCustomAppBar(),
              body: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 60,
                      ),
                      profilePhoto(),
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  label: const Text(
                                    "Your Full Name",
                                  ),
                                  alignLabelWithHint: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Name must not be empty";
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              TextFormField(
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Bio must not be empty";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  alignLabelWithHint: true,
                                  hintText: "Bio",
                                ),
                                maxLength: 150,
                                maxLines: 5,
                                controller: statusController,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      GestureDetector(
                        onTap: photo == null
                            ? () {
                                showModal();
                              }
                            : () async {
                                if (_formKey.currentState.validate()) {
                                  setState(() {
                                    pressed = true;
                                  });
                                  FirebaseAuth.instance.currentUser
                                      .updateDisplayName(nameController.text);

                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();

                                  prefs.setString('name', nameController.text);

                                  await uploadPfp().then((value) {});

                                  String value = await getDownload();

                                  createUserInFireStore(value);

                                  FirebaseAuth.instance.currentUser
                                      .updatePhotoURL(value);

                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              HomePageScreen()));
                                }
                              },
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width * 0.7,
                          decoration: BoxDecoration(
                            color: Configs.black,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Continue",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          : Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.black12.withOpacity(0.1),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }

  void showModal() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          "Error",
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Please set your profile picture to continue.",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        actions: [
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Configs.black),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget profilePhoto() {
    return Form(
      child: GestureDetector(
        onTap: () {
          pickImage();
        },
        child: CircleAvatar(
          backgroundColor: Colors.grey[300],
          radius: 80,
          backgroundImage: photo != null ? FileImage(File(photo.path)) : null,
          child: photo == null
              ? Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 60,
                )
              : null,
        ),
      ),
    );
  }

  statusFormField() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Form(
        key: _statusForm,
        child: TextFormField(
          validator: (value) {
            if (value.isEmpty) {
              return "Bio must not be empty";
            }
            return null;
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            alignLabelWithHint: true,
            hintText: "Bio",
          ),
          maxLength: 150,
          maxLines: 5,
          controller: statusController,
        ),
      ),
    );
  }

  Widget textFormField() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Form(
        key: _formKey,
        child: TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            label: const Text(
              "Your Full Name",
            ),
            alignLabelWithHint: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          validator: (value) {
            if (value.isEmpty) {
              return "Name must not be empty";
            } else {
              return null;
            }
          },
        ),
      ),
    );
  }
}

class MyCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      // width: MediaQuery.of(context).size.width,
      // color: Colors.red,
      child: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 25),
        width: MediaQuery.of(context).size.width,
        child: Text(
          "Update Profile",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(80);
}
