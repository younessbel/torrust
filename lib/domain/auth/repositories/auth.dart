import 'package:dartz/dartz.dart';
import 'package:netflix/data/auth/models/auth/signup_req_params.dart';

abstract class AuthRepository {
  Future<Either> signUp(SignupReqParams params) ;
}
