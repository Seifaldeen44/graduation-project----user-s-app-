import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:finalproj/components/logo.dart';
import 'package:finalproj/components/Button.dart';
import 'otp.dart'; // Import the OTP Verification Page

class PhoneAuthPage extends StatefulWidget {
  PhoneAuthPage({super.key});

  @override
  _PhoneAuthPageState createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  final TextEditingController phoneController = TextEditingController(text: "+20");
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;

  // Function to handle sending OTP to the phone number
  void _sendOTP() async {
    final phoneNumber = phoneController.text;

    // Validate the phone number format
    if (RegExp(r'^\+20[0-9]{10}$').hasMatch(phoneNumber)) {
      try {
        await _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            // Auto-complete on successful phone number verification
            await _auth.signInWithCredential(credential);
            Navigator.pushReplacementNamed(context, 'Home');
          },
          verificationFailed: (FirebaseAuthException e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Verification Failed: ${e.message}")));
          },
          codeSent: (String verificationId, int? resendToken) {
            setState(() {
              _verificationId = verificationId;
            });
            // Navigate to OTP verification page with the verificationId
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtpVerificationPage(verificationId: verificationId),
              ),
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            setState(() {
              _verificationId = verificationId;
            });
          },
        );
        print("OTP Sent to $phoneNumber");
      } catch (e) {
        print("Error sending OTP: $e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Invalid phone number format")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Phone Authentication"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomLogo(),
            SizedBox(height: 20),
            TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "Enter your phone number",
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
            SizedBox(height: 20),
            CustomButton(text: "Send Code", onPressed: _sendOTP, BtnWidth: 80),
          ],
        ),
      ),
    );
  }
}
