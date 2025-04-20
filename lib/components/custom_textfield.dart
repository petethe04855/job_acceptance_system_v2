import 'package:flutter/material.dart';
import 'package:flutter_application_3/themes/colors.dart';

Widget customTextField({
  required TextEditingController controller,
  required String hintText,
  required Icon? prefixIcon,
  required Widget? suffixIcon,
  required bool obscureText,
  TextInputType textInputType = TextInputType.text,
  required String? Function(String?)? validator,
  required Function(String?)? onSaved,
  required Color? textStyleColor,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: textInputType,
    autofocus: false,
    enableSuggestions: false,
    autocorrect: false,
    obscureText: obscureText,
    decoration: InputDecoration(
      fillColor: backgroundAccent,
      hintStyle: const TextStyle(color: backgroundText),
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(width: 0, style: BorderStyle.none),
      ),
      filled: true,
      isDense: true,
      contentPadding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
    ),
    validator: validator,
    onSaved: onSaved,
    style: TextStyle(color: textStyleColor),
  );
}

Widget customTextFormFieldDetails({
  required TextEditingController controller,
  required String hintText,
  required int maxLines,
  required Icon? prefixIcon,
  required Color? textStyleColor,
  required Function()? onTap,
}) {
  return TextField(
    controller: controller,
    keyboardType: TextInputType.multiline,
    maxLines: maxLines,
    onTap: onTap,
    decoration: InputDecoration(
      filled: true,
      hintText: hintText,
      fillColor: backgroundAccent,
      hintStyle: const TextStyle(color: backgroundText),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(width: 0, style: BorderStyle.none),
      ),
      contentPadding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
    ),
    style: TextStyle(color: textStyleColor),
  );
}
