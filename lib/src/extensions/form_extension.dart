import 'package:easy_forms_validation/easy_forms_validation.dart';

mixin FormExtension<Form extends FormControllerMixin> {
  /// The form that is being extended.
  ///
  /// IMPORTANT: This field should be `final` to make sure that form reference is not changed
  Form get form;
}
