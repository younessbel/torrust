// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dartz/dartz.dart';
import 'package:netflix/data/auth/models/auth/signup_req_params.dart';
import 'package:netflix/data/auth/sources/auth/auth_api_service.dart';
import 'package:netflix/domain/auth/repositories/auth.dart';
import 'package:netflix/service_locator.dart';

class AuthRepositoryImpl extends AuthRepository {
  @override
  Future<Either> signUp(SignupReqParams params) async {
    return await sl<AuthApiService>().signUp(params);
  }
}
