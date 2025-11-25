// https://github.com/dart-league/validators/blob/master/lib/validators.dart

// Email

final RegExp _email = RegExp(
  r"^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$",
);

bool isEmail(String str) => _email.hasMatch(str.toLowerCase());
bool isNotEmail(String str) => !isEmail(str);

// Phone

final RegExp _phone = RegExp(r"^[0-9()+\- ]{8,15}$"); // RegExp(r"^\(\d\d\d\)\d\d\d\-\d\d\d\d$");

bool isPhoneNumber(String str) => _phone.hasMatch(str);

// Int

/*
here you are the int64 max value:

const int intMaxValue = 9223372036854775807;
for dart web is 2^53-1:

const int intMaxValue = 9007199254740991;
*/

bool isInt(
  String str, {
  int min = -0x8000000000000000,
  int max = 9007199254740991, // 0x7fffffffffffffff
}) {
  final val = int.tryParse(str);
  if (val == null) return false;
  return val >= min && val <= max;
}

bool isPrice(String str, {double min = 0, double max = double.maxFinite}) {
  final val = double.tryParse(str);
  if (val == null) return false;
  return val >= min && val <= max;
}


// eof
