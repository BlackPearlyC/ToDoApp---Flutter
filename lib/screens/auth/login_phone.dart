// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:todoapp/widgets/button.dart';

class LogInPhone extends StatefulWidget {
  const LogInPhone({super.key});

  @override
  State<LogInPhone> createState() => _LogInPhoneState();
}

class _LogInPhoneState extends State<LogInPhone> {
  // firebase
  // final _auth = FirebaseAuth.instance;
  // Form key
  final _formKey = GlobalKey<FormState>();
  // Controllers
  final phoneController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Login with phone number text
            const Text(
              "Login with phone no.",
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 100, 100, 100)),
            ),
            // ignore: prefer_const_constructors
            SizedBox(
              height: 50,
            ),
            // Mobile number text Field
            Form(
                key: _formKey,
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.phone),
                          hintText: "Phone no.",
                          helperText: "hint: +91 123 4567 4567"),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please provide phone no.";
                        } else if (value.contains("+")) {
                          return "Provide valid phone no.";
                        } else {
                          return null;
                        }
                      },
                    ))),
            const SizedBox(
              height: 20,
            ),
            // Button for login
            Button(
                label: "Login",
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    // _auth.verifyPhoneNumber(
                    //     phoneNumber: phoneController.text.toString(),
                    //     verificationCompleted: (_) {},
                    //     verificationFailed: (error) {
                    //       Fluttertoast.showToast(
                    //           msg: error.toString(),
                    //           textColor: Colors.white,
                    //           backgroundColor: Colors.blue.shade600);
                    //     },
                    //     codeSent: ,
                    //     codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
                  }
                }),
          ],
        ),
      ),
    );
  }
}
