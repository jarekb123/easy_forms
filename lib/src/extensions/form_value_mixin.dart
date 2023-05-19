import 'package:easy_forms_validation/easy_forms_validation.dart';
import 'package:easy_forms_validation/src/extensions/form_extension.dart';
import 'package:flutter/widgets.dart';

mixin FormValueMixin<Form extends FormControllerMixin, T>
    implements FormExtension<Form> {
  /// Maps form fields values to a validated value representated as single object.
  @protected
  T mapToValidatedValue();

  /// Returns the value of the field if it is valid, otherwise throws a [StateError].
  T getValidatedValue() {
    if (form.value.validationState != ValidationState.valid) {
      throw StateError('Cannot get value of invalid form');
    }
    return mapToValidatedValue();
  }

  /// Returns the value of the field if it is valid, otherwise returns `null`.
  T? getValidatedValueOrNull() {
    if (form.value.validationState != ValidationState.valid) {
      return null;
    }
    return mapToValidatedValue();
  }
}
