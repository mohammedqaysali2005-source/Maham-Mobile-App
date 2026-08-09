import '../../../../shared/models/user_model.dart';
import '../../data/models/auth_response_model.dart';

abstract class AuthRepository {
  Future<AuthResponseModel> login(String email, String password);
  Future<AuthResponseModel> register(
    String fullName,
    String email,
    String password,
  );
  Future<UserModel> getMe();
  Future<void> logout();
  Future<AuthResponseModel> refresh();
}
