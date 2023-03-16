import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todoapp/widgets/button.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  // Formkey
  final _formKey = GlobalKey<FormState>();

  // Firebase
  final _auth = FirebaseAuth.instance;
  final _firestorage = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance.ref();

  // Extra Variable
  bool loading = false;
  bool edit = false;
  String img = '';
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  // File picker
  File? _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickFile != null) {
      _image = File(pickFile.path);
      return true;
    } else {
      Fluttertoast.showToast(
          msg: "No new image is picked",
          backgroundColor: Colors.deepPurple,
          textColor: Colors.white);
      return false;
    }
  }

  // Get data
  void getData() async {
    final userId = _auth.currentUser;
    var userData = await _firestorage.collection("user").doc(userId!.uid).get();
    setState(() {
      img = userData.data()!['img'];
      nameController.text = userData.data()!['name'];
      emailController.text = userData.data()!['email'];
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  // Main function
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey.shade200,
        elevation: 0,
        title: Align(
            alignment: Alignment.centerRight,
            child: IconButton(
                onPressed: () {
                  setState(() {
                    edit = true;
                  });
                },
                icon: const Icon(
                  Icons.edit,
                  color: Colors.black,
                ))),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Main text
                const Text(
                  "Profile",
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 100, 100, 100)),
                ),
                const SizedBox(
                  height: 50,
                ),
                // Imag ebox
                InkWell(
                  onTap: edit
                      ? () {
                          getImage();
                        }
                      : null,
                  child: Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        image: _image == null
                            ? DecorationImage(
                                image: NetworkImage(img), fit: BoxFit.cover)
                            : DecorationImage(
                                image: FileImage(_image!.absolute),
                                fit: BoxFit.cover)),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                // text from
                Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name box
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white),
                          child: TextFormField(
                            controller: nameController,
                            enabled: edit ? true : false,
                            decoration: const InputDecoration(
                                labelText: "Name",
                                border: InputBorder.none,
                                prefixIcon: Icon(Icons.abc)),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Provide a name";
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        // Emial box
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white),
                          child: TextFormField(
                            controller: emailController,
                            enabled: false,
                            decoration: const InputDecoration(
                                labelText: "Email",
                                border: InputBorder.none,
                                prefixIcon: Icon(Icons.email)),
                          ),
                        ),
                      ],
                    )),
                const SizedBox(
                  height: 20,
                ),
                if (edit)
                  Button(
                      label: "Save Changes",
                      loading: loading,
                      onTap: () async {
                        await _onUpdate();
                      })
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onUpdate() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        loading = true;
      });
      late String imgURL;
      // image upload
      if (_image != null) {
        final refImg = _storage.child('images').child(_auth.currentUser!.uid);
        await refImg.putFile(_image!);
        imgURL = await refImg.getDownloadURL();
      }

      await _firestorage.collection('user').doc(_auth.currentUser!.uid).update({
        'img': _image == null ? img : imgURL,
        'name': nameController.text.toString()
      }).then((value) {
        setState(() {
          loading = false;
          edit = false;
        });
        Fluttertoast.showToast(
            msg: "Updated Successfully",
            backgroundColor: Colors.blue.shade600,
            textColor: Colors.white);
      }).onError((error, stackTrace) {
        setState(() {
          loading = false;
        });
        Fluttertoast.showToast(
            msg: error.toString(),
            backgroundColor: Colors.blue.shade600,
            textColor: Colors.white);
      });
    }
  }
}
