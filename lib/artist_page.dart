import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'editprofilepage.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart'; // Import your ChatMessages widget // Import your NewMessage widget

class AdminHomePage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const AdminHomePage({Key? key, this.userData}) : super(key: key);

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  bool isChatOpen = false; // Track whether the chat is open or closed

  @override
  Widget build(BuildContext context) {
    var isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    var containerWidth = isLandscape
        ? MediaQuery.of(context).size.width - 30.0
        : MediaQuery.of(context).size.width;
    var containerHeight = isLandscape
        ? MediaQuery.of(context).size.height - 10.0
        : MediaQuery.of(context).size.height - 20.0;
    var avatarRadius = isLandscape ? 78.0 : 30.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      UserProfilePage(userData: widget.userData),
                ),
              );
            },
            child: CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: widget.userData?['photo'] != null
                  ? NetworkImage(widget.userData!['photo'])
                  : null,
              radius: avatarRadius,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                widget.userData?['name'] ?? 'Admin',
                style: TextStyle(
                  color: Color(0xFF443D2A),
                  fontFamily: 'Inika',
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderHistoryPage(
                      userName: widget.userData?['name'] ?? 'Admin',
                    ),
                  ),
                );
              },
              child: Image.asset(
                'assets/images/Order History.png',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                setState(() {
                  // Toggle the state of isChatOpen
                  isChatOpen = !isChatOpen;
                });
              },
              child: Icon(Icons.admin_panel_settings),
            ),
            SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      AuctionFormDialog(userData: widget.userData),
                );
              },
              child: Icon(Icons.gavel), // Add icon for the auction form
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (isChatOpen)
            Expanded(
              child: ChatScreen(
                  userData: widget.userData), // Display the chat screen
            ), // Allow the admin to send messages
          Expanded(
            child: PaintingListScreen(
              artistName:
                  widget.userData?['name'] ?? 'Admin', // Pass artist name
              containerWidth: containerWidth,
              containerHeight: containerHeight,
            ),
          ), // Display the painting list
        ],
      ),
    );
  }
}

class OrderHistoryPage extends StatelessWidget {
  final String userName;

  const OrderHistoryPage({Key? key, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order History'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Bought')
            .where('artist', isEqualTo: userName)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return Center(child: Text('No orders found.'));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index].data() as Map<String, dynamic>;
              var photo = order['photo'] ?? '';
              var artist = order['artist'] ?? '';
              var buyer = order['buyer'] ?? '';

              return ListTile(
                leading: photo.isNotEmpty
                    ? Image.network(photo,
                        width: 50, height: 50, fit: BoxFit.cover)
                    : Icon(Icons.image, size: 50),
                title: Text('Artist: $artist'),
                subtitle: Text('Buyer: $buyer'),
              );
            },
          );
        },
      ),
    );
  }
}

class PaintingListScreen extends StatelessWidget {
  final String artistName;
  final double containerWidth;
  final double containerHeight;

  const PaintingListScreen({
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
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No paintings available'));
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

class AuctionFormDialog extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const AuctionFormDialog({Key? key, this.userData}) : super(key: key);

  @override
  _AuctionFormDialogState createState() => _AuctionFormDialogState();
}

class _AuctionFormDialogState extends State<AuctionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  File? _image;
  bool _isUploading = false;

  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  Future<void> _uploadData() async {
    if (_formKey.currentState!.validate() && _image != null) {
      setState(() {
        _isUploading = true;
      });

      try {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('files/bidding/$fileName'); // Updated path
        UploadTask uploadTask = storageRef.putFile(_image!);
        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadURL = await taskSnapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('bid').add({
          'name': _nameController.text,
          'startingPrice': double.parse(_priceController.text),
          'duration': int.parse(_durationController.text),
          'timestamp': DateTime.now(),
          'photoUrl': downloadURL,
          'author': widget.userData?['name'], // Added author name
        });

        Navigator.of(context).pop();
      } catch (e) {
        // Handle error
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Start an Auction'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Painting Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the painting name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Starting Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the starting price';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _durationController,
                decoration: InputDecoration(labelText: 'Duration (minutes)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the duration';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              _image == null
                  ? Text('No image selected.')
                  : Image.file(_image!, height: 150),
              TextButton(
                onPressed: _pickImage,
                child: Text('Select Image'),
              ),
              _isUploading ? CircularProgressIndicator() : Container(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: _uploadData,
          child: Text('Submit'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }
}

class UserProfilePage extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const UserProfilePage({Key? key, this.userData}) : super(key: key);

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
              radius: 75.0,
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(userData: userData),
                  ),
                );
              },
              child: Text('Edit Profile'),
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
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      UploadFormDialog(artistName: userData?['name'] ?? ''),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/Artist.png',
                    width: 20,
                    height: 20,
                  ),
                  SizedBox(width: 10),
                  Text('Upload'),
                ],
              ),
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
              radius: 75.0,
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(userData: userData),
                  ),
                );
              },
              child: Text('Edit Profile'),
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
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      UploadFormDialog(artistName: userData?['name'] ?? ''),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/Artist.png',
                    width: 20,
                    height: 20,
                  ),
                  SizedBox(width: 10),
                  Text('Upload'),
                ],
              ),
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
              radius: 75.0,
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(userData: userData),
                  ),
                );
              },
              child: Text('Edit Profile'),
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
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      UploadFormDialog(artistName: userData?['name'] ?? ''),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/Artist.png',
                    width: 20,
                    height: 20,
                  ),
                  SizedBox(width: 10),
                  Text('Upload'),
                ],
              ),
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

class UploadFormDialog extends StatefulWidget {
  final String artistName;

  const UploadFormDialog({required this.artistName});

  @override
  _UploadFormDialogState createState() => _UploadFormDialogState();
}

class _UploadFormDialogState extends State<UploadFormDialog> {
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  String? _name;
  int? _pieceNumber;
  String? _type;
  double? _latitude;
  double? _longitude;
  bool _locationFetched = false;

  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _imageFile = File(pickedFile?.path ?? '');
    });
  }

  Future<void> _getCurrentLocation() async {
    var status = await Permission.locationWhenInUse.status;
    if (!status.isGranted) {
      status = await Permission.locationWhenInUse.request();
    }

    if (status.isGranted) {
      try {
        final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _locationFetched = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location fetched successfully.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch location: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permissions are denied.')),
      );
    }
  }

  Future<void> _uploadData() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      if (_imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No image selected.')),
        );
        return;
      }

      if (_latitude == null || _longitude == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location not fetched.')),
        );
        return;
      }

      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('paintings/${DateTime.now().toIso8601String()}');
        final uploadTask = storageRef.putFile(_imageFile!);

        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('Paintings').add({
          'photo': downloadUrl,
          'name': _name,
          'pieceNumber': _pieceNumber,
          'type': _type,
          'latitude': _latitude,
          'longitude': _longitude,
          'artist': widget.artistName,
        });

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload successful.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Upload Painting'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _imageFile == null
                  ? Text('No image selected.')
                  : Image.file(_imageFile!),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Select Image'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Piece Number'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a piece number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _pieceNumber = int.tryParse(value!);
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Type'),
                items: [
                  DropdownMenuItem(
                    value: 'Painting',
                    child: Text('Painting'),
                  ),
                  DropdownMenuItem(
                    value: 'Antique',
                    child: Text('Antique'),
                  ),
                  DropdownMenuItem(
                    value: 'Craft',
                    child: Text('Craft'),
                  ),
                  DropdownMenuItem(
                    value: 'Other',
                    child: Text('Other'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _type = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a type';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _getCurrentLocation,
                child: Text('Get Location'),
              ),
              if (_locationFetched) Text('Location fetched successfully'),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: _uploadData,
          child: Text('Upload'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }
}
