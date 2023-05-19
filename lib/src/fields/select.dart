import 'package:easy_forms_validation/easy_forms_validation.dart';
import 'package:flutter/foundation.dart';

class SelectFieldController<Value, ValidationError>
    extends FieldController<Value, ValidationError> {
  SelectFieldController({
    required super.initialValue,
    required FieldValidator<Value, ValidationError> validator,
    required List<Value> initialOptions,
    String? debugLabel,
    bool autoValidate = false,
  })  : _options = ValueNotifier(initialOptions),
        super(
          validator: validator,
          debugLabel: debugLabel,
          autoValidate: autoValidate,
        );

  ValueListenable<List<Value>> get options => _options;
  final ValueNotifier<List<Value>> _options;

  void setOptions(List<Value> options) {
    _options.value = options;
  }
}

class MultiselectFieldController<Value, ValidationError>
    extends FieldController<List<Value>, ValidationError> {
  MultiselectFieldController({
    required super.initialValue,
    required FieldValidator<List<Value>, ValidationError> validator,
    required List<Value> initialOptions,
    String? debugLabel,
    bool autoValidate = false,
  })  : _options = ValueNotifier(initialOptions),
        super(
          validator: validator,
          debugLabel: debugLabel,
          autoValidate: autoValidate,
        );

  ValueListenable<List<Value>> get options => _options;
  final ValueNotifier<List<Value>> _options;

  /// Sets the list of options.
  ///
  /// This method is useful, eg. when the list of options is loaded asynchronously from the server.
  void setOptions(List<Value> options) {
    _options.value = options;
  }

  /// Adds the option to the list of selected options.
  void add(Value option) {
    final updated = [...value.value];
    if (!updated.contains(option)) {
      updated.add(option);
      updateValue(updated);
    }
  }

  /// Removes the option from the list of selected options.
  void remove(Value option) {
    final updated = [...value.value];
    if (updated.contains(option)) {
      updated.remove(option);
      updateValue(updated);
    }
  }
}
