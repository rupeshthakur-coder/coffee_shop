import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        elevation: 0,
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: user == null
          ? const Center(child: Text('Please login to view your cart'))
          : SafeArea(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('cart')
                    .where('userId', isEqualTo: user.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  // Debug prints for Firebase data
                  print('User ID in query: ${user.uid}');
                  print('Connection State: ${snapshot.connectionState}');
                  print('Has Error: ${snapshot.hasError}');
                  if (snapshot.hasError) {
                    print('Error Details: ${snapshot.error}');
                    print('Error Stack Trace: ${snapshot.stackTrace}');
                  }
                  print('Data exists: ${snapshot.hasData}');
                  print('Number of documents: ${snapshot.data?.docs.length}');

                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.data?.docs.isEmpty ?? true) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_bag_outlined,
                              size: 100, color: Colors.brown[200]),
                          const SizedBox(height: 16),
                          Text(
                            'Your cart is empty',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Colors.brown[700],
                                ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Continue Shopping'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Calculate total price and quantity
                  double totalPrice = 0;
                  int totalItems = 0;
                  for (var doc in snapshot.data!.docs) {
                    final int quantity = (doc['quantity'] as num? ?? 1).toInt();
                    totalItems += quantity;
                    final double itemPrice =
                        (doc.data() as Map<String, dynamic>)
                                .containsKey('amount')
                            ? (doc['amount'] as num).toDouble()
                            : 0.0;
                    totalPrice += itemPrice * quantity;
                  }

                  return Stack(
                    children: [
                      // Main cart list
                      ListView.builder(
                        padding: const EdgeInsets.only(
                            bottom: 120), // Add padding for bottom summary
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final item = snapshot.data!.docs[index];
                          final quantity = item['quantity'] ?? 1;

                          return Dismissible(
                            key: Key(item.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red[100],
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              child:
                                  const Icon(Icons.delete, color: Colors.red),
                            ),
                            onDismissed: (direction) async {
                              // Delete item from Firebase
                              await FirebaseFirestore.instance
                                  .collection('cart')
                                  .doc(item.id)
                                  .delete();

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Item removed from cart'),
                                  backgroundColor: Colors.brown,
                                ),
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.brown[100]!),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    // Product image
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        item['image'] ?? '',
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            width: 80,
                                            height: 80,
                                            color: Colors.brown[50],
                                            child: const Icon(Icons.coffee,
                                                color: Colors.brown),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Product details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['name'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '\$${((item.data() as Map<String, dynamic>).containsKey('amount') ? (item['amount'] as num).toDouble() : 0.0).toString()}',
                                            style: TextStyle(
                                              color: Colors.brown[700],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                    Icons.remove_circle_outline,
                                                    color: Colors.brown[700]),
                                                onPressed: () async {
                                                  if (quantity > 1) {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('cart')
                                                        .doc(item.id)
                                                        .update({
                                                      'quantity': quantity - 1
                                                    });
                                                  }
                                                },
                                              ),
                                              Text('$quantity'),
                                              IconButton(
                                                icon: Icon(
                                                    Icons.add_circle_outline,
                                                    color: Colors.brown[700]),
                                                onPressed: () async {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('cart')
                                                      .doc(item.id)
                                                      .update({
                                                    'quantity': quantity + 1
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      // Bottom summary and checkout button
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total Items: $totalItems',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '\$${totalPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.brown,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    // TODO: Implement checkout
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.brown,
                                    minimumSize: const Size.fromHeight(50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Checkout',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }
}
