import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Widget buildPaintingList({
  required String artistName,
  required double containerWidth,
  required double containerHeight,
  bool recentWork = false,
}) {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('Paintings')
        .where('artist', isEqualTo: artistName)
        .where('recentWork', isEqualTo: recentWork)
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
            height: containerHeight * 0.5, // Adjust height as needed
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
                  height: containerHeight * 0.4,
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
