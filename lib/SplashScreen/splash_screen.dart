// ignore_for_file: await_only_futures

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hangout_test/HomePage/homepage_screen.dart';
import 'package:hangout_test/UpdateName/update_name.dart';
import 'package:hangout_test/LoginScreen/login_screen.dart';
import 'package:hangout_test/constants/configs.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int splashDelay = 2;

  Future<User> getUser() async {
    return await FirebaseAuth.instance.currentUser;
  }

  @override
  void initState() {
    super.initState();
    _loadWidget();
  }

  _loadWidget() {
    var duration = Duration(seconds: splashDelay);
    return Timer(duration, checkLogin);
  }

  checkLogin() async {
    // getUser().then((_firebaseUser) {
    //   if (_firebaseUser != null) {
    //     Navigator.pushReplacement(
    //         context, MaterialPageRoute(builder: (context) => HomePage()));
    //   } else {
    //     Navigator.pushReplacement(
    //         context, MaterialPageRoute(builder: (context) => Login()));
    //   }
    // });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('phone');
    var name = prefs.getString('name');

    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: Builder(
          builder: (context) {
            if (token != null && name != null) {
              return HomePageScreen();
            } else if (token != null) {
              return UpdateName();
            } else {
              return LoginPage();
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Configs.black,
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Configs.black,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/hangout.png',
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
