import 'package:flutter/material.dart';

import '../../models/phone_text_field_prefix_entity.dart';

class CustomPhonePrefixesList extends StatelessWidget {
  final List<PhoneTextFieldPrefixEntity> prefixes;
  final PhoneTextFieldPrefixEntity? selectedPrefix;
  final Function(PhoneTextFieldPrefixEntity)? onPrefixSelected;
  const CustomPhonePrefixesList({super.key, required this.prefixes, this.selectedPrefix, this.onPrefixSelected});

  @override
  Widget build(BuildContext context) {
    return RadioGroup<PhoneTextFieldPrefixEntity>(
      groupValue: selectedPrefix,
      onChanged: (value) {
        if (value != null) {
          onPrefixSelected?.call(value);
          Navigator.pop<PhoneTextFieldPrefixEntity>(context);
        }
      },
      child: ListView.builder(
        itemCount: prefixes.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final prefix = prefixes[index];
          return Column(
            children: [
              RadioListTile<PhoneTextFieldPrefixEntity>(
                contentPadding: EdgeInsets.only(left: 16, right: 8),
                title: Text(
                  "${prefix.value} - ${prefix.name}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                value: prefix,
                radioScaleFactor: 1.4,
                controlAffinity: ListTileControlAffinity.trailing,
                visualDensity: VisualDensity.compact,
                radioSide: BorderSide(width: 1.5, color: Colors.black54),
                fillColor: WidgetStateProperty.all(Colors.black54),
              ),
              Divider(indent: 16, endIndent: 16, height: 0, thickness: 0.5),
            ],
          );
        },
      ),
    );
  }
}
