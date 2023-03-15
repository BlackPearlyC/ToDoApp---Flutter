import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todoapp/widgets/button.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  // Firebase
  final _auth = FirebaseAuth.instance;
  // Form key
  // ignore: unused_field
  final _formKey = GlobalKey<FormState>();
  // Controllers
  final emailControllers = TextEditingController();
  final passwordController = TextEditingController();
  // Extra veriable
  bool loading = false;
  // main program
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      // Body
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Login text
            const Text(
              "Login",
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 100, 100, 100)),
            ),
            const SizedBox(
              height: 50,
            ),
            // Login Form
            Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email input
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
                            hintText: "Email",
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
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.password),
                            hintText: "Password",
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
            // ignore: prefer_const_constructors
            SizedBox(
              height: 20,
            ),
            // Button
            Button(
                label: "Login",
                loading: loading,
                onTap: () async {
                  await _onLoginTap();
                })
            // Create account tab
          ],
        ),
      ),
    );
  }

  // Login Setup code
  Future<void> _onLoginTap() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        loading = true;
      });
      await _auth
          .signInWithEmailAndPassword(
              email: emailControllers.text.toString(),
              password: passwordController.text.toString())
          .then((value) {
        setState(() {
          loading = false;
        });
        Fluttertoast.showToast(
            msg: "Logged in Successfully",
            textColor: Colors.white,
            backgroundColor: Colors.blue.shade600);
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
}
