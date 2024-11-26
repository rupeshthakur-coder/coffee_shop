import 'package:coffee_shop/features/auth/domain/entities/user_entity.dart';
import 'package:coffee_shop/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRepository(this._firebaseAuth, this._firestore);

  Future<UserEntity> signUp(
      String email, String password, String name, String phone) async {
    try {
      final methods = await _firebaseAuth.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) {
        throw 'Account already exists with this email';
      }

      final UserCredential result =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user!;
      final userEntity = UserEntity(
        uid: user.uid,
        email: email,
        name: name,
        phone: phone,
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userEntity.toMap());

      await _firestore.collection('user_credentials').doc(user.uid).set({
        'password': password,
      });

      return userEntity;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserEntity> logIn(
      String identifier, String password, LoginMethod method) async {
    try {
      late UserCredential result;
      late QuerySnapshot querySnapshot;

      switch (method) {
        case LoginMethod.email:
          try {
            result = await _firebaseAuth.signInWithEmailAndPassword(
              email: identifier,
              password: password,
            );
          } catch (e) {
            throw 'Invalid email or password';
          }
          break;

        case LoginMethod.phone:
        case LoginMethod.username:
          // Query Firestore based on method
          final field = method == LoginMethod.phone ? 'phone' : 'name';
          querySnapshot = await _firestore
              .collection('users')
              .where(field, isEqualTo: identifier)
              .get();

          if (querySnapshot.docs.isEmpty) {
            throw 'No account found with this ${method == LoginMethod.phone ? 'phone number' : 'username'}';
          }

          final userDoc = querySnapshot.docs.first;
          final email = (userDoc.data() as Map<String, dynamic>)['email'];

          try {
            result = await _firebaseAuth.signInWithEmailAndPassword(
              email: email,
              password: password,
            );
          } catch (e) {
            throw 'Invalid password';
          }
          break;
      }

      final user = result.user!;
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        throw 'User data not found';
      }

      return UserEntity(
        uid: user.uid,
        email: userDoc.data()?['email'],
        phone: userDoc.data()?['phone'],
        name: userDoc.data()?['name'],
      );
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> forgotPassword(String identifier, LoginMethod method) async {
    try {
      String? email;

      if (method == LoginMethod.email) {
        email = identifier;
      } else {
        final field = method == LoginMethod.phone ? 'phone' : 'name';
        final querySnapshot = await _firestore
            .collection('users')
            .where(field, isEqualTo: identifier)
            .get();

        if (querySnapshot.docs.isEmpty) {
          throw 'No account found with this ${method == LoginMethod.phone ? 'phone number' : 'username'}';
        }

        email = querySnapshot.docs.first.data()['email'];
      }

      await _firebaseAuth.sendPasswordResetEmail(email: email!);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> saveUserData(String uid, String name, String phone) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .update({'name': name, 'phone': phone});
  }
}
