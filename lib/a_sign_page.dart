import 'package:flutter/material.dart';
import 'package:d_art_gallery/signup_page.dart';
import 'package:d_art_gallery/A_signin_page.dart';
import 'darkmode.dart';
import 'package:provider/provider.dart';

class ASignPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.themeMode == ThemeMode.light
          ? Colors.white
          : Colors.black,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 72), // Vertical space to position the text
              Text(
                'Artist !',
                style: TextStyle(
                  color: themeProvider.themeMode == ThemeMode.light
                      ? Color(0xFF443D2A)
                      : Colors.white,
                  fontFamily: 'Inika',
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                ),
              ),
              // Do you love art?
              Text(
                'Do you love your job?',
                style: TextStyle(
                  color: themeProvider.themeMode == ThemeMode.light
                      ? Color(0xFF443D2A)
                      : Colors.white,
                  fontFamily: 'Inika',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),

              SizedBox(height: 20),
              Container(
                width: 100,
                height: 100,
                child: Image.asset('assets/images/Curved Arrow Down.png'),
              ),

              SizedBox(height: 20),

              // Buttons for "Sign In" and "Sign Up"
              ElevatedButton(
                onPressed: () {
                  // Navigate to sign in page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignInPage()),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    themeProvider.themeMode == ThemeMode.light
                        ? Colors.white
                        : Colors.black,
                  ),
                  foregroundColor: MaterialStateProperty.all<Color>(
                    themeProvider.themeMode == ThemeMode.light
                        ? Color(0xFF443D2A)
                        : Colors.white,
                  ),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                  ),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(80),
                      side: BorderSide(
                        color: themeProvider.themeMode == ThemeMode.light
                            ? Color(0xFF443D2A)
                            : Colors.white,
                        width: 6,
                      ),
                    ),
                  ),
                  shadowColor: MaterialStateProperty.all<Color>(
                    Color.fromRGBO(0, 0, 0, 0.25),
                  ),
                ),
                child: Text(
                  'Sign In',
                  style: TextStyle(
                    color: themeProvider.themeMode == ThemeMode.light
                        ? Color(0xFF443D2A)
                        : Colors.white,
                    fontFamily: 'Inika',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  // Navigate to sign up page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpPage()),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    themeProvider.themeMode == ThemeMode.light
                        ? Colors.white
                        : Colors.black,
                  ),
                  foregroundColor: MaterialStateProperty.all<Color>(
                    themeProvider.themeMode == ThemeMode.light
                        ? Color(0xFF443D2A)
                        : Colors.white,
                  ),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                  ),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(80),
                      side: BorderSide(
                        color: themeProvider.themeMode == ThemeMode.light
                            ? Color(0xFF443D2A)
                            : Colors.white,
                        width: 6,
                      ),
                    ),
                  ),
                  shadowColor: MaterialStateProperty.all<Color>(
                    Color.fromRGBO(0, 0, 0, 0.25),
                  ),
                ),
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    color: themeProvider.themeMode == ThemeMode.light
                        ? Color(0xFF443D2A)
                        : Colors.white,
                    fontFamily: 'Inika',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
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
