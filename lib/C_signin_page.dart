import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore package
import 'signup_page.dart';
import 'forgot_password_page.dart';
import 'user_details_page.dart'; // Import UserDetailsPage
import 'artist_page.dart'; // Import ArtistPage
import 'customer_page.dart'; // Import CustomerPage

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Initialize Cloud Firestore instance

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<Map<String, dynamic>?> _getUserData(String email) async {
    final snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data();
    }
    return null;
  }

  Future<void> _signIn() async {
    try {
      final Map<String, dynamic> UserData = {
        'type': 'Customer',
      };
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      final userData = await _getUserData(email);

      if (userData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email not found. Please sign up first.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (userData['password'] == password) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-in successful!'),
            backgroundColor: Colors.green,
          ),
        );

        if (userData['type'] == 'Artist') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => AdminHomePage(userData: userData)),
          );
        } else if (UserData['type'] == 'Customer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => CustomerHomePage(userData: userData)),
          );
        }

        _emailController.clear();
        _passwordController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Incorrect password. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign in: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  TextStyle getLabelStyle(double screenWidth) {
    double fontSize = screenWidth * 0.04;
    if (fontSize < 16) {
      fontSize = 16;
    }
    return TextStyle(
      color: Color(0xFF443D2A),
      fontFamily: 'Inika',
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
      height: 1.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sign in to your Account',
                style: TextStyle(
                  color: Color(0xFF443D2A),
                  fontFamily: 'Inika',
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.normal,
                  height: 1.0,
                ),
              ),
              SizedBox(height: 20),
              Text('Email', style: getLabelStyle(screenWidth)),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'example@example.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF443D2A), width: 3),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20),
              Text('Password', style: getLabelStyle(screenWidth)),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  suffixIcon: GestureDetector(
                    onTap: _togglePasswordVisibility,
                    child: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF443D2A), width: 3),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                obscureText: _obscurePassword,
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF443D2A),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Login Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Inika',
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ForgotPasswordPage()),
                    );
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Color(0xFF443D2A),
                      fontFamily: 'Inika',
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      height: 1.0,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpPage()),
                    );
                  },
                  child: Text(
                    "Don't have an account? Sign up",
                    style: TextStyle(
                      color: Color(0xFF443D2A),
                      fontFamily: 'Inika',
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      height: 1.0,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
