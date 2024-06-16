import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'build_painting.dart';

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const ProfilePage({Key? key, this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var containerWidth = MediaQuery.of(context).size.width;
    var containerHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: userData?['photo'] != null
                    ? NetworkImage(userData!['photo'])
                    : null,
                radius: 52.5,
              ),
              SizedBox(height: 10),
              Text(
                userData?['name'] ?? 'User',
                style: TextStyle(
                  color: Color(0xFF443D2A),
                  fontFamily: 'Inika',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Followers: ${userData?['followers']}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              Text(
                'Following: ${userData?['following']}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              Text(
                'Art Pieces: ${userData?['artPieces']}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                child: Text('Edit Profile'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Image.asset('assets/images/artbook.png'),
                    iconSize: 50,
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Image.asset('assets/images/Purchase Order.png'),
                    iconSize: 50,
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Image.asset('assets/images/auction.png'),
                    iconSize: 50,
                    onPressed: () {},
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: Image.asset('assets/images/Artist.png', width: 24),
                label: Text('Upload'),
              ),
              SizedBox(height: 20),
              Container(
                width: 284,
                height: 0,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Recent Work',
                style: TextStyle(
                  color: Color(0xFF443D2A),
                  fontFamily: 'Inika',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              buildPaintingList(
                artistName: userData?['name'] ?? 'User Name',
                containerWidth: containerWidth,
                containerHeight: containerHeight,
                recentWork: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
