import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Cart Item Model
// // Model
class CartItem {
  final String id;
  final String productId;
  final int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.quantity,
  });
}

// Cart Events
abstract class CartEvent {}

class LoadCart extends CartEvent {}

class UpdateCartFromFirebase extends CartEvent {
  final List<CartItem> items;

  UpdateCartFromFirebase(this.items);
}

// Cart States
abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItem> items;

  CartLoaded({required this.items});
}

// CartBloc
class CartBloc extends Bloc<CartEvent, CartState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription? _cartSubscription;

  CartBloc() : super(CartInitial()) {
    on<LoadCart>(_onLoadCart);
    on<UpdateCartFromFirebase>(_onUpdateCartFromFirebase);

    _startListeningToCart();
  }

  void _startListeningToCart() {
    final user = _auth.currentUser;
    if (user != null) {
      _cartSubscription?.cancel();
      _cartSubscription = _firestore.collection('cart').where('userId', isEqualTo: user.uid).snapshots().listen((snapshot) {
        final items = snapshot.docs.map((doc) {
          final data = doc.data();
          return CartItem(
            id: doc.id,
            productId: data['productId'] ?? '',
            quantity: (data['quantity'] as num?)?.toInt() ?? 1,
          );
        }).toList();

        add(UpdateCartFromFirebase(items));
      });
    }
  }

  Future<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    emit(CartLoading());
    final user = _auth.currentUser;
    if (user == null) {
      emit(CartInitial());
      return;
    }

    final snapshot = await _firestore.collection('cart').where('userId', isEqualTo: user.uid).get();

    final items = snapshot.docs.map((doc) {
      final data = doc.data();
      return CartItem(
        id: doc.id,
        productId: data['productId'] ?? '',
        quantity: (data['quantity'] as num?)?.toInt() ?? 1,
      );
    }).toList();

    emit(CartLoaded(items: items));
  }

  void _onUpdateCartFromFirebase(UpdateCartFromFirebase event, Emitter<CartState> emit) {
    emit(CartLoaded(items: event.items));
  }

  @override
  Future<void> close() {
    _cartSubscription?.cancel();
    return super.close();
  }
}
