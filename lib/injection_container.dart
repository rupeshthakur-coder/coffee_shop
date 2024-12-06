import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'features/auth/data/repositories/firebase_auth_repository.dart';
import 'features/auth/domain/usecases/sign_up_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

void init() {
  // Firebase instances
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // Repository
  sl.registerLazySingleton(() => FirebaseAuthRepository(sl(), sl()));

  // Use Cases
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));

  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      signUpUseCase: sl<SignUpUseCase>(),
      loginUseCase: sl<LoginUseCase>(),
      repository: sl<FirebaseAuthRepository>(),
    ),
  );

  // for admin
}
