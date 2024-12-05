import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object> get props => [];
}

class CartInitial extends CartState {}

class CartLoaded extends CartState {
  final List<CartItem> items;

  const CartLoaded({required this.items});

  @override
  List<Object> get props => [items];
}

class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object> get props => [message];
}

class CartItem extends Equatable {
  final String id;
  final String name;
  final double amount;
  final String image;
  final int quantity;

  const CartItem({
    required this.id,
    required this.name,
    required this.amount,
    required this.image,
    this.quantity = 1,
  });

  factory CartItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartItem(
      id: doc.id,
      name: data['name'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      image: data['image'] ?? '',
      quantity: (data['quantity'] ?? 1).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'image': image,
      'quantity': quantity,
    };
  }

  CartItem copyWith({
    String? id,
    String? name,
    double? amount,
    String? image,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      image: image ?? this.image,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object> get props => [id, name, amount, image, quantity];
}
