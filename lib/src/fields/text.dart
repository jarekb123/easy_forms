import 'package:easy_forms/easy_forms.dart';

class TextFieldController<ValidationError>
    extends FieldController<String, ValidationError> {
  TextFieldController({
    super.initialValue = '',
    super.validator,
  });
}
