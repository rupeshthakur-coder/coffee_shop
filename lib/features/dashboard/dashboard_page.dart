import 'package:coffee_shop/features/cart/bloc/cart_bloc.dart';
import 'package:coffee_shop/features/dashboard/pages/todays_special_page.dart';
import 'package:coffee_shop/features/home/home_page.dart';
import 'package:coffee_shop/features/profile/profile_page.dart';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  // List of pages to show
  final List<Widget> _pages = [
    const HomePage(),
    const TodaySpecialPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          'Coffee Shop',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.brown,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Badge(
              backgroundColor: Colors.brown,
              // label: Text('$_notificationCount'),
              child: Icon(
                Icons.notifications_outlined,
                color: Colors.brown.shade700,
              ),
            ),
            onPressed: () {
              // Handle notification action
            },
          ),
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              int totalQuantity = 0;
              if (state is CartLoaded) {
                // Sum up quantities of all items
                totalQuantity =
                    state.items.fold(0, (sum, item) => sum + item.quantity);
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
                onPressed: () => Navigator.pushNamed(context, '/cart'),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          selectedItemColor: Colors.brown,
          unselectedItemColor: Colors.grey,
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star_outline),
              activeIcon: Icon(Icons.star),
              label: "Today's Special",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
