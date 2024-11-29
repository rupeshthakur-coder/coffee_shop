import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartService {
  static Future<int> getItemCount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No user logged in');
        return 0;
      }

      print('Fetching cart for user: ${user.uid}');
      final cartSnapshot = await FirebaseFirestore.instance
          .collection('carts')
          .doc(user.uid)
          .collection('items')
          .get();

      // Sum up the quantities of all items
      int totalCount = 0;
      for (var doc in cartSnapshot.docs) {
        totalCount += (doc.data()['quantity'] ?? 0) as int;
      }

      print('Total items count: $totalCount');
      return totalCount;
    } catch (e) {
      print('Error getting cart count: $e');
      return 0;
    }
  }
}
