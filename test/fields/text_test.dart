import 'package:easy_forms/easy_forms.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

enum _TextFieldValidationError { tooShort, tooLong }

void main() {
  group(
    'TextFieldController',
    () {
      late TextFieldController<_TextFieldValidationError> field;

      setUp(
        () {
          field = TextFieldController<_TextFieldValidationError>(
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
          expect(field.value.value, 'a');
        },
      );

      test(
        'should update the value',
        () {
          field.updateValue('abc');
          expect(field.value.value, 'abc');
        },
      );

      test(
        'should validate the value',
        () {
          field
            ..updateValue('ab')
            ..validate();
          expectValidationError(
            field.value,
            _TextFieldValidationError.tooShort,
          );
          expectValidationState(field.value, ValidationState.invalid);

          field
            ..updateValue('abcdef')
            ..validate();
          expectValidationError(field.value, _TextFieldValidationError.tooLong);
          expectValidationState(field.value, ValidationState.invalid);

          field
            ..updateValue('abc')
            ..validate();
          expectValidationError(field.value, isNull);
          expectValidationState(field.value, ValidationState.valid);
        },
      );
    },
  );
}
