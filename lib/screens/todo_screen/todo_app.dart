import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todoapp/screens/auth/login.dart';
import 'package:todoapp/screens/profile/profile.dart';

class ToDoApp extends StatefulWidget {
  const ToDoApp({super.key});

  @override
  State<ToDoApp> createState() => _ToDoAppState();
}

class _ToDoAppState extends State<ToDoApp> {
  // Firebase
  final _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;

  // Variable of backend
  String img = '';
  final searchController = TextEditingController();

// Function to get data from user
  void getData() async {
    final userId = _auth.currentUser;
    var userStore = await _fireStore.collection("user").doc(userId!.uid).get();
    setState(() {
      img = userStore.data()!['img'];
    });
  }

  // Main Function
  @override
  Widget build(BuildContext context) {
    setState(() {
      getData();
    });
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        // Navigation bar
        appBar: _headerWithImageandLogout(context),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                // ignore: prefer_const_constructors
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      labelText: "Search"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  AppBar _headerWithImageandLogout(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.grey.shade200,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Profile Picture with on click
          InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UserProfile()));
              },
              child: Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(45),
                    border: Border.all(width: 1),
                    image: DecorationImage(
                        image: NetworkImage(img), fit: BoxFit.cover)),
              )),
          // Logout Button
          IconButton(
              onPressed: () async {
                await _auth.signOut().then((value) {
                  Fluttertoast.showToast(
                      msg: "Logout Successfully",
                      backgroundColor: Colors.blue.shade600,
                      textColor: Colors.white);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const LogIn()));
                }).onError((error, stackTrace) {
                  Fluttertoast.showToast(
                      msg: error.toString(),
                      backgroundColor: Colors.blue.shade600,
                      textColor: Colors.white);
                });
              },
              icon: const Icon(
                Icons.logout,
                color: Color.fromARGB(255, 56, 56, 56),
                size: 24,
              )),
        ],
      ),
    );
  }
}
