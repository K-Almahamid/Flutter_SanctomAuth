import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as Dio;
import 'package:flutter_laravel_auth/models/user.dart';
import 'package:flutter_laravel_auth/services/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Auth extends ChangeNotifier {
  bool _isLoggedIn = false;
  late User _user;
  late String _token;

  bool get authenticated => _isLoggedIn;

  User get user => _user;

  final storage = const FlutterSecureStorage();

  void login({required Map credentials}) async {
    try {
      // print(credentials);
      Dio.Response response =
          await dio().post('/sanctum/token', data: credentials);
      // print(response.data.toString());

      String token = response.data.toString();
      tryToken(token: token);
    } catch (e) {
      print(e);
    }
  }

  void tryToken({required String token}) async {
    if (token == null) {
      return; //if null no request send
    } else {
      try {
        Dio.Response response = await dio().get('/user',
            options: Dio.Options(headers: {'Authorization': 'Bearer $token'}));
        _isLoggedIn = true;
        _user = User.fromJson(response.data);
        _token = token;
        storeToken(token: token);
        notifyListeners();

        print(_user);
      } catch (e) {
        print(e);
      }
    }
  }

  void storeToken({required String token}) async {
    storage.write(key: 'token', value: token);
  }

  void cleanUpToken() async {
    // _user = null;
    _isLoggedIn = false;
    await storage.delete(key: 'token');
  }

  void logout() async {
    try {
      Dio.Response response = await dio().get('/user/revoke',
          options: Dio.Options(headers: {'Authorization': 'Bearer $_token'}));
      cleanUpToken();
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
}
