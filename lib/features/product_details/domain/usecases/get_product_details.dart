import '../entities/product_entity.dart';

class GetProductDetails {
  final ProductRepository repository;

  GetProductDetails(this.repository);

  Future<ProductEntity> call(String productId) {
    return repository.getProductDetails(productId);
  }
}
