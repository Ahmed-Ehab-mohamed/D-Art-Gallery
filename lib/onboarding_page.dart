import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'onboarding_page_1.dart'; // Ensure this is the correct path to OnBoardingPage1
import 'darkmode.dart';

class OnBoardingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Use MediaQuery to get the size of the screen
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isPortrait = mediaQuery.orientation == Orientation.portrait;

    // Navigate to OnBoardingPage1 after a delay
    Future.delayed(Duration(milliseconds: 7000), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnBoardingPage1()),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Onboarding Page'),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      backgroundColor: themeProvider.themeMode == ThemeMode.light
          ? Color(0xFFFFF9F8)
          : Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: isPortrait ? screenWidth * 0.9 : screenHeight * 0.9,
              height: isPortrait ? screenHeight * 0.4 : screenHeight * 0.3,
              child: Image.asset(
                'assets/images/D art Gallery 1.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
