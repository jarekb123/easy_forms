import 'package:easy_forms_validation/easy_forms_validation.dart';

enum EmailValidationError { invalidFormat, alreadyUsed }

enum PasswordValidationError { tooShort }

class LoginForm with FormControllerMixin {
  final email = TextFieldController(
    initialValue: '',
    validator: (value) {
      if (value.isEmpty || !value.contains('@')) {
        return EmailValidationError.invalidFormat;
      }
      return null;
    },
  );
  final password = TextFieldController(
    initialValue: '',
    validator: (value) {
      if (value.length < 6) {
        return PasswordValidationError.tooShort;
      }
      return null;
    },
  );

  @override
  List<EasyForm<FormPartState>> get fields => [email, password];
}
