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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
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
                        GestureDetector(
                          onTap: () {
                            // Allow user to choose an icon
                            setState(() {
                              _isEditing = true;
                            });
                          },
                          child: const CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person,
                                size: 50, color: Colors.grey),
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
    super.dispose();
  }
}
