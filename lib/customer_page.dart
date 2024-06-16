import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'customer_adminpage.dart';
import 'editprofilepage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'paymob_manager.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'paymob_manager.dart';
import 'chat_screen.dart';

class CustomerHomePage extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const CustomerHomePage({Key? key, this.userData}) : super(key: key);

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

    String? userId = userData?['uid'];

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
                  builder: (context) => CustomerProfilePage(userData: userData),
                ),
              );
            },
            child: CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: userData?['photo'] != null
                  ? NetworkImage(userData!['photo'])
                  : null,
              radius: avatarRadius,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                userData?['name'] ?? 'User',
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
                    builder: (context) => AuctionOptionsScreen(userId: userId),
                  ),
                );
              },
              child: Image.asset(
                'assets/images/auction.png',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                if (userId != null) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => CartSideContainer(userId: userId),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('User ID is not provided.')),
                  );
                }
              },
              child: Icon(Icons.shopping_cart),
            ),
            SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                if (userId != null) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) =>
                        FavoritesSideContainer(userId: userId),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('User ID is not provided.')),
                  );
                }
              },
              child: Icon(Icons.favorite),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PaintingListScreen(
              userData: userData,
              containerWidth: containerWidth,
              containerHeight: containerHeight,
            ),
          ),
        ],
      ),
    );
  }
}

class CartSideContainer extends StatelessWidget {
  final String? userId;

  const CartSideContainer({Key? key, this.userId}) : super(key: key);

  Future<void> removeFromCart(String itemId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('Cart').doc(itemId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed from cart successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove from cart: $e')),
      );
    }
  }

  void _payNow(BuildContext context, double totalPrice) async {
    try {
      // Round totalPrice to the nearest integer
      final roundedTotalPrice = totalPrice.round();

      print(
          "Rounded Total Price: $roundedTotalPrice"); // Print the rounded total price

      final paymentKey =
          await PaymobManager().getPaymentKey(roundedTotalPrice.toInt(), "EGP");
      final paymentUrl =
          "https://accept.paymob.com/api/acceptance/iframes/850891?payment_token=$paymentKey";
      await launchUrl(Uri.parse(paymentUrl));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: Failed to initiate payment'),
        ),
      );
      print("Payment Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      // Handle scenario when userId is not provided
      return Center(child: Text('User ID is not provided.'));
    }

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Cart',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Cart')
                  .where('userId', isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var cartItems = snapshot.data!.docs;

                if (cartItems.isEmpty) {
                  return Center(child: Text('Your cart is empty.'));
                }

                // Calculate the total price
                double totalPrice = 0.0;
                for (var doc in cartItems) {
                  var item = doc.data() as Map<String, dynamic>;
                  var price = item['price'] ?? '0';
                  totalPrice += double.tryParse(price.toString()) ?? 0.0;
                }

                return Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        var item =
                            cartItems[index].data() as Map<String, dynamic>;
                        var itemId = cartItems[index].id;

                        // Ensure values are not null
                        var artist = item['artist'] ?? 'Unknown Artist';
                        var name = item['name'] ?? 'Unnamed Product';
                        var photo = item['photo'] ?? '';
                        var price = item['price'] ?? '0';

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 10.0),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(10.0),
                            leading: photo.isNotEmpty
                                ? Image.network(photo,
                                    width: 50, height: 50, fit: BoxFit.cover)
                                : Icon(Icons.image, size: 50),
                            title: Text(name,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Artist: $artist\nPrice: \$$price'),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                removeFromCart(itemId, context);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      'Total Price: \$${totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle payment action
                          _payNow(context, totalPrice);
                        },
                        child: Text('Pay'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class FavoritesSideContainer extends StatelessWidget {
  final String? userId;

  const FavoritesSideContainer({Key? key, this.userId}) : super(key: key);

  Future<void> removeFromFavorites(String itemId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('Favorites')
          .doc(itemId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed from favorites successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove from favorites: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      // Handle scenario when userId is not provided
      return Center(child: Text('User ID is not provided.'));
    }

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Favorites',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Favorites')
                  .where('userId', isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var favoriteItems = snapshot.data!.docs;

                if (favoriteItems.isEmpty) {
                  return Center(child: Text('Your favorites list is empty.'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: favoriteItems.length,
                  itemBuilder: (context, index) {
                    var item =
                        favoriteItems[index].data() as Map<String, dynamic>;
                    var itemId = favoriteItems[index].id;

                    // Ensure values are not null
                    var artist = item['artist'] ?? 'Unknown Artist';
                    var name = item['name'] ?? 'Unnamed Product';
                    var photo = item['photo'] ?? '';
                    var price = item['price'] ?? '0';

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(10.0),
                        leading: photo.isNotEmpty
                            ? Image.network(photo,
                                width: 50, height: 50, fit: BoxFit.cover)
                            : Icon(Icons.image, size: 50),
                        title: Text(name,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Artist: $artist\nPrice: \$$price'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            removeFromFavorites(itemId, context);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AuctionOptionsScreen extends StatelessWidget {
  final String? userId;
  const AuctionOptionsScreen({Key? key, this.userId}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auction Options'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              // Navigate to Live Auctions screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LiveAuctionsScreen(userId: userId),
                ),
              );
            },
            child: Text('Live Auctions'),
          ),
          ElevatedButton(
            onPressed: () {
              // Navigate to All Bids screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllBidsScreen(userId: userId),
                ),
              );
            },
            child: Text('All Bids'),
          ),
        ],
      ),
    );
  }
}

class AllBidsScreen extends StatelessWidget {
  final String? userId;

  AllBidsScreen({Key? key, this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Bids'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('bids').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No bids available'));
          }

          Map<String, dynamic> highestBids = {};

          for (var doc in snapshot.data!.docs) {
            final bid = doc.data() as Map<String, dynamic>;
            final paintingName = bid['painting_name'];
            final bidAmount = bid['bid_amount'];

            if (!highestBids.containsKey(paintingName) ||
                bidAmount > highestBids[paintingName]) {
              highestBids[paintingName] = bidAmount;
            }
          }

          return ListView.builder(
            itemCount: highestBids.length,
            itemBuilder: (context, index) {
              final paintingName = highestBids.keys.elementAt(index);
              final highestBid = highestBids[paintingName];
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('bids')
                    .where('painting_name', isEqualTo: paintingName)
                    .where('bid_amount', isEqualTo: highestBid)
                    .get()
                    .then((value) => value.docs.first),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final bid = snapshot.data!.data() as Map<String, dynamic>;
                  final photoUrl = bid['photoUrl'] ?? '';
                  final bidUid = bid['uid'];

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
                        Image.network(
                          photoUrl,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          paintingName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text('Bid Amount: \$${highestBid.toString()}'),
                        if (bidUid == userId)
                          ElevatedButton(
                            onPressed: () {
                              _payNow(context, paintingName, highestBid);
                            },
                            child: Text('Pay Now'),
                          ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              _showBidDetailsPopup(context, bid);
                            },
                            child: Text('View Bid'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _payNow(
      BuildContext context, String paintingName, double bidAmount) async {
    try {
      final roundedBidAmount = bidAmount.round();
      final paymentKey =
          await PaymobManager().getPaymentKey(roundedBidAmount.toInt(), "EGP");
      final paymentUrl =
          "https://accept.paymob.com/api/acceptance/iframes/850891?payment_token=$paymentKey";
      await launchUrl(Uri.parse(paymentUrl));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Failed to initiate payment')),
      );
      print("Payment Error: $e");
    }
  }

  void _showBidDetailsPopup(BuildContext context, Map<String, dynamic> bid) {
    final String paintingName = bid['painting_name'];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BidDetailsPopup(paintingName: paintingName);
      },
    );
  }
}

void _payNow(
    BuildContext context, String paintingName, double bidAmount) async {
  try {
    // Round bidAmount to the nearest integer
    final roundedBidAmount = bidAmount.round();

    print(
        "Rounded Bid Amount: $roundedBidAmount"); // Print the rounded bid amount

    final paymentKey =
        await PaymobManager().getPaymentKey(roundedBidAmount.toInt(), "EGP");
    final paymentUrl =
        "https://accept.paymob.com/api/acceptance/iframes/850891?payment_token=$paymentKey";
    await launchUrl(Uri.parse(paymentUrl));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: Failed to initiate payment'),
      ),
    );
    print("Payment Error: $e");
  }
}

void _showBidDetailsPopup(BuildContext context, Map<String, dynamic> bid) {
  final String paintingName = bid['painting_name'];
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return BidDetailsPopup(paintingName: paintingName);
    },
  );
}

class BidDetailsPopup extends StatelessWidget {
  final String paintingName;

  const BidDetailsPopup({Key? key, required this.paintingName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bids for $paintingName',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 16),
            FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('bids')
                  .where('painting_name', isEqualTo: paintingName)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No bids available'));
                }

                // Find the highest bid
                final highestBid = snapshot.data!.docs
                    .map((doc) => doc.data() as Map<String, dynamic>)
                    .reduce((curr, next) =>
                        curr['bid_amount'] > next['bid_amount'] ? curr : next);

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final bid = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;
                    final bidAmount = bid['bid_amount'];
                    final uid = bid['uid'];
                    return ListTile(
                      title: Text('Bid Amount: \$${bidAmount.toString()}'),
                      subtitle: Text('User UID: $uid'),
                      trailing: uid == FirebaseAuth.instance.currentUser!.uid &&
                              bid == highestBid
                          ? ElevatedButton(
                              onPressed: () {
                                // Handle 'Pay Now' button press
                                _payNow(context, paintingName, bidAmount);
                              },
                              child: Text('Pay Now'),
                            )
                          : null,
                    );
                  },
                );
              },
            ),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _payNow(
      BuildContext context, String paintingName, double bidAmount) async {
    try {
      // Round bidAmount to the nearest integer
      final roundedBidAmount = bidAmount.round();

      print(
          "Rounded Bid Amount: $roundedBidAmount"); // Print the rounded bid amount

      final paymentKey =
          await PaymobManager().getPaymentKey(roundedBidAmount.toInt(), "EGP");
      final paymentUrl =
          "https://accept.paymob.com/api/acceptance/iframes/850891?payment_token=$paymentKey";
      await launchUrl(Uri.parse(paymentUrl));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: Failed to initiate payment'),
        ),
      );
      print("Payment Error: $e");
    }
  }
}

class LiveAuctionsScreen extends StatelessWidget {
  final String? userId;

  LiveAuctionsScreen({Key? key, this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Auctions'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('bid').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No live auctions available'));
          }

          final now = DateTime.now();
          final liveAuctions = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['timestamp'] == null || data['duration'] == null) {
              return false;
            }
            final timestamp = (data['timestamp'] as Timestamp).toDate();
            final duration = data['duration'] as int;
            return now.isBefore(timestamp.add(Duration(minutes: duration)));
          }).toList();

          if (liveAuctions.isEmpty) {
            return Center(child: Text('No live auctions available'));
          }

          return ListView.builder(
            itemCount: liveAuctions.length,
            itemBuilder: (context, index) {
              final auction =
                  liveAuctions[index].data() as Map<String, dynamic>;
              final photoUrl = auction['photoUrl'] ?? '';
              final name = auction['name'] ?? '';
              final startingPrice = auction['startingPrice']?.toString() ?? '';

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
                    Image.network(
                      photoUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      name,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      'Starting Price: \$$startingPrice',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle bid action
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BidPayScreen(bidData: auction),
                            ),
                          );
                        },
                        child: Text('Bid'),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class BidPayScreen extends StatelessWidget {
  final Map<String, dynamic> bidData;
  final TextEditingController _bidAmountController = TextEditingController();

  BidPayScreen({Key? key, required this.bidData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name = bidData['name'] ?? '';
    final photoUrl = bidData['photoUrl'] ?? '';
    final startingPrice = bidData['startingPrice'] != null
        ? bidData['startingPrice'].toString()
        : ''; // Ensure startingPrice is a string

    return Scaffold(
      appBar: AppBar(
        title: Text('Pay for Bid'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              photoUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 16.0),
            Text(
              name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(height: 16.0),
            Text(
              'Starting Price: \$$startingPrice',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 32.0),
            TextField(
              controller: _bidAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter your bid amount',
              ),
            ),
            SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('No user is currently signed in.'),
                      ),
                    );
                    return;
                  }

                  final bidAmount = _bidAmountController.text;
                  final startingPriceInt = double.tryParse(startingPrice) ?? 0;
                  final bidAmountInt = double.tryParse(bidAmount) ?? 0;
                  final bidDetails = {
                    'painting_name': name,
                    'photoUrl': photoUrl,
                    'bid_amount': bidAmountInt,
                    'starting_price': startingPriceInt,
                    'uid': user.uid,
                  };

                  if (bidAmount.isNotEmpty) {
                    if (bidAmountInt >= startingPriceInt) {
                      FirebaseFirestore.instance
                          .collection('bids')
                          .add(bidDetails);
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Bid amount must be greater than or equal to the starting price.'),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter your bid amount.'),
                      ),
                    );
                  }
                },
                child: Text('Bid'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaintingListScreen extends StatelessWidget {
  final double containerWidth;
  final double containerHeight;
  final Map<String, dynamic>? userData;

  const PaintingListScreen({
    required this.containerWidth,
    required this.containerHeight,
    required this.userData,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Paintings').snapshots(),
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
                  GestureDetector(
                    onTap: () async {
                      final artistData = await fetchArtistData(artist);
                      if (artistData != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserProfilePage(
                              userData: artistData,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Artist not found')),
                        );
                      }
                    },
                    child: Text(
                      'Artist: $artist',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors
                            .blue, // Optional: Change color to indicate a link
                      ),
                    ),
                  ),
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
                  SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          addFavorite(userData?['uid'], name, artist, price,
                              context, photo);
                        },
                        icon: Icon(Icons.favorite_border),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          addToCart(userData?['uid'], name, artist, price,
                              context, photo);
                        },
                        child: Text('Add'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>?> fetchArtistData(String artistName) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isEqualTo: artistName)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error fetching artist data: $e');
    }
    return null;
  }

  Future<void> addFavorite(String? userId, String name, String artist,
      String price, BuildContext context, String photo) async {
    try {
      await FirebaseFirestore.instance.collection('Favorites').add({
        'userId': userId,
        'name': name,
        'artist': artist,
        'price': price,
        'photo': photo,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added to favorites successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to favorites: $e')),
      );
    }
  }

  Future<void> addToCart(String? userId, String name, String artist,
      String price, BuildContext context, String photo) async {
    try {
      await FirebaseFirestore.instance.collection('Cart').add({
        'userId': userId,
        'name': name,
        'artist': artist,
        'price': price,
        'photo': photo,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added to cart successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to cart: $e')),
      );
    }
  }
}

class CustomerProfilePage extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const CustomerProfilePage({Key? key, this.userData}) : super(key: key);

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
                      'Transactions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${userData?['transactions'] ?? 0}',
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
              child: Text('Edit'),
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
                            CustomerProfilePage(userData: userData),
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
                            CustomerProfilePage2(userData: userData),
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
                            CustomerProfilePage3(userData: userData),
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
            RecentPaintingList4(
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

class RecentPaintingList4 extends StatelessWidget {
  final String artistName;
  final double containerWidth;
  final double containerHeight;

  const RecentPaintingList4({
    required this.artistName,
    required this.containerWidth,
    required this.containerHeight,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Bought')
          .where('buyer', isEqualTo: artistName)
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
            final artist = painting['buyer'] ?? '';

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
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class CustomerProfilePage2 extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const CustomerProfilePage2({Key? key, this.userData}) : super(key: key);

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
        title: Text('Recent Request'),
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
                      'Transactions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${userData?['transactions'] ?? 0}',
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
              child: Text('Edit'),
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
                            CustomerProfilePage(userData: userData),
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
                            CustomerProfilePage2(userData: userData),
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
                            CustomerProfilePage3(userData: userData),
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
              'Recent Request',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 10),
            RecentPaintingList5(
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

class RecentPaintingList5 extends StatelessWidget {
  final String artistName;
  final double containerWidth;
  final double containerHeight;

  const RecentPaintingList5({
    required this.artistName,
    required this.containerWidth,
    required this.containerHeight,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Bought')
          .where('buyer', isEqualTo: artistName)
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
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: paintings.length,
          itemBuilder: (context, index) {
            final painting = paintings[index].data() as Map<String, dynamic>;

            // Safely parse fields with appropriate type checking
            final photo = painting['photo'] ?? '';
            final artist = painting['buyer'] ?? '';

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
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class CustomerProfilePage3 extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const CustomerProfilePage3({Key? key, this.userData}) : super(key: key);

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
                      'Transactions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${userData?['transactions'] ?? 0}',
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
              child: Text('Edit'),
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
                            CustomerProfilePage(userData: userData),
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
                            CustomerProfilePage2(userData: userData),
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
                            CustomerProfilePage3(userData: userData),
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
            RecentPaintingList6(
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

class RecentPaintingList6 extends StatelessWidget {
  final String artistName;
  final double containerWidth;
  final double containerHeight;

  const RecentPaintingList6({
    required this.artistName,
    required this.containerWidth,
    required this.containerHeight,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Bought')
          .where('buyer', isEqualTo: artistName)
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
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: paintings.length,
          itemBuilder: (context, index) {
            final painting = paintings[index].data() as Map<String, dynamic>;

            // Safely parse fields with appropriate type checking
            final photo = painting['photo'] ?? '';
            final artist = painting['buyer'] ?? '';

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
                ],
              ),
            );
          },
        );
      },
    );
  }
}
