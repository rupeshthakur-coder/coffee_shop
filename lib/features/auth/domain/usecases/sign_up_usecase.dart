import 'package:coffee_shop/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:coffee_shop/features/auth/domain/entities/user_entity.dart';

class SignUpUseCase {
  final FirebaseAuthRepository repository;

  SignUpUseCase(this.repository);

  Future<UserEntity> call(
      String email, String password, String name, String phone) async {
    return await repository.signUp(email, password, name, phone);
  }
}
