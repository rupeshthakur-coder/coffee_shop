// admin_dashboard_page.dart
//adminpassword123
//admin@example.com

import 'package:flutter/material.dart';
import 'package:coffee_shop/features/admin/admin_dashboard/add_product_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Coffee Shop Admin Dashboard',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF3C2A21),
          elevation: 0,
        ),
        backgroundColor: const Color(0xFFE5E5E5),
        body: GridView.count(
          padding: const EdgeInsets.all(20.0),
          crossAxisCount: 2,
          crossAxisSpacing: 20.0,
          mainAxisSpacing: 20.0,
          children: [
            _buildDashboardCard(
              context,
              icon: Icons.point_of_sale,
              title: 'Sales Overview',
              onTap: () {
                // Navigate to sales overview
                // TODO: Implement sales overview page
              },
            ),
            _buildDashboardCard(
              context,
              icon: Icons.add_box,
              title: 'Add Products',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddProductPage()),
                );
              },
            ),
            _buildDashboardCard(
              context,
              icon: Icons.inventory,
              title: 'Inventory Management',
              onTap: () {
                // TODO: Navigate to inventory management page
              },
            ),
            _buildDashboardCard(
              context,
              icon: Icons.people,
              title: 'Staff Management',
              onTap: () {
                // TODO: Navigate to staff management page
              },
            ),
            _buildDashboardCard(
              context,
              icon: Icons.assessment,
              title: 'Reports',
              onTap: () {
                // TODO: Navigate to reports page
              },
            ),
            _buildDashboardCard(
              context,
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {
                // TODO: Navigate to settings page
              },
            ),
            _buildDashboardCard(
              context,
              icon: Icons.notifications,
              title: 'Notifications',
              onTap: () {
                // TODO: Navigate to notifications page
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40.0,
                color: const Color(0xFF3C2A21),
              ),
              const SizedBox(height: 12.0),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3C2A21),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
