import 'dart:async'; // Import async library
import 'dart:io'; // Import dart:io library for File class
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore package
import 'package:uuid/uuid.dart'; // Import UUID package
import 'package:image_picker/image_picker.dart'; // Import image picker package

class GoogleSignUp extends StatefulWidget {
  final GoogleSignInAccount googleUser;

  GoogleSignUp({required this.googleUser});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<GoogleSignUp> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _verificationCode = ''; // Variable to store verification code
  String? _selectedType;
  File? _pickedImage;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Initialize Cloud Firestore instance
  final ImagePicker _picker = ImagePicker(); // Initialize ImagePicker

  @override
  void initState() {
    super.initState();
    _selectedType = 'Customer'; // Default user type
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  Future<bool> _isEmailExisting(String email) async {
    final snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Future<void> _signUp() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not signed in');
      }

      final String name = _nameController.text.trim();
      final String email = widget.googleUser.email!;
      final String password = _passwordController.text.trim();
      final String confirmPassword = _confirmPasswordController.text.trim();
      final String type = _selectedType!;
      final String verificationCode =
          Uuid().v4(); // Generate a unique verification code

      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Passwords do not match!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final bool emailExists = await _isEmailExisting(email);

      if (emailExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email already exists. Please sign in.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      String? imageUrl;
      if (_pickedImage != null) {
        // Upload image to Firebase Storage
        final storageRef =
            FirebaseStorage.instance.ref('ProfileImages/${Uuid().v4()}.jpg');
        await storageRef.putFile(_pickedImage!);
        imageUrl = await storageRef.getDownloadURL();
      }

      // Add user data to Cloud Firestore
      await _firestore.collection('users').add({
        'name': name,
        'email': email,
        'password': password,
        'type': type,
        'uuid': verificationCode,
        'photo': imageUrl,
        'followers': 0,
        'following': 0,
        'art_pieces': type == 'Artist' ? 0 : null,
        'transactions': type == 'Customer' ? 0 : null,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signup successful!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear the text fields
      _nameController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();

      // Start a timer to remove the verification code after 10 seconds
      Timer(Duration(seconds: 10), () {
        setState(() {
          _verificationCode = '';
        });
      });

      // Set the verification code
      setState(() {
        _verificationCode = verificationCode;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign up: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _pickedImage = File(pickedImage.path);
      });
    }
  }

  TextStyle getLabelStyle() {
    return TextStyle(
      color: Color(0xFF443D2A),
      fontFamily: 'Inika',
      fontSize: 20,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
      height: 1.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Text(
                'Create your Account',
                style: TextStyle(
                  color: Color(0xFF443D2A),
                  fontFamily: 'Inika',
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.normal,
                  height: 1.0,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Email: ${widget.googleUser.email}',
                style: getLabelStyle(),
              ),
              SizedBox(height: 20),
              Text('Name', style: getLabelStyle()),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF443D2A), width: 3),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Text('Password', style: getLabelStyle()),
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
              Text('Confirm Password', style: getLabelStyle()),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  hintText: 'Confirm your password',
                  suffixIcon: GestureDetector(
                    onTap: _toggleConfirmPasswordVisibility,
                    child: Icon(
                      _obscureConfirmPassword
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
                obscureText: _obscureConfirmPassword,
              ),
              SizedBox(height: 20),
              Text('User Type', style: getLabelStyle()),
              DropdownButton<String>(
                value: _selectedType,
                items: <String>['Artist', 'Customer'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedType = newValue;
                  });
                },
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Pick Image'),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _signUp,
                  child: Text('Sign Up'),
                ),
              ),
              SizedBox(height: 20),
              Visibility(
                visible: _verificationCode.isNotEmpty,
                child: Center(
                  child: Text('Verification Code: $_verificationCode'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _signOut() async {
    await _googleSignIn.signOut();
    Navigator.pop(context);
  }
}
