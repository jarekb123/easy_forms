import 'package:easy_forms/easy_forms.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../test_helpers.dart';

/// This file contains tests for following use cases:
/// * some validation is done on flutter side
/// * some validation is done on server side.

enum _RegisterResult { success, emailAlreadyUsed }

const usedEmail = 'taken@email.com';

class _Server {
  Future<_RegisterResult> register(String email) async {
    if (email == usedEmail) {
      return _RegisterResult.emailAlreadyUsed;
    } else {
      return _RegisterResult.success;
    }
  }
}

enum _EmailValidationError {
  invalid,
  alreadyUsed,
}

enum _RegisterSubmitResult {
  initial,
  loading,
  success,
  error,
}

class _RegisterForm
    with FormControllerMixin, SubmitFormMixin<_RegisterForm, _RegisterResult> {
  _RegisterForm(this._server);

  final _Server _server;

  final email = TextFieldController<_EmailValidationError>(
    initialValue: '',
    validator: (value) {
      if (value.isEmpty || !value.contains('@')) {
        return _EmailValidationError.invalid;
      }
      return null;
    },
  );

  @override
  List<FormPart<FormPartState>> get fields => [email];

  @override
  _RegisterForm get form => this;

  final submitState = ValueNotifier<_RegisterSubmitResult>(
    _RegisterSubmitResult.initial,
  );

  @override
  void onSubmitError(Object error, StackTrace stackTrace) {
    submitState.value = _RegisterSubmitResult.error;
  }

  @override
  void onSubmitted(_RegisterResult result) {
    if (result == _RegisterResult.emailAlreadyUsed) {
      email.overrideValidationError(_EmailValidationError.alreadyUsed);
      submitState.value = _RegisterSubmitResult.error;
    } else {
      submitState.value = _RegisterSubmitResult.success;
    }
  }

  @override
  void onSubmitting() {
    submitState.value = _RegisterSubmitResult.loading;
  }

  @override
  Future<_RegisterResult> performSubmit() {
    return _server.register(email.value.value);
  }
}

void main() {
  late _RegisterForm form;

  late MockListener<FieldControllerState<String, _EmailValidationError>>
      fieldListener;
  late MockListener<FormControllerState> formListener;

  setUp(() {
    fieldListener = MockListener();
    formListener = MockListener();

    form = _RegisterForm(
      _Server(),
    );

    form.email.addListener(() => fieldListener(form.email.value));
    form.addListener(() => formListener(form.value));
  });

  test('handles flutter side validation', () async {
    expectValidationState(form.email.value, ValidationState.dirty);
    expectValidationState(form.value, ValidationState.dirty);

    form.email.updateValue('invalid');
    await form.submit();

    expectValidationError(form.email.value, _EmailValidationError.invalid);
    expect(
      form.submitState.value,
      _RegisterSubmitResult.initial,
    ); // server not called

    // email field state changes
    verifyInOrder([
      () => fieldListener(
            const FieldControllerState(
              value: 'invalid',
              error: null,
              validationState: ValidationState.dirty,
            ),
          ),
      () => fieldListener(
            const FieldControllerState(
              value: 'invalid',
              error: _EmailValidationError.invalid,
              validationState: ValidationState.invalid,
            ),
          ),
    ]);
    verifyNoMoreInteractions(fieldListener);

    // form state changes
    verifyInOrder([
      // this is the initial state, so no change here
      // () => formListener(
      //       const FormControllerState(
      //         validationState: ValidationState.dirty,
      //       ),
      //     ),
      () => formListener(
            const FormControllerState(
              validationState: ValidationState.invalid,
            ),
          ),
    ]);
  });

  test('consumes server side validation', () async {
    expectValidationState(form.value, ValidationState.dirty);
    form.email.updateValue(usedEmail);
    await form.submit();

    expectValidationError(form.email.value, _EmailValidationError.alreadyUsed);
    expect(
      form.submitState.value,
      _RegisterSubmitResult.error,
    ); // server called

    // email field state changes
    verifyInOrder([
      () => fieldListener(
            const FieldControllerState(
              value: usedEmail,
              error: null,
              validationState: ValidationState.dirty,
            ),
          ),
      // frontend validation passed
      () => fieldListener(
            const FieldControllerState(
              value: usedEmail,
              error: null,
              validationState: ValidationState.valid,
            ),
          ),
      () => fieldListener(
            const FieldControllerState(
              value: usedEmail,
              error: _EmailValidationError.alreadyUsed,
              validationState: ValidationState.invalid,
            ),
          ),
    ]);
    verifyNoMoreInteractions(fieldListener);

    // form state changes
    verifyInOrder([
      // this is the initial state
      // () => formListener(
      //       const FormControllerState(
      //         validationState: ValidationState.dirty,
      //       ),
      //     ),
      () => formListener(
            const FormControllerState(
              validationState: ValidationState.valid,
            ),
          ),
      () => formListener(
            const FormControllerState(
              validationState: ValidationState.invalid,
            ),
          ),
    ]);
  });
}
