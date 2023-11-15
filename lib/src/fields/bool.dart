import 'package:easy_forms_validation/easy_forms_validation.dart';

class BoolFieldController<ValidationError>
    extends FieldController<bool, ValidationError> {
  BoolFieldController({
    super.initialValue = false,
    super.validator,
    super.debugLabel,
    super.autoValidate,
  });
}
