// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hangout_test/constants/configs.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  String chatUserId;
  String userId;
  String customId;
  String photoUrl;

  ChatScreen({
    @required this.chatUserId,
    @required this.userId,
    @required this.customId,
    @required this.photoUrl,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState(
        chatUserId: chatUserId,
        userId: userId,
        customId: customId,
        photoUrl: photoUrl,
      );
}

class _ChatScreenState extends State<ChatScreen> {
  String chatUserId;
  String userId;
  String customId;
  String photoUrl;

  _ChatScreenState({
    @required this.chatUserId,
    @required this.userId,
    @required this.customId,
    @required this.photoUrl,
  });

  TextEditingController textEditingController = new TextEditingController();
  int count1 = 0, count2 = 0;

  bool showEmojiPicker = false;

  String username2;
  String groupId;

  String currentUserPhoto;

  String userActiveStatus;
  String deviceToken;

  FocusNode textFieldFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    readLocal();
    count1 = 0;
    count2 = 0;
    username2 = FirebaseAuth.instance.currentUser.displayName;

    getUserPhoto();

    getUserDetails();
  }

  showKeyboard() => textFieldFocus.requestFocus();
  hideKeyboard() => textFieldFocus.unfocus();

  hideEmojiContainer() {
    setState(() {
      showEmojiPicker = false;
    });
  }

  showEmojiContainer() {
    setState(() {
      showEmojiPicker = true;
    });
  }

  emojiContainer() {
    return SizedBox(
      height: 260,
      child: EmojiPicker(
        config: Config(
          columns: 7,
        ),
        onEmojiSelected: (category, emoji) {
          textEditingController.text = textEditingController.text + emoji.emoji;
        },
      ),
    );
  }

  void getUserPhoto() async {
    var collection = FirebaseFirestore.instance.collection('users');

    var docSnapshot =
        await collection.doc(FirebaseAuth.instance.currentUser.uid).get();

    Map<String, dynamic> data = docSnapshot.data();

    currentUserPhoto = data['photoUrl'];
    print(currentUserPhoto);
  }

  void getUserDetails() async {
    var collection = FirebaseFirestore.instance.collection('users');

    var docSnapshot = await collection.doc(customId).get();

    Map<String, dynamic> data = docSnapshot.data();

    setState(() {
      userActiveStatus = data['active'];
      deviceToken = data['deviceToken'];
    });
    print(userActiveStatus);
  }

  readLocal() {
    if (userId.hashCode <= customId.hashCode) {
      groupId = '$userId-$customId';
    } else {
      groupId = '$customId-$userId';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Configs.black,
        appBar: MyCustomAppBar(
          imgUrl: photoUrl,
          name: chatUserId,
          customId: customId,
        ),
        body: Container(
          alignment: Alignment.bottomCenter,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              buildListMessage(),
              typeMessage(),
              showEmojiPicker
                  ? Container(
                      margin: EdgeInsets.only(top: 10),
                      child: emojiContainer(),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildListMessage() {
    return Expanded(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('messages')
            .doc(groupId)
            .collection(groupId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              reverse: true,
              padding: EdgeInsets.all(10),
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                return buildMessages(index, snapshot.data.docs[index]);
              },
            );
          }
        },
      ),
    );
  }

  void sendNotification(String message) async {
    var headersList = {
      'Accept': '*/*',
      'User-Agent': 'Thunder Client (https://www.thunderclient.com)',
      'Authorization':
          'key=AAAASL6sJh0:APA91bFJ7ncef4lGIjwpwGMLLmgAU-KEa0pnRjz5cZhF03WjYVj0HePGTk673Qww1o6eE9WAHlUnibf7w8N-5yxkFfzkGXtFO6m_QwCZbBZ5E3KWnCVtUf8aJvQRdkXcDIe-SXS-Vd8A',
      'Content-Type': 'application/json'
    };
    var url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    var body = {
      "to": deviceToken,
      "notification": {
        "title": username2,
        "body": message,
        "android_channel_id": "hangout",
        "sound": true
      }
    };
    var req = http.Request('POST', url);
    req.headers.addAll(headersList);
    req.body = json.encode(body);

    var res = await req.send();
    final resBody = await res.stream.bytesToString();

    if (res.statusCode >= 200 && res.statusCode < 300) {
      print(resBody);
    } else {
      print(res.reasonPhrase);
    }
  }

  buildMessages(int index, DocumentSnapshot document) {
    if (document['idFrom'] == userId) {
      return Padding(
        padding: EdgeInsets.only(bottom: 5, top: 5),
        child: Column(
          children: [
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    child: Text(
                      document['message'],
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                    padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                    decoration: BoxDecoration(
                      color: Colors.lightGreen[200],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        bottomLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                        topRight: Radius.circular(0),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  DateFormat.jm().format(
                    DateTime.fromMillisecondsSinceEpoch(
                      document['timestamp'],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.only(bottom: 5, top: 5),
        child: Column(
          children: [
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    child: Text(
                      document['message'],
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                    padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(0),
                        bottomLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  // DateTime.fromMillisecondsSinceEpoch(document['timestamp'])
                  //         .toString()
                  //         .split(" ")[1]
                  //         .toString()
                  //         .split(":")[0] +
                  //     ":" +
                  //     DateTime.fromMillisecondsSinceEpoch(document['timestamp'])
                  //         .toString()
                  //         .split(" ")[1]
                  //         .toString()
                  //         .split(":")[1],
                  DateFormat.jm().format(
                    DateTime.fromMillisecondsSinceEpoch(
                      document['timestamp'],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  Widget typeMessage() {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 10,
          ),
          CircleAvatar(
            child: Icon(Icons.add),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: TextField(
                    focusNode: textFieldFocus,
                    onTap: () {
                      hideEmojiContainer();
                    },
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      alignLabelWithHint: true,
                      fillColor: Colors.grey[300],
                      filled: true,
                      suffixIcon: Icon(Icons.emoji_emotions_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    controller: textEditingController,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 5,
                    minLines: 1,
                  ),
                ),
                IconButton(
                  splashRadius: 3,
                  onPressed: () {
                    if (!showEmojiPicker) {
                      hideKeyboard();
                      showEmojiContainer();
                    } else {
                      showKeyboard();
                      hideEmojiContainer();
                    }
                  },
                  icon: Icon(Icons.emoji_emotions_outlined),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: () {
              sendMsg(textEditingController.text);
              // sendNotification(textEditingController.text);
              print('pressed');
            },
            child: CircleAvatar(
              radius: 20,
              child: Icon(
                Icons.send,
                size: 18,
              ),
            ),
          ),
          SizedBox(
            width: 10,
          )
        ],
      ),
    );
  }

  void sendMsg(String message) {
    if (message.trim() != '') {
      textEditingController.clear();
      FirebaseFirestore.instance
          .collection('messages')
          .doc(groupId)
          .collection(groupId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString())
          .set({
        'idFrom': userId,
        'idTo': customId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'message': message,
      });
      FirebaseFirestore.instance.collection('messages').doc(groupId).set({
        'nickname1': chatUserId,
        'photoUrl1': photoUrl,
        'id1': customId,
        'id2': userId,
        'lastmessage': message,
        'time': DateTime.now().millisecondsSinceEpoch.toString(),
        'photoUrl2': currentUserPhoto,
        'nickname2': username2,
      });

      sendNotification(message);
    }
  }
}

class MyCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String imgUrl;
  final String name;
  final customId;

  MyCustomAppBar({
    @required this.imgUrl,
    @required this.name,
    @required this.customId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(customId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("Something Went Wrong"),
          );
        }

        if (snapshot.hasData) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                // color: Colors.red,
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: EdgeInsets.all(8),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey[850],
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Hero(
                      tag: imgUrl,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundImage: CachedNetworkImageProvider(imgUrl),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        snapshot.data['active'] == "Online"
                            ? Text(
                                snapshot.data['active'],
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                "Last Seen " +
                                    DateFormat.jm().format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          snapshot.data['lastSeen']),
                                    ),
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                      ],
                    ),
                    Spacer(),
                    Icon(
                      Icons.more_vert,
                      color: Colors.grey,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.05,
                    )
                  ],
                ),
              ),
            ],
          );
        }

        return Container();
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(80);
}
