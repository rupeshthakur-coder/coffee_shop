import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/product_entity.dart';

import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final FirebaseFirestore firestore;

  ProductRepositoryImpl(this.firestore);

  @override
  Future<ProductEntity> getProductDetails(String productId) async {
    try {
      final doc = await firestore.collection('items').doc(productId).get();

      if (!doc.exists) {
        throw Exception('Product not found');
      }

      final data = doc.data();
      if (data == null) {
        throw Exception('Product data is null');
      }

      return ProductModel.fromFirestore({
        'name': data['name'] ?? '',
        'description': data['description'] ?? '',
        'price': (data['amount'] ?? 0.0).toDouble(),
        'image': data['image'] ?? '',
        'stock': data['stock'] ?? 0,
        'milk': data['milk'] ?? 0,
        'water': data['water'] ?? 0,
        'coffee': data['coffee'] ?? 0,
        'type': data['type'] ?? '',
        'category': data['category'] ?? '',
        'origin': data['origin'] ?? '',
        'roastLevel': data['roastLevel'] ?? '',
        'brewingTime': data['brewingTime'] ?? '',
        'temperature': data['temperature'] ?? '',
      }, productId);
    } catch (e) {
      throw Exception('Failed to load product details: $e');
    }
  }
}
