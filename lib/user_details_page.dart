import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: ProfileSearchScreen()));
}

class ProfileSearchScreen extends StatefulWidget {
  @override
  _ProfileSearchScreenState createState() => _ProfileSearchScreenState();
}

class _ProfileSearchScreenState extends State<ProfileSearchScreen> {
  String searchText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (text) {
                setState(() {
                  searchText = text;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by profile name',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Profile')
                  .where('name', isGreaterThanOrEqualTo: searchText)
                  .where('name', isLessThanOrEqualTo: searchText + '\uf8ff')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data?.docs.isEmpty == true) {
                  return Center(child: Text('No profiles found'));
                }
                final profiles = snapshot.data?.docs ?? [];
                return ListView.builder(
                  itemCount: profiles.length,
                  itemBuilder: (context, index) {
                    final profile =
                        profiles[index].data() as Map<String, dynamic>;

                    final photo = profile['photo'] ?? '';
                    final name = profile['name'] ?? '';
                    final artPieces = profile['art pieces'] ?? 0;
                    final followers = profile['followers'] ?? 0;
                    final following = profile['following'] ?? 0;

                    // Log profile data to debug
                    print('Profile data: $profile');

                    return Container(
                      margin: EdgeInsets.all(8.0),
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (photo.isNotEmpty)
                            Image.network(
                              photo,
                              height: 150,
                              width: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.error,
                                  size: 150,
                                ); // Display error icon if image fails to load
                              },
                            )
                          else
                            Icon(
                              Icons.image_not_supported,
                              size: 150,
                            ), // Display placeholder if no image URL
                          SizedBox(height: 8.0),
                          Text(
                            'Name: $name',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('Art Pieces: $artPieces'),
                          Text('Followers: $followers'),
                          Text('Following: $following'),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
