import 'package:flutter/material.dart';

import '../../models/phone_text_field_prefix_entity.dart';
import 'custom_phone_prefixes_list.dart';

class CustomPhoneTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final List<PhoneTextFieldPrefixEntity> prefixes;
  final PhoneTextFieldPrefixEntity selectedPrefix;
  final Function(PhoneTextFieldPrefixEntity prefix)? onPrefixChanged;
  final void Function(String)? onChanged;
  final String? errorMessage;

  bool get hasError => errorMessage != null;

  const CustomPhoneTextField({
    super.key,
    required this.controller,
    this.hint,
    this.label,
    required this.prefixes,
    required this.selectedPrefix,
    required this.onPrefixChanged,
    required this.onChanged,
    this.errorMessage,
  });

  @override
  State<CustomPhoneTextField> createState() => _CustomPhoneTextFieldState();
}

class _CustomPhoneTextFieldState extends State<CustomPhoneTextField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    _focusNode.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _label(),
          const SizedBox(height: 8),
          _phoneField(),
          if (widget.hasError) const SizedBox(height: 5),
          _errorText(),
        ],
      ),
    );
  }

  Widget _phoneField() {
    return Container(
      height: 52,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: Colors.white, border: _getBorder()),
      child: Row(
        children: [
          _prefix(),
          Expanded(child: _textfield()),
        ],
      ),
    );
  }

  Widget _label() {
    if (widget.label == null) return const SizedBox.shrink();

    return Text(
      widget.label!,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Colors.black,
      ),
    );
  }

  Widget _prefix() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showPrefixesList(),
        child: Container(
          height: 52,
          padding: EdgeInsets.only(left: 16.5),
          child: Row(
            spacing: 8,
            children: [
              Text(widget.selectedPrefix.value),
              Icon(Icons.arrow_drop_down),
              Container(
                margin: EdgeInsets.only(right: 8),
                height: 21,
                width: 1,
                color: const Color(0xFFD9D9D9),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textfield() {
    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      onChanged: widget.onChanged,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      style: TextStyle(
        fontSize: 14,
        color: Colors.black,
        fontWeight: FontWeight.normal,
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: _focusNode.hasFocus ? const Color(0xFFF2F2F2) : const Color(0xFFBDBDBD),
        ),
        contentPadding: EdgeInsets.fromLTRB(8, 12, 16, 12),
      ),
    );
  }

  Widget _errorText() {
    if (widget.hasError && _focusNode.hasFocus) return const SizedBox.shrink();
    if (widget.errorMessage == null) return const SizedBox.shrink();

    return SizedBox(
      height: 16,
      child: Text(
        widget.errorMessage!,
        style: const TextStyle(color: Colors.red, fontSize: 12),
      ),
    );
  }

  void _showPrefixesList() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SizedBox(
              width: 32,
              height: 48,
              child: Divider(color: Colors.black, thickness: 4, radius: BorderRadius.circular(2)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 12, left: 14),
            child: const Text(
              "Selecciona el prefijo del país",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: CustomPhonePrefixesList(
              prefixes: widget.prefixes,
              selectedPrefix: widget.selectedPrefix,
              onPrefixSelected: widget.onPrefixChanged,
            ),
          ),
        ],
      ),
    );
  }

  Border _getBorder() {
    if (widget.hasError) {
      return Border.all(color: Colors.red, width: 1, strokeAlign: BorderSide.strokeAlignInside);
    }
    if (_focusNode.hasFocus) {
      return Border.all(color: Colors.black, width: 1, strokeAlign: BorderSide.strokeAlignInside);
    }
    return Border.all(color: const Color(0xFFBDBDBD), width: 1, strokeAlign: BorderSide.strokeAlignInside);
  }
}
