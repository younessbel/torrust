import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:netflix/core/constants/api_url.dart';
import 'package:netflix/core/network/dio_client.dart';
import 'package:netflix/data/auth/models/auth/signup_req_params.dart';
import 'package:netflix/service_locator.dart';

abstract class AuthApiService {
  Future<Either> signUp(SignupReqParams params);
}

class AuthApiServiceImpl extends AuthApiService {
  @override
  Future<Either> signUp(SignupReqParams params) async {
    try {
      var response =
          await sl<DioClient>().post(ApiUrl.signup, data: params.toMap());
      return Right(response.data);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }
}
//if you want add firebase

class AuthfirebaseApiServiceImpl extends AuthApiService {
  @override
  Future<Either> signUp(SignupReqParams params) async {
    try {
      var response =
          await sl<DioClient>().post(ApiUrl.signup, data: params.toMap());
      return Right(response.data);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }
}