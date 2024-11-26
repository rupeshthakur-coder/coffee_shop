import 'package:coffee_shop/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:coffee_shop/features/auth/domain/entities/user_entity.dart';
import 'package:coffee_shop/features/auth/presentation/bloc/auth_bloc.dart';

class LoginUseCase {
  final FirebaseAuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserEntity> call(
      String identifier, String password, LoginMethod method) async {
    return await repository.logIn(identifier, password, method);
  }
}
