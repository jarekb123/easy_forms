// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:easy_forms/src/extensions/form_value_mixin.dart';

import '../test_forms/login_form.dart';

class LoginRequest {
  const LoginRequest(this.email, this.password);

  final String email;
  final String password;

  @override
  bool operator ==(covariant LoginRequest other) {
    if (identical(this, other)) return true;

    return other.email == email && other.password == password;
  }

  @override
  int get hashCode => email.hashCode ^ password.hashCode;
}

class LoginFormWithFormValue extends LoginForm
    with FormValueMixin<LoginForm, LoginRequest> {
  @override
  LoginForm get form => this;

  @override
  LoginRequest mapToValidatedValue() {
    return LoginRequest(
      email.fieldValue,
      password.fieldValue,
    );
  }
}

void main() {
  registerFallbackValue(const LoginRequest('', ''));

  late LoginFormWithFormValue form;

  setUp(
    () {
      form = LoginFormWithFormValue();
    },
  );

  test('getValidatedValue() throws StateError if fields are invalid', () {
    form.email.overrideValidationError(EmailValidationError.alreadyUsed);
    form.password.overrideValidationError(PasswordValidationError.tooShort);

    expect(
      () => form.getValidatedValue(),
      throwsA(isA<StateError>()),
    );
  });

  test('getValidatedValue() returns validated value', () {
    form.email.updateValue('email@email.com');
    form.password.updateValue('password');
    form.validate();

    expect(
      form.getValidatedValue(),
      const LoginRequest('email@email.com', 'password'),
    );
  });

  test('getValidatedValueOrNull() returns null if fields are invalid', () {
    form.email.overrideValidationError(EmailValidationError.alreadyUsed);
    form.password.overrideValidationError(PasswordValidationError.tooShort);

    expect(
      form.getValidatedValueOrNull(),
      isNull,
    );
  });

  test('getValidatedValueOrNull() returns validated value', () {
    form.email.updateValue('email@email.com');
    form.password.updateValue('password');
    form.validate();

    expect(
      form.getValidatedValueOrNull(),
      const LoginRequest('email@email.com', 'password'),
    );
  });
}
