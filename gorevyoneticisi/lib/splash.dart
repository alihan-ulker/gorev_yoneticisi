import 'package:flutter/material.dart';
import 'package:gorevyoneticisi/screens/home_page.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    //Splash screen duration time
    Future.delayed(const Duration(seconds: 3), () {
      //Go to homepage after 3 seconds
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const HomePage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
          //splash screen image
          image: AssetImage("assets/splash.png"),
          fit: BoxFit.fitWidth,
        )),
      ),
      backgroundColor: Colors.black,
    );
  }
}
