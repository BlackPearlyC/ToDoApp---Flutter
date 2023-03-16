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
  final _formKey = GlobalKey<FormState>();
  String img = '';
  final searchController = TextEditingController();
  final todoAddController = TextEditingController();

// Function to get data from user
  void getData() async {
    final userId = _auth.currentUser;
    var userStore = await _fireStore.collection("user").doc(userId!.uid).get();
    setState(() {
      img = userStore.data()!['img'];
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  // Main Function
  @override
  Widget build(BuildContext context) {
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
          child: Stack(
            children: [
              // Seaarch Bar
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Container(
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
                ),
              ),
              // todo App logo
              // Todo Text
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 100),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "All ToDos",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                    )),
              ),

              // Builder
              Padding(
                padding: const EdgeInsets.only(top: 150),
                child: Expanded(child: _dataLoading()),
              ),
              // Align(
              //   alignment: Alignment.bottomLeft,
              //   child: Row(
              //     children: [
              //       Form(
              //           key: _formKey,
              //           child: Container(
              //               height: 35,
              //               color: Colors.white,
              //               child: TextFormField()))
              //     ],
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> _dataLoading() {
    return StreamBuilder<QuerySnapshot>(
        stream: _fireStore
            .collection('todoitem')
            .doc(_auth.currentUser!.uid)
            .collection('usertodo')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // Waiting for response
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          // print error if occured
          if (snapshot.hasError) {
            Fluttertoast.showToast(
                msg: "Some error occoured!, please reopen app",
                backgroundColor: Colors.deepPurple,
                textColor: Colors.white);
          }
          return Expanded(
            child: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final data = snapshot.data!.docs[index];
                  return Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white),
                      child: ListTile(
                        onTap: () {},
                        leading: Icon(
                          data['done']
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: Colors.blue,
                        ),
                        title: Text(
                          data['Todo'],
                          style: TextStyle(
                              fontSize: 16,
                              decoration: data['done']
                                  ? TextDecoration.lineThrough
                                  : null),
                        ),
                        trailing: Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.red),
                            child: IconButton(
                                onPressed: () {
                                  _fireStore
                                      .collection('todoitem')
                                      .doc(_auth.currentUser!.uid)
                                      .collection('usertodo')
                                      .doc(data['id'])
                                      .delete();
                                },
                                icon: const Icon(Icons.delete,
                                    color: Colors.white, size: 20))),
                      ),
                    ),
                  );
                }),
          );
        });
  }

// header of the app
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
  //
}
