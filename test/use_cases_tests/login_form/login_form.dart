import 'package:easy_forms/easy_forms.dart';
import 'package:flutter/foundation.dart';

import 'login_form_test_helpers.dart';

enum EmailValidationError { invalidFormat, alreadyUsed }

enum PasswordValidationError { tooShort }

class LoginForm with FormControllerMixin {
  final email = TextFieldController(
    initialValue: '',
    validator: (value, _) {
      if (value.isEmpty || !value.contains('@')) {
        return EmailValidationError.invalidFormat;
      }
      return null;
    },
  );
  final password = TextFieldController(
    initialValue: '',
    validator: (value, _) {
      if (value.length < 6) {
        return PasswordValidationError.tooShort;
      }
      return null;
    },
  );

  @override
  List<FormPart<FormPartState>> get fields => [email, password];
}

enum SubmitLoginFormState { initial, loading, success, error }

class SubmitLoginFormNotifier extends ValueNotifier<SubmitLoginFormState>
    with SubmitFormMixin<LoginForm, LoginResult> {
  SubmitLoginFormNotifier(
    this._loginService,
  ) : super(SubmitLoginFormState.initial);

  final LoginService _loginService;

  @override
  final form = LoginForm();

  @override
  void onSubmitError(Object error, StackTrace stackTrace) {
    value = SubmitLoginFormState.error;
  }

  @override
  void onSubmitted(LoginResult result) {
    if (result == LoginResult.success) {
      value = SubmitLoginFormState.success;
    } else if (result == LoginResult.emailAlreadyUsed) {
      form.email.overrideValidationError(EmailValidationError.alreadyUsed);
      value = SubmitLoginFormState.error;
    }
  }

  @override
  void onSubmitting() {
    value = SubmitLoginFormState.loading;
  }

  @override
  Future<LoginResult> performSubmit() {
    return _loginService.login(
      form.email.fieldValue,
      form.password.fieldValue,
    );
  }
}
