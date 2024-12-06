import 'package:coffee_shop/features/admin/admin_dashboard/admin_dashbard_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isEditing = false;
  int _avatarTapCount = 0;
  final _adminEmailController = TextEditingController();
  final _adminPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userData.exists) {
        setState(() {
          _nameController.text = userData.data()?['name'] ?? '';
          _emailController.text = userData.data()?['email'] ?? '';
          _phoneController.text = userData.data()?['phone'] ?? '';
          _addressController.text = userData.data()?['address'] ?? '';
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        setState(() {
          _isEditing = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context)
            .pushReplacementNamed('/login'); // Adjust this route name as needed
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to log out')),
        );
      }
    }
  }

  Future<void> _authenticateAdmin() async {
    print("Starting admin authentication"); // Debug print
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Admin Authentication'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _adminEmailController,
              decoration: const InputDecoration(
                labelText: 'Admin Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _adminPasswordController,
              decoration: const InputDecoration(
                labelText: 'Admin Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              print("Login button pressed"); // Debug print

              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                print("Checking admin credentials"); // Debug print
                // Check admin credentials in Firestore
                final adminDoc = await FirebaseFirestore.instance
                    .collection('Admin')
                    .doc(_adminEmailController.text)
                    .get();

                print("Admin doc exists: ${adminDoc.exists}"); // Debug print
                print(
                    "Admin password match: ${adminDoc.data()?['password'] == _adminPasswordController.text}"); // Debug print

                if (adminDoc.exists &&
                    adminDoc.data()?['password'] ==
                        _adminPasswordController.text) {
                  print("Authentication successful"); // Debug print

                  // Close loading and auth dialogs
                  Navigator.pop(context); // Close loading
                  Navigator.pop(context); // Close auth dialog

                  // Navigate to admin page
                  if (mounted) {
                    print("Attempting navigation to admin page"); // Debug print
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminDashboardPage(),
                      ),
                    );
                    print("Navigation completed"); // Debug print
                  }
                } else {
                  print("Invalid credentials"); // Debug print
                  // Close loading dialog
                  Navigator.pop(context);

                  // Show error
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid admin credentials')),
                  );
                }
              } catch (e) {
                print("Error occurred: $e"); // Debug print
                // Close loading dialog
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  void _handleAvatarTap() {
    setState(() {
      _avatarTapCount++;
      print('Avatar tapped $_avatarTapCount times'); // Debug print

      // Show a subtle feedback
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tap count: $_avatarTapCount'),
          duration: const Duration(milliseconds: 500),
          backgroundColor: Colors.brown,
        ),
      );

      if (_avatarTapCount >= 5) {
        _avatarTapCount = 0; // Reset counter
        print('Showing admin authentication dialog'); // Debug print
        _authenticateAdmin();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header with Edit Icon
            Stack(
              children: [
                Container(
                  color: Colors.brown,
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Center(
                    child: Column(
                      children: [
                        InkWell(
                          onTap: _handleAvatarTap,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: const CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.person,
                                  size: 50, color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _nameController.text,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  top: 16,
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _isEditing = true;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Form Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Theme.of(context).cardColor,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildEditableField(
                              controller: _nameController,
                              label: 'Name',
                              icon: Icons.person_outline,
                              validator: (value) => value?.isEmpty ?? true
                                  ? 'Please enter your name'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            _buildEditableField(
                              controller: _emailController,
                              label: 'Email',
                              icon: Icons.email_outlined,
                              validator: (value) => value?.isEmpty ?? true
                                  ? 'Please enter your email'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            _buildEditableField(
                              controller: _phoneController,
                              label: 'Phone',
                              icon: Icons.phone_outlined,
                              validator: (value) => value?.isEmpty ?? true
                                  ? 'Please enter your phone'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            _buildEditableField(
                              controller: _addressController,
                              label: 'Address',
                              icon: Icons.home_outlined,
                              validator: (value) => value?.isEmpty ?? true
                                  ? 'Please enter your address'
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_isEditing)
                      ElevatedButton(
                        onPressed: () async {
                          // Show loading indicator
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          // Update profile
                          await _updateProfile();

                          // Hide loading indicator
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: Colors.brown,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build editable fields
  Widget _buildEditableField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.brown),
        suffixIcon: _isEditing
            ? const Icon(Icons.edit_outlined, color: Colors.brown)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.brown,
            width: 2,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: validator,
      style: const TextStyle(fontSize: 16),
      enabled: _isEditing,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _adminEmailController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }
}
