import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todoapp/screens/auth/login.dart';
import 'package:todoapp/screens/auth/signup.dart';
import 'package:todoapp/widgets/button.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  // firebase
  final _auth = FirebaseAuth.instance;
  // form key
  final _formKey = GlobalKey<FormState>();
  // controller
  final emailController = TextEditingController();
  // Extra varibale
  bool loading = false;
  // Main Function
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Text rest your password
            const Text(
              "Reset your password",
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 100, 100, 100)),
            ),
            const SizedBox(
              height: 50,
            ),
            // email input field
            Form(
              key: _formKey,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
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
            ),
            const SizedBox(
              height: 20,
            ),
            // Button for forgot
            Button(
                label: "Get link",
                loading: loading,
                onTap: () async {
                  await _forgotPasswordClick(context);
                }),
            //
            Row(
              children: [
                const Text("Don't have an account"),
                TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignUp()));
                    },
                    child: const Text("Sign up"))
              ],
            ),
          ],
        ),
      ),
    );
  }

// Click on forgot password
  Future<void> _forgotPasswordClick(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        loading = true;
      });
      await _auth
          .sendPasswordResetEmail(email: emailController.text.toString())
          .then((value) {
        setState(() {
          loading = false;
        });
        Fluttertoast.showToast(
            msg: "Email is send to your main, please check your mail",
            textColor: Colors.white,
            backgroundColor: Colors.blue.shade600);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const LogIn()));
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
