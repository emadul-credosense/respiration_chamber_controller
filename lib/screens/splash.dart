import 'dart:async';
import 'package:flutter/material.dart';
import 'devicePage.dart';

class SplashScreen extends StatelessWidget {
  static const String id = 'splash';
  @override
  Widget build(BuildContext context) {
    return MyHomepage();
  }
}

class MyHomepage extends StatefulWidget {
  @override
  _MyHomepageState createState() => _MyHomepageState();
}

class _MyHomepageState extends State<MyHomepage> {
  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FlutterBlueApp()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              "img/credologo.png",
              height: 80.0,
              width: 80.0,
            ),
          ),
          Text(
            'CredoSense',
            style: TextStyle(
              fontSize: 35.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(left: 110.0),
              child: Text(
                "Sensing Dream",
                style: TextStyle(fontSize: 12.0),
              )),
        ],
      ),
    );
  }
}
