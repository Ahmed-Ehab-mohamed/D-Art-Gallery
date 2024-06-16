import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'A_signin_page.dart';
import 'sign_in.dart'; // Update this import to your actual Google Sign-Up page

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String? _selectedTitle;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  File? _pickedImageFile;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid();

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

  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _pickedImageFile = File(pickedImage.path);
      });
    }
  }

  Future<String?> _uploadImageToStorage(File imageFile) async {
    try {
      final storageRef = firebase_storage.FirebaseStorage.instance
          .ref('ProfileImages/${_uuid.v4()}.jpg');
      await storageRef.putFile(imageFile);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _signUp() async {
    try {
      final String name = _nameController.text.trim();
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();
      final String confirmPassword = _confirmPasswordController.text.trim();

      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Passwords do not match!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedTitle != 'Artist' && _selectedTitle != 'Customer') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Invalid title. Please choose either Artist or Customer.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String? imageUrl;
      if (_pickedImageFile != null) {
        imageUrl = await _uploadImageToStorage(_pickedImageFile!);
      }

      Map<String, dynamic> userData = {
        'name': name,
        'email': email,
        'password': password,
        'title': _selectedTitle,
        'photo': imageUrl ?? '',
        'uid': userCredential.user!.uid,
        'followers': 0,
        'following': 0,
      };

      if (_selectedTitle == 'Artist') {
        userData['artPieces'] = 0;
      } else {
        userData['transactions'] = 0;
      }

      await _firestore.collection('users').doc(userCredential.user!.uid).set(
            userData,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signup successful!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear the text fields
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      setState(() {
        _selectedTitle = null;
      });

      // Navigate to another page if necessary
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign up: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
              Text('Email', style: getLabelStyle()),
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
              Text('Title', style: getLabelStyle()),
              DropdownButton<String>(
                value: _selectedTitle,
                hint: Text('Select your title'),
                items: <String>['Artist', 'Customer'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTitle = newValue;
                  });
                },
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Upload Image'),
                ),
              ),
              SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF443D2A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: Size(200, 50),
                  ),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 18, fontFamily: 'Inika'),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: SizedBox(
                  height: 50,
                  child: SignInButton(
                    Buttons.google,
                    text: "Sign up with Google",
                    onPressed: _signInWithGoogle,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignInPage()),
                    );
                  },
                  child: Text(
                    'Already have an account? Sign in',
                    style: TextStyle(
                      color: Color(0xFF443D2A),
                      fontFamily: 'Inika',
                      fontSize: 18,
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
