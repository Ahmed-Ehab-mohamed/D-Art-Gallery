import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:math';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Run the app
  runApp(MyApp());
}

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
        .where('artist', isEqualTo: 'Nour') // Filter by artist name
        .where('price', isLessThanOrEqualTo: '5000') // Filter by maximum price
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
        : RecentPaintingList2(
            artistName: 'Nour',
            containerWidth: 200, // Set a value for containerWidth
            containerHeight: 200, // Set a value for containerHeight
            minPrice: 0, // Set a value for minPrice
            maxPrice: 5000, // Set a value for maxPrice
          );
  }
}

class RecentPaintingList2 extends StatelessWidget {
  final String artistName;
  final double containerWidth;
  final double containerHeight;
  final double minPrice;
  final double maxPrice;

  const RecentPaintingList2({
    required this.artistName,
    required this.containerWidth,
    required this.containerHeight,
    required this.minPrice,
    required this.maxPrice,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Paintings')
          .where('artist', isEqualTo: artistName)
          .where('price', isGreaterThan: minPrice.toString())
          .where('price', isLessThanOrEqualTo: maxPrice.toString())
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

class FilterPage extends StatefulWidget {
  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();
  final TextEditingController typeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filter Paintings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: minPriceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Minimum Price'),
            ),
            TextField(
              controller: maxPriceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Maximum Price'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecentPaintingList2(
                      artistName: 'Nour',
                      minPrice: double.parse(minPriceController.text),
                      maxPrice: double.parse(maxPriceController.text),
                      containerWidth: 200, // Set a value for containerWidth
                      containerHeight: 200,
                    ),
                  ),
                );
              },
              child: Text('Filter'),
            ),
          ],
        ),
      ),
    );
  }
}
