import 'package:get_it/get_it.dart';
import 'package:netflix/core/network/dio_client.dart';
import 'package:netflix/data/auth/repositories/auth/auth.dart';
import 'package:netflix/data/auth/sources/auth/auth_api_service.dart';
import 'package:netflix/domain/auth/repositories/auth.dart';
import 'package:netflix/domain/auth/usecases/suignup.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  sl.registerSingleton<DioClient>(DioClient());
  
  //services
  sl.registerSingleton<AuthApiService>(AuthApiServiceImpl());
  //repository
  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl());
// use case
  sl.registerSingleton<SignupUSeCase>(SignupUSeCase());

  
}
