import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hangout_test/constants/configs.dart';

class ProfileScreen extends StatefulWidget {
  final String imgUrl;
  final String name;
  final String status;

  ProfileScreen({
    @required this.imgUrl,
    @required this.name,
    @required this.status,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState(
        imgUrl: imgUrl,
        name: name,
        status: status,
      );
}

class _ProfileScreenState extends State<ProfileScreen> {
  final String imgUrl;
  final String name;
  final String status;

  _ProfileScreenState({
    @required this.imgUrl,
    @required this.name,
    @required this.status,
  });

  final _nameFormKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();

  final _statusFormKey = GlobalKey<FormState>();
  TextEditingController statusController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Configs.black,
        appBar: MyAppBar(),
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
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Something went wrong"),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasData) {
                  return Column(
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                            snapshot.data['photoUrl']),
                        radius: 60,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      ListTile(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => Dialog(
                              child: Container(
                                height: 250,
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      child: Text(
                                        "Change Name",
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      width: MediaQuery.of(context).size.width,
                                      padding: EdgeInsets.only(left: 30),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Form(
                                      key: _nameFormKey,
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.7,
                                        child: TextFormField(
                                          controller: nameController,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            alignLabelWithHint: true,
                                            hintText: "Enter your name",
                                          ),
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return "Name cannot be empty";
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text("Cancel"),
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            if (_nameFormKey.currentState
                                                .validate()) {
                                              print(nameController.text);
                                              FirebaseAuth.instance.currentUser
                                                  .updateDisplayName(
                                                      nameController.text);

                                              FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(FirebaseAuth
                                                      .instance.currentUser.uid)
                                                  .update({
                                                'nickname': nameController.text,
                                              });

                                              Navigator.pop(context);
                                            }
                                          },
                                          child: Text("Save"),
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        leading: Icon(Icons.person),
                        title: Text(
                          snapshot.data['nickname'],
                          style: TextStyle(fontSize: 18),
                        ),
                        subtitle: Text(
                            "This is your username. This name will be visible to your HangOut contacts."),
                        trailing: Icon(
                          Icons.edit,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ListTile(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => Dialog(
                              child: Container(
                                height: 250,
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      child: Text(
                                        "Change Bio",
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      width: MediaQuery.of(context).size.width,
                                      padding: EdgeInsets.only(left: 30),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Form(
                                      key: _statusFormKey,
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.7,
                                        child: TextFormField(
                                          controller: statusController,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            alignLabelWithHint: true,
                                            hintText: "Enter your Bio",
                                          ),
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return "Bio cannot be empty";
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text("Cancel"),
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            if (_statusFormKey.currentState
                                                .validate()) {
                                              print(statusController.text);
                                              // FirebaseAuth.instance.currentUser
                                              //     .updateDisplayName(
                                              //         nameController.text);

                                              FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(FirebaseAuth
                                                      .instance.currentUser.uid)
                                                  .update({
                                                'status': statusController.text,
                                              });

                                              Navigator.pop(context);
                                            }
                                          },
                                          child: Text("Save"),
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        leading: Icon(Icons.info_outline),
                        title: Text(
                          snapshot.data['status'],
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text("This is your bio."),
                        trailing: Icon(Icons.edit),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ListTile(
                        leading: Icon(Icons.phone),
                        title: Text(
                          snapshot.data['phone'],
                          style: TextStyle(fontSize: 18),
                        ),
                        subtitle: Text("Phone"),
                      )
                    ],
                  );
                }

                return Container();
              },
            ),
          ),
        ),
      ),
    );
  }
}

class MyAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: 25),
      height: MediaQuery.of(context).size.height,
      // color: Colors.red,
      child: Text(
        "Profile",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 30,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(80);
}
