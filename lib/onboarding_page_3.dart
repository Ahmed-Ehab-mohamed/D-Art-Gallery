import 'dart:ui'; // Import dart:ui for ImageFilter
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'account_type.dart'; // Import AccountTypePage
import 'darkmode.dart';

class OnBoardingPage3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    // MediaQuery to get screen size and orientation
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isPortrait = mediaQuery.orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: themeProvider.themeMode == ThemeMode.light
          ? Color(0xFFFFF9F8)
          : Colors.black,
      appBar: AppBar(
        title: Text('Onboarding Page 3'),
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
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isPortrait ? screenWidth * 0.1 : screenWidth * 0.2,
              vertical: isPortrait ? screenHeight * 0.05 : screenHeight * 0.1,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Image widget with custom dimensions
                Container(
                  width: screenWidth * 0.95,
                  height: screenHeight * 0.55,
                  child: Image.asset(
                    'assets/images/unsplash_6c43FgRt0Dw.png',
                    fit: BoxFit.contain, // Ensure the full image is displayed
                  ),
                ),
                SizedBox(height: screenHeight * 0.02), // Spacer

                // Text widget "Request Special Order"
                Text(
                  'Request Special Order',
                  style: TextStyle(
                    color: themeProvider.themeMode == ThemeMode.light
                        ? Color(0xFF443D2A)
                        : Colors.white,
                    fontFamily: 'Inika',
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01), // Spacer

                // Text widget "Communicate with your favorite artist and make special orders..."
                Text(
                  'Communicate with your favorite artist and make special orders...',
                  style: TextStyle(
                    color: themeProvider.themeMode == ThemeMode.light
                        ? Color(0xFF443D2A)
                        : Colors.white70,
                    fontFamily: 'Inika',
                    fontSize: screenWidth * 0.03,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.02), // Spacer

                // Ellipses wrapped inside a Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Ellipse 1 (Dark filled circle)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: themeProvider.themeMode == ThemeMode.light
                            ? Color(0xFF443D2A)
                            : Colors.white,
                      ),
                      child: SizedBox(
                        width: screenWidth * 0.02,
                        height: screenWidth * 0.02,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03), // Spacer

                    // Ellipse 2 (Light filled circle)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: themeProvider.themeMode == ThemeMode.light
                            ? Color(0xFFD9D9D9)
                            : Colors.white54,
                      ),
                      child: SizedBox(
                        width: screenWidth * 0.02,
                        height: screenWidth * 0.02,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03), // Spacer

                    // Ellipse 3 (Light filled circle)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: themeProvider.themeMode == ThemeMode.light
                            ? Color(0xFFD9D9D9)
                            : Colors.white54,
                      ),
                      child: SizedBox(
                        width: screenWidth * 0.02,
                        height: screenWidth * 0.02,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.02), // Spacer

                // Next page button
                GestureDetector(
                  onTap: () {
                    // Navigate to AccountTypePage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccountTypePage(),
                      ),
                    );
                  },
                  child: Container(
                    width: screenWidth * 0.15,
                    height: screenWidth * 0.15,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(screenWidth * 0.075),
                      image: DecorationImage(
                        image: AssetImage('assets/images/Next page (1).png'),
                        fit: BoxFit.contain,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: themeProvider.themeMode == ThemeMode.light
                              ? Color(0xFFFFF9F8)
                              : Colors.black,
                          blurRadius: 2,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
