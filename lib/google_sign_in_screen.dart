import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'sign_in.dart'; // Import your sign-up form screen

class GoogleSignInScreen extends StatefulWidget {
  @override
  _GoogleSignInScreenState createState() => _GoogleSignInScreenState();
}

class _GoogleSignInScreenState extends State<GoogleSignInScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Sign-In'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _signInWithGoogle,
          child: Text('Sign in with Google'),
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);

        // Navigate to sign-up form screen after successful sign-in
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => GoogleSignUp(googleUser: googleUser)),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _signOutFromGoogle() async {
    try {
      await _googleSignIn.signOut();
      // You can add additional sign-out logic here, such as signing out from Firebase Auth if necessary
    } catch (e) {
      print(e);
    }
  }
}
