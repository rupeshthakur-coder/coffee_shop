import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class CartBloc extends Bloc<CartEvent, CartState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription? _cartSubscription;

  CartBloc() : super(CartInitial()) {
    // Start listening to cart changes when bloc is created
    _startListeningToCart();

    on<LoadCart>(_onLoadCart);
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
  }

  void _startListeningToCart() {
    if (_auth.currentUser != null) {
      _cartSubscription?.cancel();
      _cartSubscription = _firestore
          .collection('carts')
          .doc(_auth.currentUser!.uid)
          .collection('items')
          .snapshots()
          .listen((snapshot) {
        final items = snapshot.docs.map((doc) {
          final data = doc.data();
          return CartItem(
            id: doc.id,
            productId: data['productId'],
            quantity: data['quantity'],
            // Add other fields as needed
          );
        }).toList();

        add(UpdateCartFromFirebase(items));
      });
    }
  }

  Future<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    try {
      emit(CartLoading());

      final snapshot = await _firestore
          .collection('carts')
          .doc(_auth.currentUser!.uid)
          .collection('items')
          .get();

      final items = snapshot.docs.map((doc) {
        final data = doc.data();
        return CartItem(
          id: doc.id,
          productId: data['productId'],
          quantity: data['quantity'],
          // Add other fields as needed
        );
      }).toList();

      emit(CartLoaded(items: items));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onAddToCart(AddToCart event, Emitter<CartState> emit) async {
    try {
      if (state is CartLoaded) {
        final userCartRef = _firestore
            .collection('carts')
            .doc(_auth.currentUser!.uid)
            .collection('items');

        // Check if item already exists
        final existingItem = await userCartRef
            .where('productId', isEqualTo: event.item.productId)
            .get();

        if (existingItem.docs.isNotEmpty) {
          // Update quantity
          await userCartRef.doc(existingItem.docs.first.id).update({
            'quantity': FieldValue.increment(event.item.quantity),
          });
        } else {
          // Add new item
          await userCartRef.add({
            'productId': event.item.productId,
            'quantity': event.item.quantity,
            // Add other item details
          });
        }

        // No need to emit state here as the stream listener will handle it
      }
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onRemoveFromCart(
      RemoveFromCart event, Emitter<CartState> emit) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(CartError('User not logged in'));
        return;
      }

      await FirebaseFirestore.instance
          .collection('cart')
          .doc(event.item.id)
          .delete();

      add(LoadCart()); // Reload cart after removing item
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _cartSubscription?.cancel();
    return super.close();
  }
}

// Events
abstract class CartEvent {}

class LoadCart extends CartEvent {}

class AddToCart extends CartEvent {
  final CartItem item;
  AddToCart(this.item);
}

class RemoveFromCart extends CartEvent {
  final CartItem item;
  RemoveFromCart(this.item);
}

class UpdateCartFromFirebase extends CartEvent {
  final List<CartItem> items;
  UpdateCartFromFirebase(this.items);
}

// States
abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItem> items;
  CartLoaded({required this.items});
}

class CartError extends CartState {
  final String message;
  CartError(this.message);
}

// Model
class CartItem {
  final String id;
  final String productId;
  final int quantity;
  // Add other fields as needed

  CartItem({
    required this.id,
    required this.productId,
    required this.quantity,
  });
}
