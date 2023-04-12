import 'package:easy_forms/easy_forms.dart';
import 'package:flutter_test/flutter_test.dart';

enum _TextFieldValidationError { tooShort, tooLong }

void main() {
  group(
    'TextFieldController',
    () {
      late TextFieldController<_TextFieldValidationError> controller;

      setUp(
        () {
          controller = TextFieldController<_TextFieldValidationError>(
            initialValue: 'a',
            validator: (value) {
              if (value.length < 3) {
                return _TextFieldValidationError.tooShort;
              }
              if (value.length > 5) {
                return _TextFieldValidationError.tooLong;
              }
              return null;
            },
          );
        },
      );

      test(
        'should have the initial value',
        () {
          expect(controller.value.value, 'a');
        },
      );

      test(
        'should update the value',
        () {
          controller.updateValue('abc');
          expect(controller.value.value, 'abc');
        },
      );

      test(
        'should validate the value',
        () {
          controller
            ..updateValue('ab')
            ..validate();
          expect(controller.error.value, _TextFieldValidationError.tooShort);
          expect(controller.validationState.value, ValidationState.invalid);

          controller
            ..updateValue('abcdef')
            ..validate();
          expect(controller.error.value, _TextFieldValidationError.tooLong);
          expect(controller.validationState.value, ValidationState.invalid);

          controller
            ..updateValue('abc')
            ..validate();
          expect(controller.error.value, null);
          expect(controller.validationState.value, ValidationState.valid);
        },
      );
    },
  );
}
