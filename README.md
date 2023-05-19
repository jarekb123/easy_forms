# easy_forms_validation

`easy_forms_validation` is a Dart library that allows for easy separation of form validation logic from the UI layer in Flutter applications. 
It provides a simple and modular way to validate form data and manage form field validation state, making your code more maintainable and organized.

## `FormPart`

`FormPart` represents a part of the form that can be validated. It can be a field, a group of fields, or a whole form.

To validate any form part use `bool validate()` method.

## `FormControllerMixin`

`FormControllerMixin` is a `FormPart` that represent a form built from fields or other forms. It is responsible to perform validation on every its field.

Example:

```dart
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

  final consent = BoolFieldController();

  @override
  List<FormPart<FormPartState>> get fields => [email, password, consent];
}
```

## `FieldController`

`FieldController` is a `FormPart` that represents a field in a form.

Predefined types of field controllers:

* `TextFieldController` - use it with `TextFieldBuilder` that is used to control text field widget
* `BoolFieldController` - use it when field value is type of `bool`
* `SelectFieldController` - use it for fields that has predefined options, eg. dropdown
* `MultiSelectFieldController` - use it for fields that enables to select multiple predefined options

## Extensions

These mixins doesn't need to be a mixin on `FormControllerMixin`. They all require to implement `FormController get form` getter. 

* `FormValueMixin` - use it when you want to represent whole validated form as single value (object).
* `SubmitFormMixin` - use it with you want to add submit logic to the form