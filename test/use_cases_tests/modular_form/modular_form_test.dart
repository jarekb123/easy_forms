import 'package:easy_forms_validation/easy_forms_validation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_helpers.dart';
import 'modular_form.dart';

void main() {
  late LoginWithConsentsForm modularForm;

  setUp(
    () {
      modularForm = LoginWithConsentsForm();
    },
  );

  test(
    'form is invalid if a nested form is invalid',
    () {
      modularForm
        ..loginForm.email.updateValue('email@email.com')
        ..loginForm.password.updateValue('password')
        ..consentsForm
            .termsAndConditions
            .updateValue(false) // terms are required
        ..consentsForm.marketingConsent.updateValue(false);

      expect(modularForm.validate(), isFalse);
      expectValidationState(
        modularForm.value,
        ValidationState.invalid,
        reason: 'form should be invalid if a nested form is invalid',
      );
    },
  );

  test(
    'form is valid if nested forms are valid',
    () {
      modularForm
        ..loginForm.email.updateValue('email@email.com')
        ..loginForm.password.updateValue('password')
        ..consentsForm
            .termsAndConditions
            .updateValue(true) // terms are required
        ..consentsForm.marketingConsent.updateValue(false);

      expect(modularForm.validate(), isTrue);
      expectValidationState(
        modularForm.value,
        ValidationState.valid,
        reason: 'form should be valid if nested forms are valid',
      );
    },
  );
}
