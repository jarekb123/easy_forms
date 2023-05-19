import 'package:easy_forms_validation/easy_forms_validation.dart';
import 'package:easy_forms_validation/src/fields/bool.dart';

import '../../test_forms/login_form.dart';

class ConsentsForm with FormControllerMixin {
  final termsAndConditions = BoolFieldController(
    validator: (value, ref) {
      if (value == false) {
        return 'Terms and conditions must be accepted';
      }
      return null;
    },
  );
  final marketingConsent = BoolFieldController();

  @override
  List<FormPart<FormPartState>> get fields {
    return [
      termsAndConditions,
      marketingConsent,
    ];
  }
}

class LoginWithConsentsForm with FormControllerMixin {
  final loginForm = LoginForm();
  final consentsForm = ConsentsForm();

  @override
  List<FormPart<FormPartState>> get fields => [loginForm, consentsForm];
}
