import 'package:coffee_shop/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../data/repositories/firebase_auth_repository.dart';

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserEntity user;

  AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignUpEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String phone;

  SignUpEvent(this.email, this.password, this.name, this.phone);

  @override
  List<Object?> get props => [email, password, name, phone];
}

class LoginEvent extends AuthEvent {
  final String identifier; // Can be email, phone, or username
  final String password;
  final LoginMethod method;

  LoginEvent(this.identifier, this.password, this.method);

  @override
  List<Object?> get props => [identifier, password, method];
}

enum LoginMethod { email, phone, username }

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignUpUseCase signUpUseCase;
  final LoginUseCase loginUseCase;
  final FirebaseAuthRepository repository;

  AuthBloc({
    required this.signUpUseCase,
    required this.loginUseCase,
    required this.repository,
  }) : super(AuthInitial()) {
    on<SignUpEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await signUpUseCase.call(
          event.email,
          event.password,
          event.name,
          event.phone,
        );
        emit(AuthSuccess(user));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await loginUseCase.call(
          event.identifier,
          event.password,
          event.method,
        );
        emit(AuthSuccess(user));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });
  }
}
