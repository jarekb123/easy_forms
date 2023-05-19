import 'package:easy_forms_validation/easy_forms_validation.dart';
import 'package:example/simple_login_page/submit_form_cubit.dart';

class LoginFormController with FormControllerMixin {
  final username = TextFieldController<String>(
    validator: (value, _) {
      if (value.isEmpty) {
        return 'The username cannot be empty';
      }
      return null;
    },
    debugLabel: 'username',
  );

  final password = TextFieldController<String>(
    validator: (value, ref) {
      if (value == 'admin') {
        return 'You cannot use this password';
      }
      return null;
    },
    debugLabel: 'password',
  );

  @override
  List<FormPart<FormPartState>> get fields => [username, password];
}

enum LoginResult {
  usernameUsed,
  success,
}

class LoginRequest {
  final String username;
  final String password;

  LoginRequest({
    required this.username,
    required this.password,
  });
}

class LoginCubit extends SubmitFormCubit<LoginFormController, LoginResult>
    with FormValueMixin<LoginFormController, LoginRequest> {
  @override
  final form = LoginFormController();

  @override
  Future<LoginResult> performSubmit() {
    final request = mapToValidatedValue();
    return _simulateBackend(request);
  }

  Future<LoginResult> _simulateBackend(LoginRequest request) async {
    await Future.delayed(const Duration(seconds: 1));
    if (request.username == 'admin') {
      return LoginResult.usernameUsed;
    }
    return LoginResult.success;
  }

  @override
  void onSubmitted(LoginResult result) {
    if (result == LoginResult.usernameUsed) {
      form.username.overrideValidationError('This username is already used');
      emit(SubmitStatus.failure);
    } else {
      emit(SubmitStatus.success);
    }
  }

  @override
  LoginRequest mapToValidatedValue() {
    return LoginRequest(
      username: form.username.fieldValue,
      password: form.password.fieldValue,
    );
  }
}
