// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:easy_forms/easy_forms.dart';

/// [FormControllerMixin] is a mixin for any class that needs form validation logic.
///
/// It can be used with any state management solution, eg. ChangeNotifier, Riverpod, flutter_bloc, etc.
///
/// {@template formcontrollermixin}
/// It can be used to validate the form and to get the validation state of its fields.
/// {@endtemplate}
///
/// {@macro formcontroller.fields}
mixin FormControllerMixin implements FormPart<FormControllerState> {
  /// The fields of the form.
  ///
  /// {@template formcontroller.fields}
  /// The fields can be grouped in subform with using another [FormControllerMixin].
  /// This will make the form more modular and reusable.
  ///
  /// Example:
  /// ```
  /// class UserIdentityFormController with FormControllerMixin {
  ///   final email = EmailFieldController();
  ///   final password = PasswordFieldController();
  ///   List<FormPart> get fields => [email, password];
  /// }
  /// class RegisterFormController with FormControllerMixin {
  ///   final userIdentity = UserIdentityFormController();
  ///   final firstName = TextFieldController();
  ///   final lastName = TextFieldController();
  ///   List<FormPart> get fields => [userIdentity, firstName, lastName];
  /// }
  /// ```
  /// {@endtemplate}
  List<FormPart> get fields;

  String? get debugLabel => null;

  bool _listened = false;

  late final _value = ValueNotifier(
    FormControllerState(validationState: _computeValidationState()),
  );

  @override
  @mustCallSuper
  void addListener(VoidCallback listener) {
    _maybeListenToFields();
    _value.addListener(listener);
  }

  @override
  @mustCallSuper
  void removeListener(VoidCallback listener) {
    _value.removeListener(listener);
    // ignore: invalid_use_of_protected_member
    if (!_value.hasListeners) {
      _listened = false;
      for (final field in fields) {
        field.removeListener(_onFieldChanged);
      }
    }
  }

  /// Current state of the form.
  @override
  FormControllerState get value {
    _maybeListenToFields();
    return _value.value;
  }

  /// Validates all fields of the form.
  @override
  bool validate() {
    return fields.every((field) => field.validate());
  }

  void _maybeListenToFields() {
    if (!_listened) {
      _listened = true;
      for (final field in fields) {
        field.addListener(_onFieldChanged);
      }
    }
  }

  void _onFieldChanged() {
    _value.value = FormControllerState(
      validationState: _computeValidationState(),
    );
  }

  ValidationState _computeValidationState() {
    for (final field in fields) {
      final validationState = field.value.validationState;
      if (validationState == ValidationState.dirty) {
        return ValidationState.dirty;
      }
      if (validationState == ValidationState.invalid) {
        return ValidationState.invalid;
      }
    }
    return ValidationState.valid;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': '$runtimeType',
      'debugLabel': debugLabel,
      'hash': identityHashCode(this).toString(),
      'validationState': value.validationState.toString(),
      'fields': fields.map((field) => field.toMap()).toList(),
    };
  }

  @override
  String toString() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toMap());
  }
}

class FormControllerState implements FormPartState {
  const FormControllerState({
    required this.validationState,
  });

  @override
  final ValidationState validationState;

  @override
  bool operator ==(covariant FormControllerState other) {
    if (identical(this, other)) return true;

    return other.validationState == validationState;
  }

  @override
  int get hashCode => validationState.hashCode;

  @override
  String toString() {
    return 'FormControllerState(validationState: $validationState)';
  }
}
