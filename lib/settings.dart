import 'package:flutter/material.dart';
import 'onboarding_page.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 50,
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  'Change Username',
                  style: TextStyle(fontSize: 25, color: Colors.brown[900]),
                ),
                TextField(
                  decoration: InputDecoration(
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'New Password',
                  style: TextStyle(fontSize: 25, color: Colors.brown[900]),
                ),
                TextField(
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.brown[900],
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                    hintText: 'Enter your new password',
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Bio',
                  style: TextStyle(fontSize: 25, color: Colors.brown[900]),
                ),
                TextField(
                  decoration: InputDecoration(
                    labelStyle: TextStyle(color: Colors.black),
                    hintText: 'Write something about yourself',
                  ),
                ),
                SizedBox(height: 20),
                Divider(color: Colors.brown[900]),
                SizedBox(height: 15),
                ExpansionTile(
                  title: Text(
                    'Activity',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[900],
                    ),
                  ),
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        'Last Activity',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Yesterday at 2:00 pm',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Divider(color: Colors.brown[900]),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Logout',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OnBoardingPage()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
