import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: PaintingSearchScreen()));
}

class PaintingSearchScreen extends StatefulWidget {
  @override
  _PaintingSearchScreenState createState() => _PaintingSearchScreenState();
}

class _PaintingSearchScreenState extends State<PaintingSearchScreen> {
  String searchText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Painting Search')),
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
                hintText: 'Search by painting name',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Paintings')
                  .where('name', isGreaterThanOrEqualTo: searchText)
                  .where('name', isLessThanOrEqualTo: searchText + '\uf8ff')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (!snapshot.hasData) {
                  return Text('No data available');
                }
                final paintings = snapshot.data?.docs ?? [];
                return ListView.builder(
                  itemCount: paintings.length,
                  itemBuilder: (context, index) {
                    final painting =
                        paintings[index].data() as Map<String, dynamic>;

                    // Log the painting data to debug
                    print('Painting data: $painting');

                    // Safely parse fields with appropriate type checking
                    final photo = painting['photo'] ?? '';
                    final name = painting['name'] ?? '';
                    final artist = painting['artist'] ?? '';
                    final price = painting['price'] ?? '';
                    final rate = painting['rate']?.toDouble() ?? 0.0;
                    final bid = painting['bid'] is bool
                        ? painting['bid']
                        : (painting['bid'] == 'true');
                    final recentWork = painting['recent work'] is bool
                        ? painting['recent work']
                        : (painting['recent work'] == 'true');
                    final request = painting['request'] is bool
                        ? painting['request']
                        : (painting['request'] == 'true');
                    final trending = painting['trending'] is bool
                        ? painting['trending']
                        : (painting['trending'] == 'true');
                    final type = painting['type'] ?? '';

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
                          Image.network(photo), // Display the painting photo
                          SizedBox(height: 8.0),
                          Text('Name: $name'), // Display the painting name
                          Text('Artist: $artist'), // Display the artist name
                          Text('Price: \$$price'), // Display the price
                          Text('Rating: $rate'), // Display the rating
                          Text(
                              'Bid: ${bid ? "Available" : "Not Available"}'), // Display the bid status
                          Text(
                              'Recent Work: ${recentWork ? "Yes" : "No"}'), // Display recent work status
                          Text(
                              'Request: ${request ? "Requested" : "Not Requested"}'), // Display request status
                          Text(
                              'Trending: ${trending ? "Trending" : "Not Trending"}'), // Display trending status
                          Text('Type: $type'), // Display the type of painting
                          // Add other fields as needed
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
