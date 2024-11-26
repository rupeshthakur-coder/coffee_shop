import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coffee_shop/core/colors/app_colors.dart';
import 'package:coffee_shop/core/textStyle/app_text_style.dart';

// BLoC for Admin Page
class AdminBloc extends Cubit<List<Item>> {
  AdminBloc() : super([]);

  void addItem(Item item) {
    // Logic to add item to Firestore
    FirebaseFirestore.instance.collection('items').add(item.toMap()).then((_) {
      emit([...state, item]); // Update state
    }).catchError((error) {
      // Handle the error, e.g., log it or show a message
      print("Failed to add item: $error");
    });
  }
}

// Item model
class Item {
  final String image;
  final String name;
  final int amount;
  final int milk;
  final int water;
  final int coffee;

  Item(this.image, this.name, this.amount, this.milk, this.water, this.coffee);

  Map<String, dynamic> toMap() {
    return {
      'image': image,
      'name': name,
      'amount': amount,
      'milk': milk,
      'water': water,
      'coffee': coffee,
    };
  }
}

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment(0.8, 1),
            colors: <Color>[
              Color(0xff4e342e), // Deep Coffee Brown
              Color(0xff6d4c41), // Mocha
              Color(0xff8d6e63), // Latte
              Color(0xffa1887f), // Caramel
            ],
          ),
        ),
        child: BlocProvider(
          create: (_) => AdminBloc(),
          child: AdminForm(),
        ),
      ),
    );
  }
}

class AdminForm extends StatelessWidget {
  final TextEditingController imageController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController milkController = TextEditingController();
  final TextEditingController waterController = TextEditingController();
  final TextEditingController coffeeController = TextEditingController();

  AdminForm({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: const Text('Admin Dashboard')
                    .indieFlowerLoginStyleffFDF7F7()),
            const SizedBox(height: 20),
            _buildTextField('Image URL or File Path', imageController),
            const SizedBox(height: 12),
            _buildTextField('Name', nameController),
            const SizedBox(height: 12),
            _buildTextField('Amount', amountController, isNumeric: true),
            const SizedBox(height: 12),
            _buildTextField('Steamed Milk', milkController, isNumeric: true),
            const SizedBox(height: 12),
            _buildTextField('Milk Foam', waterController, isNumeric: true),
            const SizedBox(height: 12),
            _buildTextField('Coffee', coffeeController, isNumeric: true),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (imageController.text.isEmpty ||
                        nameController.text.isEmpty ||
                        amountController.text.isEmpty ||
                        milkController.text.isEmpty ||
                        waterController.text.isEmpty ||
                        coffeeController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                      return;
                    }

                    final item = Item(
                      imageController.text,
                      nameController.text,
                      int.parse(amountController.text),
                      int.parse(milkController.text),
                      int.parse(waterController.text),
                      int.parse(coffeeController.text),
                    );
                    context.read<AdminBloc>().addItem(item);

                    // Clear all fields after successful addition
                    imageController.clear();
                    nameController.clear();
                    amountController.clear();
                    milkController.clear();
                    waterController.clear();
                    coffeeController.clear();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ff011C2A,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Add Item')
                      .poppinsMediumSize20FFFFFF(), // Example of custom text style
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumeric = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
        ).poppinsRegularSize14FFFBFB(),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Colors.white.withOpacity(0.5), width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.redAccent, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
