import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_shop/features/user/cart/bloc/cart_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_details_bloc.dart';

class ProductDetailsPage extends StatelessWidget {
  final String productId;

  const ProductDetailsPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    context.read<ProductDetailsBloc>().add(LoadProductDetails(productId));

    Future<void> addToCart(Map<String, dynamic> item) async {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please login to add items to cart')),
          );
          return;
        }

        // Check if item already exists in user's cart using both userId and the complete item name
        final querySnapshot = await FirebaseFirestore.instance
            .collection('cart')
            .where('userId', isEqualTo: user.uid)
            .where('itemId', isEqualTo: item['id'])
            .where('name', isEqualTo: item['name']) // Add name check
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Item exists, update quantity
          final docId = querySnapshot.docs.first.id;
          final currentQuantity =
              querySnapshot.docs.first.data()['quantity'] ?? 0;

          await FirebaseFirestore.instance
              .collection('cart')
              .doc(docId)
              .update({
            'quantity': currentQuantity + 1,
            'timestamp': FieldValue.serverTimestamp(),
          });
        } else {
          // Item doesn't exist, create new document
          await FirebaseFirestore.instance.collection('cart').add({
            'userId': user.uid,
            'itemId': item['id'],
            'name': item['name'],
            'amount': item['price'],
            'quantity': 1,
            'timestamp': FieldValue.serverTimestamp(),
            ...item,
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to cart')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding to cart: $e')),
        );
      }
    }

    return Scaffold(
      body: BlocBuilder<ProductDetailsBloc, ProductDetailsState>(
        builder: (context, state) {
          if (state is ProductDetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductDetailsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<ProductDetailsBloc>()
                          .add(LoadProductDetails(productId));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ProductDetailsLoaded) {
            final product = state.product;
            return Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: BlocBuilder<CartBloc, CartState>(
                      builder: (context, state) {
                        int totalQuantity = 0;
                        if (state is CartLoaded) {
                          // Sum up quantities of all items
                          totalQuantity = state.items
                              .fold(0, (sum, item) => sum + item.quantity);
                        }
                        return IconButton(
                          icon: Badge(
                            backgroundColor: Colors.brown,
                            label: Text('$totalQuantity'),
                            child: Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.brown.shade700,
                            ),
                          ),
                          onPressed: () =>
                              Navigator.pushNamed(context, '/cart'),
                        );
                      },
                    ),
                  ),
                ],
              ),
              body: Column(
                children: [
                  // Hero Image with Gradient Overlay (Fixed)
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: Image.network(
                          product.image,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Scrollable Content
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(32)),
                      ),
                      transform: Matrix4.translationValues(0, -24, 0),
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Text(
                                      '\$${product.price.toStringAsFixed(2)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            color: Colors.brown,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: product.stock > 0
                                            ? Colors.green.shade50
                                            : Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        product.stock > 0
                                            ? 'In Stock'
                                            : 'Out of Stock',
                                        style: TextStyle(
                                          color: product.stock > 0
                                              ? Colors.green.shade700
                                              : Colors.red.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Description
                            Text(
                              product.description,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Product Details
                            const Text(
                              'Product Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow('Type', product.type),
                            _buildDetailRow('Category', product.category),
                            _buildDetailRow('Origin', product.origin),
                            _buildDetailRow('Roast Level', product.roastLevel),

                            const Divider(height: 32),

                            // Recipe
                            const Text(
                              'Recipe',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow('Coffee', '${product.coffee}g'),
                            _buildDetailRow('Water', '${product.water}ml'),
                            _buildDetailRow('Milk', '${product.milk}ml'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => addToCart({
                            'id': product.id,
                            'name': product.name,
                            'price': product.price,
                            'image': product.image,
                          }),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown.shade50,
                            foregroundColor: Colors.brown,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Add to Cart'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {/* Buy now functionality */},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Buy Now'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
