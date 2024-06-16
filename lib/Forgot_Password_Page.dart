import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _uidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isUidVerified = false;

  void _verifyUid() async {
    try {
      final uid = _uidController.text.trim();
      final email = _emailController.text.trim();

      // Check if the user exists in the Firestore /users collection with the given UID
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .where('uid', isEqualTo: uid)
          .get();

      if (userDoc.docs.isNotEmpty) {
        setState(() {
          _isUidVerified = true;
        });
      } else {
        _showError('UID does not match for the given email.');
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _updatePassword() async {
    if (_passwordController.text == _confirmPasswordController.text) {
      try {
        // Get the user
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.updatePassword(_passwordController.text);
          _showSuccess('Password updated successfully.');
        } else {
          _showError('No user is signed in.');
        }
      } catch (e) {
        _showError(e.toString());
      }
    } else {
      _showError('Passwords do not match');
    }
  }

  void _showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Forgot Password', style: TextStyle(fontSize: 25)),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _uidController,
              decoration: InputDecoration(
                labelText: 'UID',
              ),
            ),
            SizedBox(height: 20),
            if (_isUidVerified)
              Column(
                children: [
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                    ),
                    obscureText: true,
                  ),
                  TextField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _updatePassword,
                    child: Text('Change Password'),
                  ),
                ],
              ),
            SizedBox(height: 20),
            if (!_isUidVerified)
              ElevatedButton(
                onPressed: _verifyUid,
                child: Text('Verify UID'),
              ),
          ],
        ),
      ),
    );
  }
}
