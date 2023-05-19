import 'package:easy_forms/easy_forms.dart';
import 'package:flutter/foundation.dart';

import '../../test_forms/login_form.dart';
import 'login_form_test_helpers.dart';

enum SubmitLoginFormState { initial, loading, success, error }

class SubmitLoginFormNotifier extends ValueNotifier<SubmitLoginFormState>
    with
        SubmitFormMixin<LoginForm, LoginResult>,
        FormValueMixin<LoginForm, LoginRequest> {
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
  LoginRequest mapToValidatedValue() {
    return LoginRequest(
      form.email.fieldValue,
      form.password.fieldValue,
    );
  }

  @override
  Future<LoginResult> performSubmit() {
    return _loginService.login(getValidatedValue());
  }
}
