import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class UserProfilePage extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const UserProfilePage({Key? key, this.userData}) : super(key: key);

  Future<void> _incrementFollowers() async {
    if (userData == null) return;

    try {
      final userRef = FirebaseFirestore.instance.collection('Users').doc();

      // Fetch current user data
      final userDoc = await userRef.get();
      if (userDoc.exists) {
        final currentUserData = userDoc.data()!;
        final currentFollowers = currentUserData['followers'] ?? 0;

        // Increment followers count
        await userRef.update({
          'followers': currentFollowers + 1,
        });
      }
    } catch (e) {
      print('Error updating followers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    var containerWidth = isLandscape
        ? MediaQuery.of(context).size.width - 30.0
        : MediaQuery.of(context).size.width;
    var containerHeight = isLandscape
        ? MediaQuery.of(context).size.height - 10.0 // Adjusted container height
        : MediaQuery.of(context).size.height -
            20.0; // Adjusted container height

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Recent Work'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: userData?['photo'] != null
                  ? NetworkImage(userData!['photo'])
                  : null,
              radius: 105.0,
            ),
            SizedBox(height: 10),
            Text(
              userData?['name'] ?? '',
              style: TextStyle(
                color: Color(0xFF443D2A),
                fontFamily: 'Inika',
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      'Followers',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${userData?['followers'] ?? 0}',
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Following',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${userData?['following'] ?? 0}',
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Art Work',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${userData?['art pieces'] ?? 0}',
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _incrementFollowers();
                // After updating followers count in Firebase, you may want to update the UI as well
                (context as Element).reassemble();
              },
              child: Text('Follow'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 7, horizontal: 28),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 4,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserProfilePage(userData: userData),
                      ),
                    ); //Navigate to page for first image
                  },
                  child: Image.asset(
                    'assets/images/artbook.png',
                    width: 50,
                    height: 50,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserProfilePage2(userData: userData),
                      ),
                    );
                  },
                  child: Image.asset(
                    'assets/images/Purchase Order.png',
                    width: 50,
                    height: 50,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserProfilePage3(userData: userData),
                      ),
                    );
                  },
                  child: Image.asset(
                    'assets/images/auction.png',
                    width: 50,
                    height: 50,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Recent Work',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 10),
            RecentPaintingList(
              artistName: userData?['name'] ?? '',
              containerWidth: containerWidth,
              containerHeight: containerHeight,
            ),
          ],
        ),
      ),
    );
  }
}

class RecentPaintingList extends StatelessWidget {
  final String artistName;
  final double containerWidth;
  final double containerHeight;

  const RecentPaintingList({
    required this.artistName,
    required this.containerWidth,
    required this.containerHeight,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Paintings')
          .where('artist', isEqualTo: artistName)
          .where('recent work', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No recent paintings available'));
        }
        final paintings = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: paintings.length,
          itemBuilder: (context, index) {
            final painting = paintings[index].data() as Map<String, dynamic>;

            // Safely parse fields with appropriate type checking
            final photo = painting['photo'] ?? '';
            final artist = painting['artist'] ?? '';
            final price = painting['price'] ?? '';
            final name = painting['name'] ?? '';
            final type = painting['type'] ?? '';

            return Container(
              margin: EdgeInsets.all(8.0),
              padding: EdgeInsets.all(8.0),
              width: containerWidth,
              height: containerHeight,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    photo,
                    width: containerWidth,
                    height: containerHeight * 0.6,
                    fit: BoxFit.cover,
                  ), // Display the painting photo
                  SizedBox(height: 8.0),
                  Text(
                    'Artist: $artist',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ), // Display the artist name
                  Text(
                    'Price: $price',
                  ), // Display the painting price
                  Text(
                    'Name: $name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ), // Display the painting name
                  Text(
                    'Type: $type',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ), // Display the painting type
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class UserProfilePage2 extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const UserProfilePage2({Key? key, this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    var containerWidth = isLandscape
        ? MediaQuery.of(context).size.width - 30.0
        : MediaQuery.of(context).size.width;
    var containerHeight = isLandscape
        ? MediaQuery.of(context).size.height - 10.0 // Adjusted container height
        : MediaQuery.of(context).size.height -
            20.0; // Adjusted container height

    Future<void> _increaseFollowers() async {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(userData?['uid']);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);
        if (!snapshot.exists) {
          throw Exception("User does not exist!");
        }
        final currentFollowers = snapshot.get('followers') ?? 0;
        transaction.update(userRef, {'followers': currentFollowers + 1});
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Recent Special Request'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: userData?['photo'] != null
                  ? NetworkImage(userData!['photo'])
                  : null,
              radius: 105.0,
            ),
            SizedBox(height: 10),
            Text(
              userData?['name'] ?? '',
              style: TextStyle(
                color: Color(0xFF443D2A),
                fontFamily: 'Inika',
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      'Followers',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${userData?['followers'] ?? 0}',
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Following',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${userData?['following'] ?? 0}',
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Art Work',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${userData?['art pieces'] ?? 0}',
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _increaseFollowers();
              },
              child: Text('Follow'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 7, horizontal: 28),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 4,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserProfilePage(userData: userData),
                      ),
                    ); //Navigate to page for first image
                  },
                  child: Image.asset(
                    'assets/images/artbook.png',
                    width: 50,
                    height: 50,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserProfilePage2(userData: userData),
                      ),
                    );
                  },
                  child: Image.asset(
                    'assets/images/Purchase Order.png',
                    width: 50,
                    height: 50,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserProfilePage3(userData: userData),
                      ),
                    );
                  },
                  child: Image.asset(
                    'assets/images/auction.png',
                    width: 50,
                    height: 50,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Recent Special Request',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 10),
            RecentPaintingList(
              artistName: userData?['name'] ?? '',
              containerWidth: containerWidth,
              containerHeight: containerHeight,
            ),
          ],
        ),
      ),
    );
  }
}

class RecentPaintingList2 extends StatelessWidget {
  final String artistName;
  final double containerWidth;
  final double containerHeight;

  const RecentPaintingList2({
    required this.artistName,
    required this.containerWidth,
    required this.containerHeight,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Paintings')
          .where('artist', isEqualTo: artistName)
          .where('request', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No recent paintings available'));
        }
        final paintings = snapshot.data!.docs;
        return ListView.builder(
          itemCount: paintings.length,
          itemBuilder: (context, index) {
            final painting = paintings[index].data() as Map<String, dynamic>;

            // Safely parse fields with appropriate type checking
            final photo = painting['photo'] ?? '';
            final artist = painting['artist'] ?? '';
            final price = painting['price'] ?? '';
            final name = painting['name'] ?? '';
            final type = painting['type'] ?? '';

            return Container(
              margin: EdgeInsets.all(8.0),
              padding: EdgeInsets.all(8.0),
              width: containerWidth,
              height: containerHeight,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    photo,
                    width: containerWidth,
                    height: containerHeight * 0.6,
                    fit: BoxFit.cover,
                  ), // Display the painting photo
                  SizedBox(height: 8.0),
                  Text(
                    'Artist: $artist',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ), // Display the artist name
                  Text(
                    'Price: \$$price',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Name: $name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Type: $type',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // Display the price
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class UserProfilePage3 extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const UserProfilePage3({Key? key, this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    var containerWidth = isLandscape
        ? MediaQuery.of(context).size.width - 30.0
        : MediaQuery.of(context).size.width;
    var containerHeight = isLandscape
        ? MediaQuery.of(context).size.height - 10.0 // Adjusted container height
        : MediaQuery.of(context).size.height -
            20.0; // Adjusted container height

    Future<void> _increaseFollowers() async {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(userData?['uid']);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);
        if (!snapshot.exists) {
          throw Exception("User does not exist!");
        }
        final currentFollowers = snapshot.get('followers') ?? 0;
        transaction.update(userRef, {'followers': currentFollowers + 1});
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Recent Bid'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: userData?['photo'] != null
                  ? NetworkImage(userData!['photo'])
                  : null,
              radius: 105.0,
            ),
            SizedBox(height: 10),
            Text(
              userData?['name'] ?? '',
              style: TextStyle(
                color: Color(0xFF443D2A),
                fontFamily: 'Inika',
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      'Followers',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${userData?['followers'] ?? 0}',
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Following',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${userData?['following'] ?? 0}',
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Art Work',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${userData?['art pieces'] ?? 0}',
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _increaseFollowers();
              },
              child: Text('Follow'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 7, horizontal: 28),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 4,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserProfilePage(userData: userData),
                      ),
                    ); //Navigate to page for first image
                  },
                  child: Image.asset(
                    'assets/images/artbook.png',
                    width: 50,
                    height: 50,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserProfilePage2(userData: userData),
                      ),
                    );
                  },
                  child: Image.asset(
                    'assets/images/Purchase Order.png',
                    width: 50,
                    height: 50,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserProfilePage3(userData: userData),
                      ),
                    );
                  },
                  child: Image.asset(
                    'assets/images/auction.png',
                    width: 50,
                    height: 50,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Recent Bid',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 10),
            RecentPaintingList(
              artistName: userData?['name'] ?? '',
              containerWidth: containerWidth,
              containerHeight: containerHeight,
            ),
          ],
        ),
      ),
    );
  }
}

class RecentPaintingList3 extends StatelessWidget {
  final String artistName;
  final double containerWidth;
  final double containerHeight;

  const RecentPaintingList3({
    required this.artistName,
    required this.containerWidth,
    required this.containerHeight,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Paintings')
          .where('artist', isEqualTo: artistName)
          .where('bid', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No recent paintings available'));
        }
        final paintings = snapshot.data!.docs;
        return ListView.builder(
          itemCount: paintings.length,
          itemBuilder: (context, index) {
            final painting = paintings[index].data() as Map<String, dynamic>;

            // Safely parse fields with appropriate type checking
            final photo = painting['photo'] ?? '';
            final artist = painting['artist'] ?? '';
            final price = painting['price'] ?? '';
            final name = painting['name'] ?? '';
            final type = painting['type'] ?? '';

            return Container(
              margin: EdgeInsets.all(8.0),
              padding: EdgeInsets.all(8.0),
              width: containerWidth,
              height: containerHeight,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    photo,
                    width: containerWidth,
                    height: containerHeight * 0.6,
                    fit: BoxFit.cover,
                  ), // Display the painting photo
                  SizedBox(height: 8.0),
                  Text(
                    'Artist: $artist',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ), // Display the artist name
                  Text(
                    'Price: \$$price',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Name: $name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Type: $type',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // Display the price
                ],
              ),
            );
          },
        );
      },
    );
  }
}
