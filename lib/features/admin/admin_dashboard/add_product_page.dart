import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String image;
  final String name;
  final double price;
  final int stock;
  final int milk;
  final int water;
  final int coffee;
  final String description;
  final String type;
  final String category;
  final String origin;
  final String roastLevel;
  final String brewingTime;
  final String temperature;

  Product({
    required this.image,
    required this.name,
    required this.price,
    required this.stock,
    required this.milk,
    required this.water,
    required this.coffee,
    required this.description,
    required this.type,
    required this.category,
    required this.origin,
    required this.roastLevel,
    required this.brewingTime,
    required this.temperature,
  });

  Map<String, dynamic> toMap() {
    return {
      'image': image,
      'name': name,
      'price': price,
      'stock': stock,
      'milk': milk,
      'water': water,
      'coffee': coffee,
      'description': description,
      'type': type,
      'category': category,
      'origin': origin,
      'roastLevel': roastLevel,
      'brewingTime': brewingTime,
      'temperature': temperature,
    };
  }
}

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController imageController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController milkController = TextEditingController();
  final TextEditingController waterController = TextEditingController();
  final TextEditingController coffeeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController originController = TextEditingController();
  final TextEditingController roastLevelController = TextEditingController();
  final TextEditingController brewingTimeController = TextEditingController();
  final TextEditingController temperatureController = TextEditingController();
  String selectedType = 'coffee';
  String selectedCategory = 'hot';

  // Add category lists
  final Map<String, List<String>> categoryOptions = {
    'coffee': ['hot', 'cold', 'arabica', 'robusta', 'blend'],
    'tea': ['hot', 'cold', 'green', 'black', 'herbal'],
  };

  Future<void> _addProduct() async {
    if (!_validateFields()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    try {
      final product = Product(
        image: imageController.text,
        name: nameController.text,
        price: double.parse(priceController.text),
        stock: int.parse(stockController.text),
        milk: int.parse(milkController.text),
        water: int.parse(waterController.text),
        coffee: int.parse(coffeeController.text),
        description: descriptionController.text,
        type: selectedType,
        category: selectedCategory,
        origin: originController.text,
        roastLevel: roastLevelController.text,
        brewingTime: brewingTimeController.text,
        temperature: temperatureController.text,
      );

      await FirebaseFirestore.instance
          .collection('products')
          .add(product.toMap());

      _clearForm();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding product: $e')),
      );
    }
  }

  bool _validateFields() {
    return imageController.text.isNotEmpty &&
        nameController.text.isNotEmpty &&
        priceController.text.isNotEmpty &&
        stockController.text.isNotEmpty &&
        milkController.text.isNotEmpty &&
        waterController.text.isNotEmpty &&
        coffeeController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        originController.text.isNotEmpty &&
        roastLevelController.text.isNotEmpty &&
        brewingTimeController.text.isNotEmpty &&
        temperatureController.text.isNotEmpty;
  }

  void _clearForm() {
    imageController.clear();
    nameController.clear();
    priceController.clear();
    stockController.clear();
    milkController.clear();
    waterController.clear();
    coffeeController.clear();
    descriptionController.clear();
    originController.clear();
    roastLevelController.clear();
    brewingTimeController.clear();
    temperatureController.clear();
    setState(() {
      selectedType = 'coffee';
      selectedCategory = 'hot';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('New Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {}, // Add clear form functionality
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description Section
            const Text('Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Product Name Field
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
                hintText: 'e.g., Ethiopian Yirgacheffe Coffee',
              ),
            ),
            const SizedBox(height: 16),

            // Product Description Field
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Product Description',
                border: OutlineInputBorder(),
                hintText:
                    'Describe the product characteristics, flavor notes, etc.',
              ),
            ),
            const SizedBox(height: 24),

            // Category Section
            const Text('Category',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Update the category dropdown
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Product Category',
              ),
              items: categoryOptions[selectedType]?.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Update the type dropdown to handle category changes
            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Product Type',
              ),
              items: const [
                DropdownMenuItem(value: 'coffee', child: Text('Coffee')),
                DropdownMenuItem(value: 'tea', child: Text('Tea')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedType = value!;
                  // Reset category to first option when type changes
                  selectedCategory = categoryOptions[value]!.first;
                });
              },
            ),
            const SizedBox(height: 24),

            // Add Image URL Field
            const Text('Image',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: imageController,
              decoration: const InputDecoration(
                labelText: 'Image URL',
                border: OutlineInputBorder(),
                hintText: 'Enter image URL or file path',
              ),
            ),
            const SizedBox(height: 24),

            // Add new fields before Recipe Details section
            const Text('Product Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            TextField(
              controller: originController,
              decoration: InputDecoration(
                labelText:
                    selectedType == 'coffee' ? 'Coffee Origin' : 'Tea Origin',
                border: const OutlineInputBorder(),
                hintText: selectedType == 'coffee'
                    ? 'e.g., Ethiopia, Colombia'
                    : 'e.g., China, India',
              ),
            ),
            const SizedBox(height: 16),

            // Conditional field based on product type
            if (selectedType == 'coffee')
              TextField(
                controller: roastLevelController,
                decoration: const InputDecoration(
                  labelText: 'Roast Level',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Light, Medium, Dark',
                ),
              ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: brewingTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Brewing Time',
                      border: OutlineInputBorder(),
                      suffixText: 'min',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: temperatureController,
                    decoration: const InputDecoration(
                      labelText: 'Brewing Temperature',
                      border: OutlineInputBorder(),
                      suffixText: '°C',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Add these fields before the Product Details section
            const Text('Recipe Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: milkController,
                    decoration: const InputDecoration(
                      labelText: 'Steamed Milk (ml)',
                      border: OutlineInputBorder(),
                      suffixText: 'ml',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: waterController,
                    decoration: const InputDecoration(
                      labelText: 'Water (ml)',
                      border: OutlineInputBorder(),
                      suffixText: 'ml',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: coffeeController,
              decoration: const InputDecoration(
                labelText: 'Coffee or tea (g)',
                border: OutlineInputBorder(),
                suffixText: 'g',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // Product Details
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: stockController,
                    decoration: const InputDecoration(
                      labelText: 'Stock Quantity',
                      border: OutlineInputBorder(),
                      suffixText: 'units',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Add Product',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearForm,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Clear Form'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
