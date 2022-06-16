import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hangout_test/ChatListScreen/chat_list_screen.dart';
import 'package:hangout_test/ContactScreen/contact_screen.dart';
import 'package:hangout_test/NotificationService/local_notification_service.dart';
import 'package:hangout_test/SettingsPage/settings_screen.dart';
import 'package:hangout_test/constants/configs.dart';

class HomePageScreen extends StatefulWidget {
  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen>
    with WidgetsBindingObserver {
  int _selectedIndex = 0;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setStatus("Online");

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      print("FirebaseMessaging.instance.getInitialMessage");
      if (message != null) {
        print("New Notification");
      }
    });

    FirebaseMessaging.onMessage.listen((message) {
      print("FirebaseMessaging.onMessage.listen");
      if (message.notification != null) {
        print(message.notification.title);
        print(message.notification.body);
        LocalNotificationService.createanddisplaynotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("FirebaseMessaging.onMessageOpenedApp.listen");
      if (message.notification != null) {
        print(message.notification.title);
        print(message.notification.body);
      }
    });
  }

  void setStatus(String status) async {
    await _firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .update({
      "active": status,
      "lastSeen": DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      //online
      setStatus("Offline");
    } else {
      //offline
      setStatus("Online");
    }
  }

  static final List<Widget> _widgetOptions = <Widget>[
    ChatListScreen(),
    ContactScreen(),
    SettingsScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(8),
          color: Colors.white,
          child: Container(
            decoration: BoxDecoration(
                color: Configs.black, borderRadius: BorderRadius.circular(50)),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: GNav(
                  rippleColor: Colors.grey[300],
                  hoverColor: Colors.grey[800],
                  gap: 8,
                  activeColor: Configs.black,
                  iconSize: 24,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  duration: Duration(milliseconds: 400),
                  tabBackgroundColor: Colors.white,
                  color: Colors.grey,
                  tabs: [
                    GButton(
                      icon: Icons.chat,
                      text: "Chats",
                    ),
                    GButton(
                      icon: Icons.group,
                      text: "Contacts",
                    ),
                    GButton(
                      icon: Icons.settings,
                      text: "Settings",
                    ),
                  ],
                  selectedIndex: _selectedIndex,
                  onTabChange: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
