import 'package:easy_forms/easy_forms.dart';
import 'package:flutter_test/flutter_test.dart';

enum _SelectValidationError { notSupported }

enum _MultiSelectValidationError { tooManyOptionsSelected }

void main() {
  group(
    'SelectFieldController',
    () {
      late SelectFieldController<String, _SelectValidationError> controller;

      setUp(
        () {
          controller = SelectFieldController<String, _SelectValidationError>(
            initialValue: 'a',
            validator: (value) {
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
          expect(controller.value.value, 'a');
        },
      );

      test(
        'should have the initial options',
        () {
          expect(controller.options.value, ['a', 'b', 'c']);
        },
      );

      test(
        'should update the value',
        () {
          controller.updateValue('b');
          expect(controller.value.value, 'b');
        },
      );

      test(
        'should update the options',
        () {
          controller.setOptions(['a', 'b']);
          expect(controller.options.value, ['a', 'b']);
        },
      );

      test(
        'should validate the value',
        () {
          controller
            ..updateValue('c')
            ..validate();

          expect(controller.error.value, _SelectValidationError.notSupported);
          expect(controller.validationState.value, ValidationState.invalid);
        },
      );
    },
  );

  group(
    'MultiselectFieldController',
    () {
      late MultiselectFieldController controller;

      setUp(
        () {
          controller = MultiselectFieldController(
            initialValue: ['a'],
            validator: (value) {
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
          expect(controller.value.value, ['a']);
        },
      );

      test(
        'should have the initial options',
        () {
          expect(controller.options.value, ['a', 'b', 'c']);
        },
      );

      test(
        'should update the value',
        () {
          controller.updateValue(['b']);
          expect(controller.value.value, ['b']);
        },
      );

      test(
        'should update the options',
        () {
          controller.setOptions(['a', 'b']);
          expect(controller.options.value, ['a', 'b']);
        },
      );

      test(
        'should add an option to the value',
        () {
          controller.add('b');
          expect(controller.value.value, ['a', 'b']);
        },
      );

      test(
        'should not add an option to the value if it is already there',
        () {
          controller.add('a');
          expect(controller.value.value, ['a']);
        },
      );

      test(
        'should remove an option from the value',
        () {
          controller.remove('a');
          expect(controller.value.value, []);
        },
      );

      test(
        'should not remove an option from the value if it is not there',
        () {
          controller.remove('b');
          expect(controller.value.value, ['a']);
        },
      );

      test(
        'should validate the value',
        () {
          controller
            ..updateValue(['a', 'b', 'c'])
            ..validate();

          expect(
            controller.error.value,
            _MultiSelectValidationError.tooManyOptionsSelected,
          );
          expect(controller.validationState.value, ValidationState.invalid);
        },
      );
    },
  );
}
