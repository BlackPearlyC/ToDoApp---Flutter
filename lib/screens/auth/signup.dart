import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todoapp/screens/auth/login.dart';
import 'package:todoapp/screens/todo_screen/todo_app.dart';
// import 'package:todoapp/screens/todo_screen/todo_app.dart';
import 'package:todoapp/widgets/button.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  // firebase
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance.ref();
  final _firestore = FirebaseFirestore.instance.collection("user");

  // form key
  final _formKey = GlobalKey<FormState>();

  // Email Function
  final emailControllers = TextEditingController();
  final passwordControllers = TextEditingController();
  final fullNameController = TextEditingController();

  // Image Picker
  File? _image;
  final picker = ImagePicker();

  // extra varibale
  bool loading = false;

  // Image Picker function
  Future getGalaryImage() async {
    final pickFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    setState(() {
      if (pickFile != null) {
        _image = File(pickFile.path);
      } else {
        Fluttertoast.showToast(
            msg: "No image is picked",
            backgroundColor: Colors.deepPurple,
            textColor: Colors.white);
      }
    });
  }

  // Main Function
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Sign up text
                const Text(
                  "Sign up",
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 100, 100, 100)),
                ),
                const SizedBox(
                  height: 50,
                ),
                // Image Picker
                InkWell(
                  onTap: () {
                    getGalaryImage();
                  },
                  // Image picker
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                        image: _image != null
                            ? DecorationImage(
                                image: FileImage(
                                  _image!.absolute,
                                ),
                                fit: BoxFit.cover)
                            : null),
                    child: _image != null
                        ? null
                        : const Icon(Icons.person, size: 30),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                // Login Form
                Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Name input
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            controller: fullNameController,
                            decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.abc),
                                hintText: "e.g. Black Pearl",
                                labelText: "Full Name",
                                // prefixIconConstraints: BoxConstraints(),
                                border: InputBorder.none),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Name cannot be empty";
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        // Email Container
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            controller: emailControllers,
                            decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.email),
                                hintText: "abc@gmail.com",
                                labelText: "Email",
                                // prefixIconConstraints: BoxConstraints(),
                                border: InputBorder.none),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Email cannot be empty";
                              } else if (!value.contains("@")) {
                                return "Provide valid email";
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        // Password input
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white),
                          child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            controller: passwordControllers,
                            obscureText: true,
                            decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.password),
                                labelText: "Password",
                                border: InputBorder.none),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Password cannot be empty";
                              } else if (value.length < 6) {
                                return "Password length must be atleast 6";
                              } else {
                                return null;
                              }
                            },
                          ),
                        )
                      ],
                    )),
                const SizedBox(
                  height: 20,
                ),
                Button(
                    label: "Sign up",
                    loading: loading,
                    onTap: () async {
                      await _onClickButton(context);
                    }),
                // Alreaady have an account
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LogIn()));
                        },
                        child: const Text("Login"))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onClickButton(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        loading = true;
      });
      await _auth
          .createUserWithEmailAndPassword(
              email: emailControllers.text.toString(),
              password: passwordControllers.text.toString())
          .then((value) async {
        // image url
        late String imgURL;
        // image upload
        if (_image != null) {
          final refImg = _storage.child('images').child(value.user!.uid);
          await refImg.putFile(_image!);
          imgURL = await refImg.getDownloadURL();
        }

        // sendin to daat base
        // ignore: use_build_context_synchronously
        await _uploadToFirestore(value, imgURL, context);
      }).onError((error, stackTrace) {
        setState(() {
          loading = false;
        });
        Fluttertoast.showToast(
            msg: error.toString(),
            textColor: Colors.white,
            backgroundColor: Colors.blue.shade600);
      });
    }
  }

  Future<void> _uploadToFirestore(
      UserCredential value, String imgURL, BuildContext context) async {
    await _firestore.doc(value.user!.uid).set({
      "id": value.user!.uid,
      "name": fullNameController.text.toString(),
      "email": emailControllers.text.toString(),
      "img": imgURL.isEmpty ? null : imgURL
    }).then((value) {
      setState(() {
        loading = false;
      });
      Fluttertoast.showToast(
          msg: "Account created successfully",
          textColor: Colors.white,
          backgroundColor: Colors.blue.shade600);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const ToDoApp()));
    }).onError((error, stackTrace) {
      setState(() {
        loading = false;
      });
      Fluttertoast.showToast(
          msg: error.toString(),
          textColor: Colors.white,
          backgroundColor: Colors.blue.shade600);
    });
  }
}
