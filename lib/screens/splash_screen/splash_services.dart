import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todoapp/screens/auth/login.dart';

class SplashServices {
  final _auth = FirebaseAuth.instance;
  void logIn(BuildContext context) {
    if (_auth.currentUser != null) {
      Timer(
        const Duration(seconds: 3),
        () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const LogIn()));
        },
      );
    } else {
      Timer(
        const Duration(seconds: 3),
        () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const LogIn()));
        },
      );
    }
  }
}
