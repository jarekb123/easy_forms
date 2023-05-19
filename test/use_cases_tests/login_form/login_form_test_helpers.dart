import 'package:mocktail/mocktail.dart';

enum LoginResult {
  success,
  emailAlreadyUsed,
}

class LoginRequest {
  LoginRequest(this.email, this.password);

  final String email;
  final String password;
}

abstract class LoginService {
  Future<LoginResult> login(LoginRequest request);
}

class MockLoginService extends Mock implements LoginService {}
