// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:easy_forms/easy_forms.dart';

typedef FieldValidator<Value, ValidationError> = ValidationError? Function(
  Value value,
  FieldRef ref,
);

/// [FieldController] is a controller for a field in a form.
class FieldController<Value, ValidationError>
    implements FormPart<FieldControllerState<Value, ValidationError>> {
  /// Creates a [FieldController].
  ///
  /// If [autoValidate] is set to true, the field will be validated on every its value change, so:
  /// * immediately with the initial value
  /// * when [updateValue] is called
  /// * when [validate] is called
  FieldController({
    required Value initialValue,
    FieldValidator<Value, ValidationError>? validator,
    this.debugLabel,
    this.autoValidate = false,
  })  : _initialValue = initialValue,
        _validator = validator ?? _defaultValidator;

  // Creates a validator that always returns null (field's value is always valid)
  static ValidationError? _defaultValidator<Value, ValidationError>(
    Value value,
    FieldRef ref,
  ) =>
      null;

  /// {@macro field_controller_state}
  @override
  FieldControllerState<Value, ValidationError> get value => _value.value;

  late final ValueNotifier<FieldControllerState<Value, ValidationError>>
      _value = ValueNotifier(
    FieldControllerState<Value, ValidationError>(
      value: _initialValue,
      error: autoValidate ? _validator(_initialValue, _ref) : null,
      validationState: autoValidate
          ? _validator(_initialValue, _ref) == null
              ? ValidationState.valid
              : ValidationState.invalid
          : ValidationState.dirty,
    ),
  );

  /// The value of the field.
  Value get fieldValue => value.value;

  /// Whether the field is validated on every change of its value.
  final bool autoValidate;

  // ignore: invalid_use_of_protected_member
  bool get hasListeners => _value.hasListeners;

  /// The validator of the field.
  /// It is called when the field is validated.
  ///
  /// It should return null if the field is valid.
  final FieldValidator<Value, ValidationError> _validator;

  final Value _initialValue;
  late final _ref = FieldRef(this, autoValidate);

  /// The debug label of the field.
  /// It is used in [toString]/[toMap] to identify the field.
  final String? debugLabel;

  @override
  void addListener(VoidCallback listener) {
    _value.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _value.removeListener(listener);
  }

  void dispose() {
    _ref.dispose();
    _value.dispose();
  }

  /// Updates the value of the field.
  ///
  /// If [autoValidate] is true, the field will be validated immediately.
  void updateValue(Value value) {
    if (autoValidate) {
      final error = _validator(value, _ref);
      _value.value = FieldControllerState(
        value: value,
        error: error,
        validationState:
            error == null ? ValidationState.valid : ValidationState.invalid,
      );
    } else {
      _value.value = FieldControllerState(
        value: value,
        error: null,
        validationState: ValidationState.dirty,
      );
    }
  }

  /// Validates the field.
  ///
  /// Returns true if the field is valid, false otherwise.
  @override
  bool validate() {
    final error = _validator(value.value, _ref);
    _value.value = FieldControllerState(
      value: value.value,
      error: error,
      validationState:
          error == null ? ValidationState.valid : ValidationState.invalid,
    );
    return error == null;
  }

  /// Overrides the validation state of the field.
  ///
  /// It is useful when the app-side validation of the field is not enough,
  /// eg. some validation is performed on the server.
  void overrideValidationError(ValidationError error) {
    _value.value = FieldControllerState(
      value: value.value,
      error: error,
      validationState: ValidationState.invalid,
    );
  }

  /// Used to dump the state of the field.
  @override
  Map<String, String> toMap() {
    return {
      'type': '$runtimeType',
      'debugLabel': debugLabel.toString(),
      'hash': identityHashCode(this).toString(),
      'value': value.value.toString(),
      'error': value.error.toString(),
      'validationState': value.validationState.toString(),
    };
  }

  @override
  String toString() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toMap());
  }
}

/// {@template field_controller_state}
/// The state of the field.
/// It contains the current value, error and validation state.
/// {@endtemplate}
class FieldControllerState<Value, ValidationError> implements FormPartState {
  /// {@macro field_controller_state}
  const FieldControllerState({
    required this.value,
    required this.error,
    required this.validationState,
  });

  /// The current value of the field.
  final Value value;

  /// The current validation error of the field.
  final ValidationError? error;

  /// The current validation state of the node.
  @override
  final ValidationState validationState;

  @override
  bool operator ==(
    covariant FieldControllerState<Value, ValidationError> other,
  ) {
    if (identical(this, other)) return true;

    return other.value == value &&
        other.error == error &&
        other.validationState == validationState;
  }

  @override
  int get hashCode => Object.hash(value, error, validationState);

  @override
  String toString() {
    return 'FieldControllerState(value: $value, error: $error, validationState: $validationState)';
  }
}

/// It is used to watch the state of another field.
/// It is useful to create fields validators that depend on other fields.
class FieldRef {
  final FieldController _parent;
  final bool _autoValidate;

  final _dependencies = <FieldController>[];

  FieldRef(
    this._parent,
    this._autoValidate,
  );

  FieldControllerState<T, ValidationError> watch<T, ValidationError>(
    FieldController<T, ValidationError> field,
  ) {
    if (_autoValidate) {
      _listenToDependency(field);
    }

    return field.value;
  }

  void dispose() {
    for (final field in _dependencies) {
      field.removeListener(_validate);
    }
  }

  void _listenToDependency(FieldController field) {
    if (!_dependencies.contains(field)) {
      _dependencies.add(field);
      field.addListener(_validate);
    }
  }

  void _validate() {
    _parent.validate();
  }
}
