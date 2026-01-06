import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'Screens/auth/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

late Size mq; 

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "We Chat",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor:Color(0xFF3AAA35),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFF3AAA35),
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.white, size: 30),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}
