import 'package:flutter/services.dart';

import '../../hybrid_custom_text_field.dart';

class DateInputFormatter extends TextInputFormatter {
  final HybridTextFieldFormatterDateType type;

  DateInputFormatter(this.type);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    switch (type) {
      case HybridTextFieldFormatterDateType.mmyy:
        if (text.length > 4) text = text.substring(0, 4);
        if (text.length >= 3) text = '${text.substring(0, 2)}/${text.substring(2)}';
        break;
      case HybridTextFieldFormatterDateType.mmyyyy:
        if (text.length > 6) text = text.substring(0, 6);
        if (text.length >= 3) text = '${text.substring(0, 2)}/${text.substring(2)}';
        break;
      case HybridTextFieldFormatterDateType.ddmmyyyy:
        if (text.length > 8) text = text.substring(0, 8);
        if (text.length >= 5) {
          text = '${text.substring(0, 2)}/${text.substring(2, 4)}/${text.substring(4)}';
        } else if (text.length >= 3) {
          text = '${text.substring(0, 2)}/${text.substring(2)}';
        }
        break;
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
