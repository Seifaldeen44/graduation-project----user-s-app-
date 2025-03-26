import 'package:flutter/material.dart';

class GetStartedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.transparent,
              child: Image.asset("images/download.jpg"),
            ),
            SizedBox(height: 20),
            Text(
              'Get Started with Tramify!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 5,
              ),
            ),
            Text(
              "Let's Get You Started!",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 5,
              ),
            ),
            Text(
              "Track trams and plan your journey",
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 35),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 145, 129, 216),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 65, vertical: 20),
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, 'Phoneauth');
              },
              child: Text(
                'GET STARTED',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, 'Phoneauth');
              },
              child: Text(
                'already have an account? Login',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
