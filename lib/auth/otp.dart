import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:finalproj/components/logo.dart';
import 'package:finalproj/components/Button.dart';

class OtpVerificationPage extends StatefulWidget {
  final String verificationId;

  OtpVerificationPage({required this.verificationId, super.key});

  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  List<TextEditingController> otpControllers =
  List.generate(6, (index) => TextEditingController());
  FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to handle OTP verification
  void _verifyOtp() async {
    String otp = otpControllers.map((controller) => controller.text).join();

    // Check if OTP length is 6
    if (otp.length == 6) {
      try {
        // Use the verificationId from the PhoneAuthPage and verify the OTP
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
            verificationId: widget.verificationId, smsCode: otp);

        await _auth.signInWithCredential(credential);

        // Navigate to the HomePage after successful OTP verification
        Navigator.pushReplacementNamed(context, 'Home');
      } catch (e) {
        // Handle error in OTP verification
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Invalid OTP!")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter a valid OTP")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("OTP Verification"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomLogo(),
            SizedBox(height: 20),
            Text("Enter the OTP sent to your phone number", style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 40,
                  child: TextField(
                    controller: otpControllers[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    decoration: InputDecoration(
                      counterText: "",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                  ),
                );
              }),
            ),
            SizedBox(height: 20),
            CustomButton(text: "Verify OTP", onPressed: _verifyOtp, BtnWidth: 80),
          ],
        ),
      ),
    );
  }
}
