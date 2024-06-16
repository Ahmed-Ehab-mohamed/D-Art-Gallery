import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:math';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paintings Details',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Paintings Details'),
        ),
        body: FilterFirestore(),
      ),
    );
  }
}

class FilterFirestore extends StatefulWidget {
  const FilterFirestore({Key? key}) : super(key: key);

  @override
  _FilterFirestoreState createState() => _FilterFirestoreState();
}

class _FilterFirestoreState extends State<FilterFirestore> {
  late List<DocumentSnapshot> data;
  final Location _location = Location();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchData() async {
    CollectionReference paintings =
        FirebaseFirestore.instance.collection("Paintings");
    QuerySnapshot paintingsData = await paintings
        .where('artist',
            isEqualTo:
                'Nour') // Filter by artist name // Filter by maximum price
        .get();
    setState(() {
      data = paintingsData.docs;
    });
  }

  Future<LocationData> getLocation() async {
    LocationData currentLocation;
    try {
      currentLocation = await _location.getLocation();
    } catch (e) {
      currentLocation = LocationData.fromMap({
        "latitude": 0,
        "longitude": 0,
      });
    }
    return currentLocation;
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return data == null
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, i) {
              final itemData = data[i].data() as Map<String, dynamic>;
              return Card(
                child: Column(
                  children: [
                    ListTile(
                      title: Text('Name: ${itemData['name']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Artist: ${itemData['artist']}'),
                          Text('Price: ${itemData['price']}'),
                          Text('Type: ${itemData['type']}'),
                          Text('Bid: ${itemData['bid']}'),
                          Text('Latitude: ${itemData['latitude']}'),
                          Text('Longitude: ${itemData['longitude']}'),
                          Text('Photo: ${itemData['photo']}'),
                          Text('Rate: ${itemData['rate']}'),
                          Text('Recent Work: ${itemData['recent work']}'),
                          Text('Request: ${itemData['request']}'),
                          Text('Trending: ${itemData['trending']}'),
                        ],
                      ),
                    ),
                    Image.network(itemData['photo']),
                  ],
                ),
              );
            },
          );
  }
}
