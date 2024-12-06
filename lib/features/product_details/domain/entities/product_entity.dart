class ProductEntity {
  final String id;
  final String name;
  final String description;
  final double price;
  final String image;
  final int stock;
  final int milk;
  final int water;
  final int coffee;
  final String type;
  final String category;
  final String origin;
  final String roastLevel;
  final String brewingTime;
  final String temperature;

  ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.stock,
    required this.milk,
    required this.water,
    required this.coffee,
    required this.type,
    required this.category,
    required this.origin,
    required this.roastLevel,
    required this.brewingTime,
    required this.temperature,
  });
}

abstract class ProductRepository {
  Future<ProductEntity> getProductDetails(String productId);
}
