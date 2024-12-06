import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.image,
    required super.stock,
    required super.milk,
    required super.water,
    required super.coffee,
    required super.type,
    required super.category,
    required super.origin,
    required super.roastLevel,
    required super.brewingTime,
    required super.temperature,
  });

  factory ProductModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ProductModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      image: data['image'] ?? '',
      stock: data['stock'] ?? 0,
      milk: data['milk'] ?? 0,
      water: data['water'] ?? 0,
      coffee: data['coffee'] ?? 0,
      type: data['type'] ?? '',
      category: data['category'] ?? '',
      origin: data['origin'] ?? '',
      roastLevel: data['roastLevel'] ?? '',
      brewingTime: data['brewingTime'] ?? '',
      temperature: data['temperature'] ?? '',
    );
  }
}
