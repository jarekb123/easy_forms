import 'package:easy_forms_validation/easy_forms_validation.dart';
import 'package:flutter/foundation.dart';

ValidationError? _defaultValidator<Value, ValidationError>(
  Value value,
) =>
    null;

class EasyFormField<T, E extends Object>
    implements ValueListenable<EasyFormFieldState<T, E>> {
  EasyFormField({
    required T initialValue,
    FieldValidator<T, E>? validator,
  })  : _value = ValueNotifier(EasyFormFieldState<T, E>(
          initialValue: initialValue,
          value: initialValue,
        )),
        _validator = validator ?? _defaultValidator;

  final ValueNotifier<EasyFormFieldState<T, E>> _value;

  final FieldValidator<T, E> _validator;

  @override
  void addListener(VoidCallback listener) {
    _value.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _value.removeListener(listener);
  }

  @override
  EasyFormFieldState<T, E> get value => _value.value;

  void updateValue(T value) {
    E? error;
    if (_value.value.autovalidate) {
      error = _validator(value);
    }

    _value.value = _value.value.copyWith(value: value, error: error);
  }

  bool validate() {
    final error = _validator(_value.value.value);

    _value.value = _value.value.copyWith(error: error);

    return error == null;
  }

  void setAutovalidate(bool autovalidate) {
    _value.value = _value.value.copyWith(autovalidate: autovalidate);
  }

  void clearErrors() {
    _value.value = _value.value.copyWith(error: null);
  }
}

class EasyFormFieldState<T, E> {
  EasyFormFieldState({
    required this.initialValue,
    required this.value,
    this.error,
    this.autovalidate = false,
  });

  final T initialValue;
  final T value;
  final E? error;
  final bool autovalidate;

  EasyFormFieldState<T, E> copyWith({
    T? initialValue,
    T? value,
    E? error,
    bool? autovalidate,
  }) =>
      EasyFormFieldState<T, E>(
        initialValue: initialValue ?? this.initialValue,
        value: value ?? this.value,
        error: error ?? this.error,
        autovalidate: autovalidate ?? this.autovalidate,
      );
}
