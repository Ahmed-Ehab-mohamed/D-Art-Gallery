import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'darkmode.dart';
import 'package:d_art_gallery/a_sign_page.dart';
import 'package:d_art_gallery/C_sign_page.dart'; // Import your theme provider

class AccountTypePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isPortrait = mediaQuery.orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: themeProvider.themeMode == ThemeMode.light
          ? Colors.white
          : Colors.black,
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          56, // Left padding
          72, // Top padding
          0, // Right padding
          0, // Bottom padding
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Welcome message
                Text(
                  'Welcome!',
                  style: TextStyle(
                    color: themeProvider.themeMode == ThemeMode.light
                        ? Color(0xFF443D2A)
                        : Colors.white,
                    fontFamily: 'Inika',
                    fontSize:
                        isPortrait ? screenWidth * 0.1 : screenHeight * 0.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Choose Account type...',
                  style: TextStyle(
                    color: themeProvider.themeMode == ThemeMode.light
                        ? Color(0xFF443D2A)
                        : Colors.white,
                    fontFamily: 'Inika',
                    fontSize:
                        isPortrait ? screenWidth * 0.04 : screenHeight * 0.04,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                SizedBox(height: 20),

                // Image above buttons
                Container(
                  width: isPortrait ? screenWidth * 0.3 : screenHeight * 0.3,
                  height: isPortrait ? screenWidth * 0.3 : screenHeight * 0.3,
                  child: Image.asset('assets/images/Curved Arrow Down.png'),
                ),

                SizedBox(height: 20),

                // Buttons for account types
                TextButton(
                  onPressed: () {
                    // Navigate to ASignPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ASignPage()),
                    );
                  },
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(
                      themeProvider.themeMode == ThemeMode.light
                          ? Color(0xFF443D2A)
                          : Colors.white,
                    ),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.symmetric(
                        horizontal:
                            isPortrait ? screenWidth * 0.2 : screenHeight * 0.2,
                        vertical: 8, // Adjusted vertical padding
                      ),
                    ),
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          isPortrait ? screenWidth * 0.4 : screenHeight * 0.4,
                        ),
                        side: BorderSide(
                          color: themeProvider.themeMode == ThemeMode.light
                              ? Color(0xFF443D2A)
                              : Colors.white,
                          width: 6,
                        ),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8), // Add padding to the child
                    child: Text(
                      'Artist',
                      style: TextStyle(
                        color: themeProvider.themeMode == ThemeMode.light
                            ? Color(0xFF443D2A)
                            : Colors.white,
                        fontFamily: 'Inika',
                        fontSize:
                            isPortrait ? screenWidth * 0.1 : screenHeight * 0.1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    // Navigate to CSignPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CSignPage()),
                    );
                  },
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(
                      themeProvider.themeMode == ThemeMode.light
                          ? Color(0xFF443D2A)
                          : Colors.white,
                    ),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.zero, // No padding
                    ),
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          isPortrait ? screenWidth * 0.4 : screenHeight * 0.4,
                        ),
                        side: BorderSide(
                          color: themeProvider.themeMode == ThemeMode.light
                              ? Color(0xFF443D2A)
                              : Colors.white,
                          width: 6,
                        ),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8), // Add padding to the child
                    child: Text(
                      'Customer',
                      style: TextStyle(
                        color: themeProvider.themeMode == ThemeMode.light
                            ? Color(0xFF443D2A)
                            : Colors.white,
                        fontFamily: 'Inika',
                        fontSize:
                            isPortrait ? screenWidth * 0.1 : screenHeight * 0.1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
