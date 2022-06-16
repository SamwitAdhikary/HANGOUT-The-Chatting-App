import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hangout_test/ChatScreen/chat_screen.dart';
import 'package:hangout_test/constants/configs.dart';
import 'package:hangout_test/image_dialog.dart';

class ContactScreen extends StatefulWidget {
  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  String userid;

  @override
  void initState() {
    super.initState();
    userid = FirebaseAuth.instance.currentUser.uid;
    print(FirebaseAuth.instance.currentUser.photoURL);
  }

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
                  padding: EdgeInsets.only(left: 25),
                  alignment: Alignment.centerLeft,
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    "Contacts",
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
                        .orderBy('nickname', descending: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Something Went Wrong.'),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasData) {
                        return ListView.builder(
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            itemCount: snapshot.data.docs.length,
                            itemBuilder: (context, index) {
                              return buildItem(
                                  context, snapshot.data.docs[index]);
                            });
                      } else {
                        return Container();
                      }
                    },
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    String id = document['id'].toString();
    String name = document['nickname'].toString();
    String status = document['status'].toString();
    FirebaseAuth.instance.currentUser.updatePhotoURL(document['photoUrl']);
    print("UserId is: $userid");
    print("Document id: $id");
    if (userid != id) {
      return Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    chatUserId: name,
                    userId: userid,
                    customId: id,
                    photoUrl: document['photoUrl'],
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: ListTile(
                title: Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                subtitle: Text(
                  status,
                ),
                leading: Hero(
                  tag: document['photoUrl'],
                  child: Material(
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => ImageDialog(
                            imgUrl: document['photoUrl'],
                          ),
                        );
                      },
                      child: CachedNetworkImage(
                        placeholder: (context, url) => Container(
                          child: CircularProgressIndicator(),
                          width: 50,
                          height: 50,
                          padding: EdgeInsets.all(15),
                        ),
                        imageUrl: document['photoUrl'],
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
