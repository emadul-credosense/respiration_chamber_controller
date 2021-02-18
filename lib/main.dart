import 'package:flutter/material.dart';
import 'package:respiration_chamber_controller/screens/splash.dart';

void main() {
  runApp(BluetoothControllerHomepage());
}

class BluetoothControllerHomepage extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
    );
  }
}
