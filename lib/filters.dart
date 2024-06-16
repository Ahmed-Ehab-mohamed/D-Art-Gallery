import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart' as Geolocator;
import 'package:firebase_core/firebase_core.dart';
import 'package:location/location.dart';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Filter Page',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: FilterPage(),
    );
  }
}

class FilterPage extends StatefulWidget {
  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  bool _priceExpanded = false;
  String? _minPrice;
  String? _maxPrice;
  LocationData? _userLocation;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      Geolocator.Position position =
          await Geolocator.Geolocator.getCurrentPosition(
        desiredAccuracy: Geolocator.LocationAccuracy.high,
      );
      _userLocation = LocationData.fromMap({
        "latitude": position.latitude,
        "longitude": position.longitude,
      });
    } catch (e) {
      print('Error getting location: $e');
      _userLocation = LocationData.fromMap({
        "latitude": 0,
        "longitude": 0,
      });
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_userLocation == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Color(0xFFEDE6D5),
      appBar: AppBar(
        backgroundColor: Color(0xFF6E5F4B),
        title: Text('Filters'),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () {
              // Handle close button press
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                color: Color(0xFFB4A597),
                child: Column(
                  children: [
                    ListTile(
                      title: Text('Price'),
                      trailing: IconButton(
                        icon: Icon(
                          _priceExpanded
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _priceExpanded = !_priceExpanded;
                          });
                        },
                      ),
                    ),
                    Visibility(
                      visible: _priceExpanded,
                      child: Column(
                        children: [
                          TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Min Price',
                              hintText: 'Enter Min Price',
                            ),
                            onChanged: (value) {
                              setState(() {
                                _minPrice = value;
                              });
                            },
                          ),
                          TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Max Price',
                              hintText: 'Enter Max Price',
                            ),
                            onChanged: (value) {
                              setState(() {
                                _maxPrice = value;
                              });
                            },
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FilteredPaintings(
                                    minPrice: _minPrice,
                                    maxPrice: _maxPrice,
                                    userLocation: _userLocation!,
                                  ),
                                ),
                              );
                            },
                            child: Text('Filter'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FilteredPaintings extends StatelessWidget {
  final String? minPrice;
  final String? maxPrice;
  final LocationData userLocation;

  const FilteredPaintings({
    Key? key,
    required this.minPrice,
    required this.maxPrice,
    required this.userLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filtered Paintings'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Paintings')
            .where('price', isGreaterThanOrEqualTo: minPrice)
            .where('price', isLessThanOrEqualTo: maxPrice)
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
              final photo = painting['photo'] ?? '';
              final artist = painting['artist'] ?? '';
              final price = painting['price'] ?? '';
              final name = painting['name'] ?? '';
              final distance = _calculateDistance(
                painting['latitude'] ?? 0.0,
                painting['longitude'] ?? 0.0,
                userLocation.latitude ?? 0.0,
                userLocation.longitude ?? 0.0,
              );
              return ListTile(
                leading: Image.network(photo),
                title: Text(name),
                subtitle: Text(
                    'Artist: $artist\nPrice: $price\nDistance: $distance km'),
              );
            },
          );
        },
      ),
    );
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295;
    final c = cos;
    final a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}
