import 'package:easy_forms/easy_forms.dart';

class TextFieldController<ValidationError>
    extends FieldController<String, ValidationError> {
  TextFieldController({
    required super.initialValue,
    required super.validator,
  });
}
