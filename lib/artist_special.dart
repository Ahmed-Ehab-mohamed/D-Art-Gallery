import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Georgia',
        primarySwatch: Colors.brown,
      ),
      home: RecentSpecialRequestsPage(),
    );
  }
}

class RecentSpecialRequestsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40, // Smaller radius
              backgroundImage: AssetImage('assets/images/pic1.avif'),
            ),
            SizedBox(height: 8),
            Text(
              'Rozy ⭐',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      '36',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text('Art pieces'),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '590',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text('followers'),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '100',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text('following'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.brown),
                    textStyle: TextStyle(
                        color: Colors.brown[900], fontWeight: FontWeight.bold),
                  ),
                  child: Text('Edit Profile'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.brown),
                    textStyle: TextStyle(
                        color: Colors.brown[900], fontWeight: FontWeight.bold),
                  ),
                  child: Text('Share Profile'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(color: Colors.brown[900]),
            SizedBox(height: 16),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.brush, size: 50, color: Colors.brown[900]),
                  Icon(Icons.book_sharp, size: 50, color: Colors.brown[900]),
                  Icon(Icons.settings, size: 50, color: Colors.brown[900]),
                ],
              ),
            ),
            SizedBox(height: 16),
            Divider(color: Colors.brown[900]),
            SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Icon(Icons.upload_file, size: 50, color: Colors.brown[900]),
                  SizedBox(height: 8),
                  Text('Upload',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            SizedBox(height: 16),
            Divider(color: Colors.black),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent Special Requests',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
              itemCount: 4,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black)),
                  child: Image.asset(
                    'assets/images/pic1.avif',
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
