import 'package:mocktail/mocktail.dart';

enum LoginResult {
  success,
  emailAlreadyUsed,
}

abstract class LoginService {
  Future<LoginResult> login(String email, String password);
}

class MockLoginService extends Mock implements LoginService {}
