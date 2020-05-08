import 'package:sddomain/model/user_model.dart';

abstract class UserRepository {
  Future<void> logout();

  Future<UserModel> profile();

  Future<UserModel> getUserById(int id);
}