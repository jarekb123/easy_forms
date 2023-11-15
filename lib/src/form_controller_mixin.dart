// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:easy_forms_validation/src/form_field.dart';
import 'package:flutter/foundation.dart';

/// [FormControllerMixin] is a mixin for any class that needs form validation logic.
///
/// It can be used with any state management solution, eg. ChangeNotifier, Riverpod, flutter_bloc, etc.
///
/// {@template formcontrollermixin}
/// It can be used to validate the form and to get the validation state of its fields.
/// {@endtemplate}
///
/// {@macro formcontroller.fields}
mixin FormControllerMixin {
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
  List<EasyFormField> get fields;

  Listenable get onFieldsChanged => Listenable.merge(fields);

  String? get debugLabel => null;

  Map<String, dynamic> toMap() {
    return {
      'type': '$runtimeType',
      'debugLabel': debugLabel,
      'hash': identityHashCode(this).toString(),
      'fields': fields.map((e) => e.value.value)
    };
  }

  @override
  String toString() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toMap());
  }

  void validateWithAutovalidate() {
    for (final field in fields) {
      if (field.value.autovalidate) field.validate();
    }
  }

  void setAutovalidate(bool autovalidate) {
    for (final field in fields) {
      field.setAutovalidate(autovalidate);
    }
  }

  void clearErrors() {
    for (final field in fields) {
      field.clearErrors();
    }
  }

  bool validate({bool enableAutovalidate = true}) {
    if (enableAutovalidate) {
      setAutovalidate(true);
    }

    return [for (final field in fields) field.validate()].every((e) => e);
  }
}
