import "package:flutter/services.dart";

class MaxValueInputFormatter extends TextInputFormatter {
  final int maxValue;

  MaxValueInputFormatter(this.maxValue);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final int newValueAsInt = int.tryParse(newValue.text) ?? 0;
    if (newValueAsInt > maxValue) {
      // If the entered value is greater than the maxValue, set it to maxValue.
      newValue = TextEditingValue(
        text: maxValue.toString(),
        selection: TextSelection.fromPosition(
          TextPosition(offset: maxValue.toString().length),
        ),
      );
    }
    return newValue;
  }
}

class MinValueInputFormatter extends TextInputFormatter {
  final int minValue;

  MinValueInputFormatter(this.minValue);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final int newValueAsInt = int.tryParse(newValue.text) ?? 0;
    if (newValueAsInt < minValue) {
      // If the entered value is lesser than the minValue, set it to minValue.
      newValue = TextEditingValue(
        text: minValue.toString(),
        selection: TextSelection.fromPosition(
          TextPosition(offset: minValue.toString().length),
        ),
      );
    }
    return newValue;
  }
}
