import 'package:easy_forms_validation/easy_forms_validation.dart';

enum EmailValidationError { invalidFormat, alreadyUsed }

enum PasswordValidationError { tooShort }

class LoginForm with FormControllerMixin {
  final email = TextFieldController(
    initialValue: '',
    validator: (value, _) {
      if (value.isEmpty || !value.contains('@')) {
        return EmailValidationError.invalidFormat;
      }
      return null;
    },
  );
  final password = TextFieldController(
    initialValue: '',
    validator: (value, _) {
      if (value.length < 6) {
        return PasswordValidationError.tooShort;
      }
      return null;
    },
  );

  @override
  List<FormPart<FormPartState>> get fields => [email, password];
}
