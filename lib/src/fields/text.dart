import 'package:easy_forms_validation/easy_forms_validation.dart';

class TextFieldController<ValidationError>
    extends FieldController<String, ValidationError> {
  TextFieldController({
    super.initialValue = '',
    super.validator,
    super.debugLabel,
  });
}
