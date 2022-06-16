// ignore_for_file: unused_local_variable

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hangout_test/AuthClass/auth_service.dart';
import 'package:hangout_test/constants/configs.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  int start = 30;
  String buttonName = "Send";
  bool wait = false;
  bool smsSend = false;

  TextEditingController phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  AuthClass authClass = AuthClass();

  String verificationIdFinal = '';
  String smsCode = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                  height: MediaQuery.of(context).size.height * 0.1,
                ),
                textField(),
                SizedBox(
                  height: 30,
                ),
                Container(
                  width: MediaQuery.of(context).size.width - 30,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Configs.black,
                          margin: EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                      Text(
                        "Enter 6 Digit OTP",
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Configs.black,
                          margin: EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                otpField(),
                SizedBox(
                  height: 40,
                ),
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: "Send OTP again in ",
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: "00:$start",
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.red,
                      ),
                    ),
                    TextSpan(
                        text: " sec",
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.black,
                        )),
                  ]),
                ),
                SizedBox(
                  height: 50,
                ),
                GestureDetector(
                  onTap: smsSend == false
                      ? () {
                          showModal();
                        }
                      : () {
                          authClass.signInWithPhoneNumber(
                              verificationIdFinal, smsCode, context);
                        },
                  child: Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      color: smsSend == false ? Colors.grey : Configs.black,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Let's Continue",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          Icons.arrow_forward,
                          size: 20,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
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
          "Please verify your number to continue.",
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

  void startTimer() {
    const onsec = Duration(seconds: 1);
    Timer _timer = Timer.periodic(onsec, (timer) {
      if (start == 0) {
        setState(() {
          timer.cancel();
          wait = false;
        });
      } else {
        setState(() {
          if (!mounted) return;
          start--;
        });
      }
    });
  }

  Widget otpField() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      child: PinCodeTextField(
        length: 6,
        appContext: context,
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(5),
          activeColor: Colors.grey[300],
          activeFillColor: Colors.white,
          inactiveFillColor: Colors.grey[300],
          inactiveColor: Colors.grey[300],
        ),
        enableActiveFill: true,
        useHapticFeedback: true,
        hapticFeedbackTypes: HapticFeedbackTypes.medium,
        animationType: AnimationType.none,
        keyboardType: TextInputType.number,
        onChanged: (value) {
          print(value);
        },
        onCompleted: (value) {
          setState(() {
            smsCode = value;
          });
        },
      ),
    );
  }

  Widget textField() {
    return Form(
      key: _formKey,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        child: TextFormField(
          keyboardType: TextInputType.number,
          controller: phoneController,
          validator: (value) {
            if (value.isEmpty) {
              return "Field cannot be empty";
            }
            return null;
          },
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            fillColor: Configs.black,
            filled: true,
            hintText: "Enter your phone number",
            hintStyle: const TextStyle(
              color: Colors.white54,
              fontSize: 17,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 19),
            prefixIcon: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 15),
              child: Text(
                "(+91)",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                ),
              ),
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
              child: wait
                  ? Container(
                      child: Text(
                        buttonName,
                        style: TextStyle(
                          color: wait ? Colors.grey : Colors.white,
                          fontSize: 17,
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: wait
                          ? null
                          : () async {
                              if (_formKey.currentState.validate()) {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                print('Pressed on send');
                                setState(() {
                                  start = 30;
                                  wait = true;
                                  buttonName = 'Resend';
                                });
                                await authClass.verifyPhoneNumber(
                                    "+91 ${phoneController.text}",
                                    context,
                                    setData);

                                prefs.setString("phone", phoneController.text);
                              }
                            },
                      child: Text(
                        buttonName,
                        style: TextStyle(
                          color: wait ? Colors.grey : Colors.white,
                          fontSize: 17,
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  void setData(verificationId) {
    setState(() {
      verificationIdFinal = verificationId;
      smsSend = true;
    });
    startTimer();
  }
}

class MyCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Configs.black,
      child: Container(
        padding: EdgeInsets.only(left: 25),
        alignment: Alignment.centerLeft,
        // color: Colors.red,
        child: Text(
          "SignUp",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Size get preferredSize => Size.fromHeight(80);
}
