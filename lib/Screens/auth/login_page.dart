import 'package:flutter/material.dart';
import 'package:we_chat/api/apis.dart';
import '../../main.dart';
import 'auth_services.dart';
import '../home_page.dart';
import '../../helper/dialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isAnimated = false;

  void handleGoogleSignIn() async {
    CustomDialog.showProgressBar(context);

    final userCredential = await AuthService.signInWithGoogle();

    CustomDialog.hideProgressBar(context);

    if (!mounted) return;

    if (userCredential != null) {
      if ((await APIs.userExists())) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        await APIs.createUsers().then((value) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        });
      }
    } else {
      CustomDialog.showSnackbar(
        context,
        "Google Sign-In failed. Please try again.",
        backgroundColor: const Color.fromARGB(255, 238, 24, 9),
        textColor: Colors.white,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isAnimated = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome to Login Page"),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
            top: mq.height * 0.05,
            right: _isAnimated ? mq.width * 0.25 : -mq.width * 0.5,
            width: mq.width * 0.5,
            duration: const Duration(milliseconds: 1000),
            child: Image.asset("assets/images/logo.png"),
          ),
          Positioned(
            bottom: mq.height * 0.15,
            left: mq.width * 0.1,
            width: mq.width * 0.8,
            height: mq.height * 0.06,
            child: ElevatedButton.icon(
              onPressed: handleGoogleSignIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3AAA35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 1,
              ),
              icon: Container(
                height: mq.height * 0.04,
                width: mq.height * 0.04,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Image.asset(
                    "assets/images/google.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              label: const Text(
                "  Log in with Google",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
