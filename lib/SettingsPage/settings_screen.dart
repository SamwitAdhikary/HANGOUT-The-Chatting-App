import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hangout_test/Profile/profile.dart';
import 'package:hangout_test/constants/configs.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  var currentUser = FirebaseAuth.instance.currentUser.uid;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Configs.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.1,
                // color: Colors.red,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 25),
                  child: Text(
                    "Settings",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.73,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('id', isEqualTo: currentUser)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Something Went Wrong'),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasData) {
                      return CustomScrollView(
                        slivers: [
                          SliverList(
                            delegate: SliverChildListDelegate(
                              snapshot.data.docs
                                  .map((DocumentSnapshot document) {
                                Map<String, dynamic> data = document.data();
                                return Column(
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.13,
                                      width: MediaQuery.of(context).size.width,
                                      // color: Colors.red,
                                      child: InkWell(
                                        onTap: () {
                                          print("Pressed on");
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ProfileScreen(
                                                imgUrl: data['photoUrl'],
                                                name: data['nickname'],
                                                status: data['status'],
                                              ),
                                            ),
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Hero(
                                              tag: data['photoUrl'],
                                              child: CircleAvatar(
                                                radius: 40,
                                                backgroundImage:
                                                    CachedNetworkImageProvider(
                                                        data['photoUrl']),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  alignment:
                                                      Alignment.bottomLeft,
                                                  height: 50,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.6,
                                                  child: Text(
                                                    data['nickname'],
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  // color: Colors.blue,
                                                ),
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.6,
                                                  // padding:
                                                  //     EdgeInsets.only(top: 5),
                                                  height: 50,
                                                  child: Text(
                                                    data['status'],
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        TextStyle(fontSize: 15),
                                                  ),
                                                  // color: Colors.yellow,
                                                ),
                                              ],
                                            ),
                                            Icon(Icons.qr_code),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      child: Divider(),
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.key),
                                      title: Text("Account"),
                                      subtitle: Text(
                                          "Privacy, security, change number"),
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.chat),
                                      title: Text("Chats"),
                                      subtitle: Text(
                                          'Theme, wallpapers, chat history'),
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.help),
                                      title: Text("Help"),
                                      subtitle: Text(
                                          'Help center, contact us, privacy policy'),
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.group),
                                      title: Text("Invite a friend"),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      height: 50,
                                      // color: Colors.red,
                                      width: MediaQuery.of(context).size.width,
                                      child: Column(
                                        children: [
                                          Text('from'),
                                          Text(
                                            "Hangout",
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          )
                        ],
                      );
                    }

                    return Container();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
