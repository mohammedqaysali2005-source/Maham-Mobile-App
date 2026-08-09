import 'package:dio/dio.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../shared/models/user_model.dart';
import '../models/auth_response_model.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final DioClient _dioClient;
  final SecureStorageService _secureStorageService;

  AuthRepositoryImpl(this._dioClient, this._secureStorageService);

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    try {
      final response = await _dioClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final apiResponse = ApiResponse<AuthResponseModel>.fromJson(
        response.data,
        (data) => AuthResponseModel.fromJson(data),
      );

      if (apiResponse.success && apiResponse.data != null) {
        final authData = apiResponse.data!;
        await _saveAuthData(authData);
        return authData;
      } else {
        throw ApiException(message: apiResponse.message ?? 'فشل تسجيل الدخول');
      }
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(message: e.message ?? 'فشل تسجيل الدخول');
    }
  }

  @override
  Future<AuthResponseModel> register(
    String fullName,
    String email,
    String password,
  ) async {
    try {
      final response = await _dioClient.post(
        '/auth/register',
        data: {
          'fullName': fullName,
          'email': email,
          'password': password,
        },
      );

      final apiResponse = ApiResponse<AuthResponseModel>.fromJson(
        response.data,
        (data) => AuthResponseModel.fromJson(data),
      );

      if (apiResponse.success && apiResponse.data != null) {
        final authData = apiResponse.data!;
        await _saveAuthData(authData);
        return authData;
      } else {
        throw ApiException(
            message: apiResponse.message ?? 'فشل إنشاء حساب جديد');
      }
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(message: e.message ?? 'فشل إنشاء حساب جديد');
    }
  }

  @override
  Future<UserModel> getMe() async {
    try {
      final response = await _dioClient.get('/auth/me');

      final apiResponse = ApiResponse<UserModel>.fromJson(
        response.data,
        (data) => UserModel.fromJson(data),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      } else {
        throw ApiException(message: apiResponse.message ?? 'فشل جلب الملف الشخصي');
      }
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(message: e.message ?? 'فشل جلب الملف الشخصي');
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Best-effort call to backend
      await _dioClient.post('/auth/logout').timeout(const Duration(seconds: 3));
    } catch (_) {
      // Ignore network failures on logout
    } finally {
      // Always clear local session token
      await _secureStorageService.clearAll();
    }
  }

  @override
  Future<AuthResponseModel> refresh() async {
    try {
      final response = await _dioClient.post('/auth/refresh');

      final apiResponse = ApiResponse<AuthResponseModel>.fromJson(
        response.data,
        (data) => AuthResponseModel.fromJson(data),
      );

      if (apiResponse.success && apiResponse.data != null) {
        final authData = apiResponse.data!;
        await _saveAuthData(authData);
        return authData;
      } else {
        throw ApiException(message: apiResponse.message ?? 'فشل تجديد الرمز');
      }
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(message: e.message ?? 'فشل تجديد الرمز');
    }
  }

  Future<void> _saveAuthData(AuthResponseModel authData) async {
    await _secureStorageService.saveToken(authData.token);
    await _secureStorageService.saveUserId(authData.user.id);
    await _secureStorageService.saveUserName(authData.user.fullName);
    await _secureStorageService.saveUserEmail(authData.user.email);
    await _secureStorageService.saveUserRole(authData.user.role);
  }
}
