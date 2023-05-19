import 'package:easy_forms_validation/easy_forms_validation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

enum _SelectValidationError { notSupported }

enum _MultiSelectValidationError { tooManyOptionsSelected }

void main() {
  group(
    'SelectFieldController',
    () {
      late SelectFieldController<String, _SelectValidationError> field;

      setUp(
        () {
          field = SelectFieldController<String, _SelectValidationError>(
            initialValue: 'a',
            validator: (value, _) {
              if (value == 'c') {
                return _SelectValidationError.notSupported;
              }
              return null;
            },
            initialOptions: ['a', 'b', 'c'],
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
        'should have the initial options',
        () {
          expect(field.options.value, ['a', 'b', 'c']);
        },
      );

      test(
        'should update the value',
        () {
          field.updateValue('b');
          expect(field.value.value, 'b');
        },
      );

      test(
        'should update the options',
        () {
          field.setOptions(['a', 'b']);
          expect(field.options.value, ['a', 'b']);
        },
      );

      test(
        'should validate the value',
        () {
          field
            ..updateValue('c')
            ..validate();

          expectValidationError(
              field.value, _SelectValidationError.notSupported);
          expectValidationState(field.value, ValidationState.invalid);
        },
      );
    },
  );

  group(
    'MultiselectFieldController',
    () {
      late MultiselectFieldController field;

      setUp(
        () {
          field = MultiselectFieldController(
            initialValue: ['a'],
            validator: (value, _) {
              if (value.length > 2) {
                return _MultiSelectValidationError.tooManyOptionsSelected;
              }
              return null;
            },
            initialOptions: ['a', 'b', 'c'],
          );
        },
      );

      test(
        'should have the initial value',
        () {
          expect(field.value.value, ['a']);
        },
      );

      test(
        'should have the initial options',
        () {
          expect(field.options.value, ['a', 'b', 'c']);
        },
      );

      test(
        'should update the value',
        () {
          field.updateValue(['b']);
          expect(field.value.value, ['b']);
        },
      );

      test(
        'should update the options',
        () {
          field.setOptions(['a', 'b']);
          expect(field.options.value, ['a', 'b']);
        },
      );

      test(
        'should add an option to the value',
        () {
          field.add('b');
          expect(field.value.value, ['a', 'b']);
        },
      );

      test(
        'should not add an option to the value if it is already there',
        () {
          field.add('a');
          expect(field.value.value, ['a']);
        },
      );

      test(
        'should remove an option from the value',
        () {
          field.remove('a');
          expect(field.value.value, []);
        },
      );

      test(
        'should not remove an option from the value if it is not there',
        () {
          field.remove('b');
          expect(field.value.value, ['a']);
        },
      );

      test(
        'should validate the value',
        () {
          field
            ..updateValue(['a', 'b', 'c'])
            ..validate();

          expectValidationError(
            field.value,
            _MultiSelectValidationError.tooManyOptionsSelected,
          );
          expectValidationState(field.value, ValidationState.invalid);
        },
      );
    },
  );
}
