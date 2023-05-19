import 'package:easy_forms/easy_forms.dart';

class BoolFieldController<ValidationError>
    extends FieldController<bool, ValidationError> {
  BoolFieldController({
    super.initialValue = false,
    super.validator,
  });
}
