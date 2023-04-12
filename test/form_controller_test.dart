import 'package:easy_forms/easy_forms.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'test_helpers.dart';

void main() {
  group('simple flat form', () {
    late _FlatForm form;

    setUp(() {
      form = _FlatForm();
    });

    test('initially checks validation state', () {
      expect(form.validationState.value, ValidationState.dirty);
    });

    test('update of any field value changes form validation state to dirty',
        () {
      form.field1.updateValue('not empty');
      expect(form.validationState.value, ValidationState.dirty);
    });

    test('test validate() side effects', () {
      form.field1.updateValue('not empty');
      // field2 is valid initially

      expect(form.validate(), isTrue);
      expect(
        form.validationState.value,
        ValidationState.valid,
        reason:
            'validation state should be valid after validate() on valid form',
      );

      form.field1.updateValue('changed');
      expect(
        form.validationState.value,
        ValidationState.dirty,
        reason:
            'validation state should be dirty after updateValue() on any field',
      );

      form.field2.updateValue(''); // empty field2 - invalid value
      expect(form.validate(), isFalse);
      expect(
        form.validationState.value,
        ValidationState.invalid,
        reason:
            'validation state should be invalid after validate() on invalid form',
      );
    });
  });

  group(
    'form with autovalidated fields',
    () {
      late _AutovalidatedForm form;
      late MockListener<ValidationState> validationStateListener;

      setUp(() {
        form = _AutovalidatedForm();
        validationStateListener = MockListener<ValidationState>();
        form.validationState.addListener(
          () => validationStateListener(form.validationState.value),
        );
      });

      test('initially checks validation state', () {
        expect(form.validationState.value, ValidationState.valid);
        verifyZeroInteractions(validationStateListener);
      });

      test(
        'update of any field value changes validates the form validation',
        () {
          form.field1.updateValue('not');
          expect(form.validationState.value, ValidationState.valid);
          // initial validation state is not changed
          verifyNever(() => validationStateListener(ValidationState.valid));

          form.field1.updateValue('');
          expect(form.validationState.value, ValidationState.invalid);

          verify(
            () => validationStateListener(ValidationState.invalid),
          ).called(1);
          verifyNoMoreInteractions(validationStateListener);
        },
      );

      test('test validation state changes (without calling validate())', () {
        form.field1.updateValue('not empty');
        // field2 is valid initially

        expect(
          form.validationState.value,
          ValidationState.valid,
          reason: 'validation state should be valid on valid form',
        );

        form.field1.updateValue('changed');
        form.field2.updateValue('changed');
        expect(
          form.validationState.value,
          isNot(ValidationState.dirty),
          reason: 'validation state should not be dirty after updateValue()'
              'on form with autovalidated fields',
        );

        form.field2.updateValue(''); // empty field2 - invalid value
        expect(
          form.validationState.value,
          ValidationState.invalid,
          reason:
              'validation state should be invalid after validate() on invalid form',
        );
      });
    },
  );

  group('form with subforms', () {
    late _NestedForm form;

    setUp(() {
      form = _NestedForm();
    });

    test('initially checks validation state', () {
      expect(form.validationState.value, ValidationState.dirty);
    });

    test(
      'update of any non-autovalidated field value'
      'changes form validation state to dirty',
      () {
        form.validate();
        expect(form.validationState.value, isNot(ValidationState.dirty));

        form.subform.field1.updateValue('not empty');
        expect(form.validationState.value, ValidationState.dirty);
      },
    );

    test('test validate() side effects', () {
      form.subform.field1.updateValue('not empty');

      expect(
        form.autovalidatedSubform.validationState.value,
        ValidationState.valid,
        reason: 'autovalidated subform should be valid',
      );
      expect(form.validate(), isTrue);
      expect(
        form.validationState.value,
        ValidationState.valid,
        reason:
            'validation state should be valid after validate() on valid form',
      );

      form.subform.field1.updateValue('changed');
      expect(
        form.validationState.value,
        ValidationState.dirty,
        reason:
            'validation state should be dirty after updateValue() on any field',
      );

      form.subform.field2.updateValue(''); // empty field2 - invalid value
      expect(form.validate(), isFalse);
      expect(
        form.validationState.value,
        ValidationState.invalid,
        reason:
            'validation state should be invalid after validate() on invalid form',
      );

      form.subform.field2.updateValue('changed');
      expect(form.validate(), isTrue);
      expect(
        form.validationState.value,
        ValidationState.valid,
        reason:
            'validation state should be valid after validate() on valid form',
      );
    });

    test(
      'dump form state',
      () {
        final form = _NestedForm();
        // ignore: avoid_print
        print(form.toString());
      },
      skip: true,
    );
  });
}

String? _validate(String value) {
  if (value.isEmpty) {
    return 'This field is required';
  }
  return null;
}

class _TestFieldController extends FieldController<String, String> {
  _TestFieldController({
    super.initialValue = '',
  }) : super(validator: _validate);
}

class _FlatForm with FormControllerMixin {
  final _TestFieldController field1 = _TestFieldController();
  final _TestFieldController field2 =
      _TestFieldController(initialValue: 'not empty');

  @override
  List<ValidationNode> get fields => [field1, field2];
}

class _AutovalidatedForm with FormControllerMixin {
  final field1 = FieldController<String, String>(
    initialValue: 'not empty',
    validator: _validate,
    autoValidate: true,
  );

  final field2 = FieldController<String, String>(
    initialValue: 'not empty',
    validator: _validate,
    debugLabel: 'field2',
    autoValidate: true,
  );

  @override
  List<ValidationNode> get fields => [field1, field2];
}

class _NestedForm with FormControllerMixin {
  final subform = _FlatForm();
  final autovalidatedSubform = _AutovalidatedForm();

  @override
  List<ValidationNode> get fields => [subform, autovalidatedSubform];
}