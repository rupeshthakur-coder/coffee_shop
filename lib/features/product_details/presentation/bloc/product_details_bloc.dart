import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_product_details.dart';

// Events
abstract class ProductDetailsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProductDetails extends ProductDetailsEvent {
  final String productId;

  LoadProductDetails(this.productId);

  @override
  List<Object?> get props => [productId];
}

// States
abstract class ProductDetailsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProductDetailsInitial extends ProductDetailsState {}

class ProductDetailsLoading extends ProductDetailsState {}

class ProductDetailsLoaded extends ProductDetailsState {
  final ProductEntity product;

  ProductDetailsLoaded(this.product);

  @override
  List<Object?> get props => [product];
}

class ProductDetailsError extends ProductDetailsState {
  final String message;

  ProductDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class ProductDetailsBloc
    extends Bloc<ProductDetailsEvent, ProductDetailsState> {
  final GetProductDetails getProductDetails;

  ProductDetailsBloc({required this.getProductDetails})
      : super(ProductDetailsInitial()) {
    on<LoadProductDetails>(_onLoadProductDetails);
  }

  Future<void> _onLoadProductDetails(
    LoadProductDetails event,
    Emitter<ProductDetailsState> emit,
  ) async {
    emit(ProductDetailsLoading());
    try {
      final product = await getProductDetails(event.productId);
      emit(ProductDetailsLoaded(product));
    } catch (e) {
      emit(ProductDetailsError(e.toString()));
    }
  }
}
