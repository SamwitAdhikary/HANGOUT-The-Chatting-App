import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hangout_test/ChatScreen/chat_screen.dart';
import 'package:hangout_test/constants/configs.dart';
import 'package:hangout_test/image_dialog.dart';

class ChatListScreen extends StatefulWidget {
  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  String uid;
  String name;
  String image;

  DocumentSnapshot snapshot;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser.uid;
    name = FirebaseAuth.instance.currentUser.displayName;
    image = FirebaseAuth.instance.currentUser.photoURL;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Configs.black,
        appBar: MyAppBar(
          id: uid,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.72,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 5,
                    width: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(
                        50,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20),
                    width: MediaQuery.of(context).size.width,
                    // color: Colors.red,
                    child: Text(
                      "Recent Chat",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    // physics: BouncingScrollPhysics(),
                    child: Container(
                      // color: Colors.yellow,
                      height: MediaQuery.of(context).size.height * 0.65,
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('messages')
                            .orderBy('time', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Something Went wrong'),
                            );
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasData) {
                            return ListView.builder(
                              // physics: BouncingScrollPhysics(),
                              padding: EdgeInsets.only(top: 10),
                              itemCount: snapshot.data.docs.length,
                              itemBuilder: (context, index) {
                                return buildItem(
                                    context, snapshot.data.docs[index]);
                              },
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItem(BuildContext context, document) {
    if (uid == document['id1']) {
      return Column(
        children: [
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    chatUserId: document['nickname2'],
                    userId: document['id1'],
                    customId: document['id2'],
                    photoUrl: document['photoUrl2'],
                  ),
                ),
              );
            },
            title: Text(
              document['nickname2'],
            ),
            subtitle: Text(
              document['lastmessage'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            leading: Hero(
              tag: document['photoUrl2'],
              child: Material(
                child: InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (_) => ImageDialog(
                              imgUrl: document['photoUrl2'],
                            ));
                  },
                  child: CachedNetworkImage(
                    placeholder: (context, url) => Container(
                      child: CircularProgressIndicator(),
                      width: 50,
                      height: 50,
                      padding: EdgeInsets.all(15),
                    ),
                    imageUrl: document['photoUrl2'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                borderRadius: BorderRadius.all(Radius.circular(25)),
                clipBehavior: Clip.antiAliasWithSaveLayer,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Divider(
              height: 1,
            ),
          )
        ],
      );
    } else if (uid == document['id2']) {
      return Column(
        children: [
          ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatScreen(
                            chatUserId: document['nickname1'],
                            userId: document['id2'],
                            customId: document['id1'],
                            photoUrl: document['photoUrl1'],
                          )));
            },
            title: Text(
              document['nickname1'],
            ),
            subtitle: Text(
              document['lastmessage'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              // "",
            ),
            leading: Hero(
              tag: document['photoUrl1'],
              child: Material(
                borderRadius: BorderRadius.all(Radius.circular(25)),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (_) => ImageDialog(
                              imgUrl: document['photoUrl1'],
                            ));
                  },
                  child: CachedNetworkImage(
                    placeholder: (context, url) => Container(
                      child: CircularProgressIndicator(),
                      width: 50,
                      height: 50,
                      padding: EdgeInsets.all(15),
                    ),
                    imageUrl: document['photoUrl1'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Divider(
              height: 1,
            ),
          )
        ],
      );
    } else {
      return Container();
    }
  }
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final id;

  MyAppBar({
    @required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: id)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Something Went Wrong'),
          );
        }

        if (snapshot.hasData) {
          return CustomScrollView(
            physics: NeverScrollableScrollPhysics(),
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate(
                  snapshot.data.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data();
                    return Container(
                      // height: MediaQuery.of(context).size.height,
                      // width: MediaQuery.of(context).size.width,
                      color: Configs.black,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //! Welcome message and notification icon
                          Container(
                            // alignment: Alignment.center,
                            // color: Colors.red,
                            child: Row(
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      // color: Colors.red,
                                      margin:
                                          EdgeInsets.only(left: 20, top: 10),
                                      child: Text(
                                        "Welcome ${data['nickname'].split(" ")[0]}✌️",
                                        // data['nickname'],
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 17),
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      margin: EdgeInsets.only(left: 20, top: 0),
                                      // color: Colors.red,
                                      child: Text(
                                        "HangOut",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Spacer(),
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  child: Material(
                                    child: InkWell(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => ImageDialog(
                                            imgUrl: data['photoUrl'],
                                          ),
                                        );
                                      },
                                      child: CachedNetworkImage(
                                        placeholder: (context, url) =>
                                            Container(
                                          color: Configs.black,
                                          child: CircularProgressIndicator(),
                                          width: 50,
                                          height: 50,
                                          padding: EdgeInsets.all(15),
                                        ),
                                        imageUrl: data['photoUrl'],
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(25)),
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.05,
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              )
            ],
          );
        }

        return Container();
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(90);
}
