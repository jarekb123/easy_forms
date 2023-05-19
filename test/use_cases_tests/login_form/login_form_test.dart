import 'package:easy_forms/easy_forms.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'login_form.dart';
import 'login_form_test_helpers.dart';

void main() {
  late MockLoginService mockLoginService;
  late SubmitLoginFormNotifier loginNotifier;

  setUp(() {
    loginNotifier = SubmitLoginFormNotifier(
      mockLoginService = MockLoginService(),
    );
  });

  test(
    'initial form and field states are dirty',
    () {
      expect(
        loginNotifier.form.value.validationState,
        ValidationState.dirty,
      );
      expect(
        loginNotifier.form.email.value.validationState,
        ValidationState.dirty,
      );
      expect(
        loginNotifier.form.password.value.validationState,
        ValidationState.dirty,
      );
    },
  );

  test(
    'submit() form validates and perform server validations ',
    () async {
      when(
        () => mockLoginService.login(any(), any()),
      ).thenAnswer(
        (_) async => LoginResult.emailAlreadyUsed,
      );

      loginNotifier.form.email.updateValue('email@email.com');
      loginNotifier.form.password.updateValue('password');
      await loginNotifier.submit();

      expect(
        loginNotifier.form.email.value,
        const FieldControllerState(
          value: 'email@email.com',
          error: EmailValidationError.alreadyUsed,
          validationState: ValidationState.invalid,
        ),
      );
      expect(
        loginNotifier.form.value.validationState,
        ValidationState.invalid,
      );
      expect(
        loginNotifier.form.password.value.validationState,
        ValidationState.valid,
      );
    },
  );
}
