import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coffee_shop/features/user/cart/bloc/cart_bloc.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: const Text(
        'Coffee Shop',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: Colors.brown,
        ),
      ),
      elevation: 0,
      actions: [
        IconButton(
          icon: Badge(
            backgroundColor: Colors.brown,
            child: Icon(
              Icons.notifications_outlined,
              color: Colors.brown.shade700,
            ),
          ),
          onPressed: () {
            // Handle notification action
          },
        ),
        BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            int totalQuantity = 0;

            if (state is CartLoaded) {
              totalQuantity = state.items.fold(
                0,
                (sum, item) => sum + item.quantity,
              );
            }

            return Badge(
              backgroundColor: Colors.brown,
              label: state is CartLoading
                  ? const SizedBox(
                      width: 10,
                      height: 10,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text('$totalQuantity'),
              child: IconButton(
                icon: Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.brown.shade700,
                ),
                onPressed: () => Navigator.pushNamed(context, '/cart'),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
