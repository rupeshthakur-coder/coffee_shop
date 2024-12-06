import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_shop/features/product_details/data/repositories/product_repository_impl.dart';
import 'package:coffee_shop/features/product_details/domain/usecases/get_product_details.dart';
import 'package:coffee_shop/features/product_details/presentation/bloc/product_details_bloc.dart';
import 'package:coffee_shop/features/product_details/presentation/pages/product_details_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage<HomePageState> extends StatefulWidget {
  const HomePage({super.key});

  @override
  createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Hot Coffee',
    'Cold Coffee',
    'Specials'
  ];

  Future<void> _addToFavorites(Map<String, dynamic> item) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please login to add items to favorites')),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('favorites').add({
        'userId': user.uid, // Using actual user UID from Firebase Auth
        'itemId': item['id'],
        'timestamp': FieldValue.serverTimestamp(),
        ...item, // Include all item details
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to favorites')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding to favorites: $e')),
      );
    }
  }

  Future<void> _addToCart(Map<String, dynamic> item) async {
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

        await FirebaseFirestore.instance.collection('cart').doc(docId).update({
          'quantity': currentQuantity + 1,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        // Item doesn't exist, create new document
        await FirebaseFirestore.instance.collection('cart').add({
          'userId': user.uid,
          'itemId': item['id'],
          'name': item['name'], // Ensure name is stored
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _searchQuery = '';
            _searchController.clear();
          });
        },
        child: Column(
          children: [
            _buildSearchBar(),
            _buildCategoryList(),
            Expanded(child: _buildProductList()),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return Container(
      height: 50.h,
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategory == _categories[index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: FilterChip(
              selected: isSelected,
              label: Text(
                _categories[index],
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isSelected ? Colors.white : Colors.brown,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.brown,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: Colors.grey[100],
              selectedColor: Colors.brown,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = _categories[index];
                });
              },
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(fontSize: 14.sp),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'Find your perfect coffee...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: Colors.brown[400]),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.brown[400]),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('items').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final items = snapshot.data?.docs ?? [];
        final filteredItems = items.where((item) {
          final data = item.data() as Map<String, dynamic>;
          final itemName = data['name']?.toString() ?? '';
          final itemCategory = data['category']?.toString() ?? 'All';

          bool matchesSearch = itemName.toLowerCase().contains(_searchQuery);
          bool matchesCategory =
              _selectedCategory == 'All' || itemCategory == _selectedCategory;

          return matchesSearch && matchesCategory;
        }).toList();

        if (filteredItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No items found'),
                if (_searchQuery.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
                    child: const Text('Clear Search'),
                  ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: EdgeInsets.all(8.w),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
          ),
          itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            final item = filteredItems[index].data() as Map<String, dynamic>;
            return Card(
              elevation: 4,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: GestureDetector(
                onTap: () {
                  final productId = filteredItems[index].id;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (context) => ProductDetailsBloc(
                          getProductDetails: GetProductDetails(
                            ProductRepositoryImpl(FirebaseFirestore.instance),
                          ),
                        ),
                        child: ProductDetailsPage(productId: productId),
                      ),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          height: 140.h,
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20.r)),
                            child: Image.network(
                              item['image']?.toString() ?? '',
                              fit: BoxFit.fill,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8.h,
                          right: 8.w,
                          child: CircleAvatar(
                            radius: 16.r,
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: Icon(
                                Icons.favorite_border,
                                color: Colors.brown,
                                size: 18.sp,
                              ),
                              onPressed: () => _addToFavorites(item),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name']?.toString() ?? 'Unnamed Product',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.brown[50],
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              'Coffee: ${item['coffee']?.toString() ?? '0'}% | Milk: ${item['milk']?.toString() ?? '0'}%',
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: Colors.brown[700],
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$${item['amount']?.toString() ?? '0.00'}',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown[700],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.brown,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.add_shopping_cart,
                                    color: Colors.white,
                                    size: 16.sp,
                                  ),
                                  onPressed: () => _addToCart(item),
                                  padding: EdgeInsets.all(6.w),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
